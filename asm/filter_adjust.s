  .include "bootstrap.s"

cr    = 13
palnts  = $02a6

pra1 = 56320
prb1 = 56321
ta1 =  56324
tb1 =  56326
icr1 = 56333
cra1 = 56334
crb1 = 56335

  ; PAL : 11 sec = 1823 * 5945 cycles (more or less)
  ; NTSC : 11 sec = 3125 * 3600 cycles

pal1 = 1823 - 1
pal2 = 5945 - 1
nts1 = 3125 - 1
nts2 = 3600 - 1

linprt = $bdcd ; print integer represented by a (hi) x (lo)
strout = $ab1e

scratch = 2
filt = 251

  lda #0
  sta filt

  ldx #maxfilt
  lda #0
  jsr linprt
  lda #<press_space
  ldy #>press_space
  jsr strout

  sei
  lda #%00010000
check_space
  bit prb1
  bne check_space

  lda #11
  sta 53265

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

  lda #$2f
  sta 54296
  lda #$08
  sta 54295
loop
  lda filt
  sta 53280 ; some visual feedback
  asl
  tay
  lda filters + 1, y
  sta scratch
  lda filters, y
  sta 54293
  .rept 3
  lsr scratch
  ror
  .endr
  sta 54294
test
  bit icr1
  bpl test
  lda filt
  clc
  adc #1
  cmp #maxfilt
  bne .l0
  lda #0
.l0
  sta filt
  jmp loop

press_space
  .byte " CYCLES. PRESS SPACE OR FIRE", cr
  .byte "ON JOYSTICK IN PORT 1 TO START.", cr, 0

filters
  .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 13, 16, 19, 23, 27, 32, 38, 45
  .word 54, 64, 76, 91, 108, 128, 152, 181, 215, 256, 304, 362, 431, 512
  .word 609, 724, 861, 1024, 1218, 1448, 1722, 2047
maxfilt = (* - filters) / 2
