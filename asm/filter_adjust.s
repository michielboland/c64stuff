  .include "bootstrap.s"

cr    = 13
palnts  = $02a6

irqvec = $0314
iokeys = $fddd
restor = $ff8a

viccry = 53265
vicec = 53280

pra1 = 56320
prb1 = 56321
ta1 =  56324
tb1 =  56326
icr1 = 56333
cra1 = 56334
crb1 = 56335

  ; PAL :   2 sec = 79 * 24943 cycles (more or less)
  ; NTSC :  2 sec = 1307 * 1565 cycles

pal1 = 79 - 1
pal2 = 24943 - 1
nts1 = 1307 - 1
nts2 = 1565 - 1

linprt = $bdcd ; print integer represented by a (hi) x (lo)
strout = $ab1e

scratch = 2
cutoff_counter = 251
irq_counter = 252
type_counter = 253

  .macro PRINT
  lda #<\1
  ldy #>\1
  jsr strout
  .endm

  PRINT resonance
  jsr input_byte
  bcc .ok
.err
  ldx #14
  jmp ($0300)
.ok
  cmp #16
  bcs .err

  .rept 4
  asl a
  .endr
  ora #8
  sta 54295

  PRINT return

  lda #0
  sta cutoff_counter
  sta type_counter

  ldx #nfilters
  lda #0
  jsr linprt
  PRINT rounds
  ldx #ncutoffs
  lda #0
  jsr linprt
  PRINT press_space

  sei
  lda #%00010000
check_space
  bit prb1
  bne check_space

  lda #11
  sta viccry
  lda #0
  sta vicec

  lda #$7f
  sta icr1
  lda icr1
  lda palnts
  bne pal
  ; ntsc
  lda #<nts1
  sta ta1
  lda #>nts1
  sta ta1+1
  lda #<nts2
  sta tb1
  lda #>nts2
  sta tb1+1
  jmp start_timers
pal
  lda #<pal1
  sta ta1
  lda #>pal1
  sta ta1+1
  lda #<pal2
  sta tb1
  lda #>pal2
  sta tb1+1
start_timers
  lda #%00010001 ; load and start timer a
  sta cra1
  lda #%01010001 ; load and start timer b; timer b counts ta underflows
  sta crb1
  lda #%10000010 ; irq on timer b underflow
  sta icr1
  lda #<isr
  sta irqvec
  lda #>isr
  sta irqvec+1
  cli

loop
  ldx type_counter
  lda filter, x
  sta 54296
  lda cutoff_counter
  asl
  tay
  lda cutoffs + 1, y
  sta scratch
  lda cutoffs, y
  sta 54293
  .rept 3
  lsr scratch
  ror
  .endr
  sta 54294
  lda irq_counter
test
  cmp irq_counter
  beq test
  lda cutoff_counter
  clc
  adc #1
  sta cutoff_counter
  cmp #ncutoffs
  bne loop
  lda #0
  sta cutoff_counter
  lda type_counter
  clc
  adc #1
  sta type_counter
  cmp #nfilters
  bne loop
  lda #27
  sta viccry
  lda #14
  sta vicec
  sei
  jsr iokeys
  jsr restor
  cli
  rts

isr
  inc irq_counter
  jmp $ea7e

  .include "input_byte.s"

resonance
  .byte "RESONANCE? ", 0
rounds
  .byte " ROUNDS OF ", 0
press_space
  .byte " CYCLES. PRESS SPACE", cr, "OR FIRE "
  .byte "ON JOYSTICK IN PORT 1 TO START."
return
  .byte cr, 0

filter
  .byte $2f, $1f, $4f, $5f
nfilters = * - filter
cutoffs
  .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 13, 16, 19, 23, 27, 32, 38, 45
  .word 54, 64, 76, 91, 108, 128, 152, 181, 215, 256, 304, 362, 431, 512
  .word 609, 724, 861, 1024, 1218, 1448, 1722, 2047
ncutoffs = (* - cutoffs) / 2
