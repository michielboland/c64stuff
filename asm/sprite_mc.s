irqvec   = $0314

viccry   = $d011
vicrc    = $d012
vicse    = $d015
vicirq   = $d019
vicirqen = $d01a
vicscm   = $d01c

cia1tb   = $dc06
cia1icr  = $dc0d
cia1crb  = $dc0f

defirq   = $ea31

  .include "bootstrap.s"

  jsr init

  sei

  lda #$7f
  sta cia1icr
  lda cia1icr

  .ifdef NTSC
  lda #64
  .else
  lda #62
  .endif
  sta cia1tb
  lda #0
  sta cia1tb+1

  lda #249
  sta vicrc
  lda #$1b
  sta viccry

.l0
  lda vicrc
  bne .l0
  lda vicrc
.l1
  cmp vicrc
  beq .l1
  jsr delay
  lda vicrc
  cmp vicrc
  bne .l2
  bit 0
  nop
.l2
  jsr delay
  lda vicrc
  cmp vicrc
  beq *+2
  beq *+2
  jsr delay
  lda vicrc
  cmp vicrc
  beq *+2
  nop
  nop
  .ifndef NTSC
  nop
  .endif

  lda #$11
  sta cia1crb

  lda #1
  sta vicirqen
  sta vicirq
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1
  cli
  rts

irq
  lda cia1tb
  lsr a
  bcs *+2
  lsr a
  bcs *+2
  bcs *+2
  lsr a
  bcc stable
  bit 0
  nop

stable
  .ifdef NTSC
  nop
  .endif

  lda #$13
  sta viccry
  lda #$ff
  sta vicse
  lda #0
  ldx #$ff
  .rept 17
  nop
  .endr
  bit 0

  .rept 21
  sta vicscm
  .ifdef NTSC
  nop
  .endif
  .rept 5
  stx vicscm
  sta vicscm
  .endr
  .endr

  lda #$1b
  sta viccry
  lda #0
  sta vicse

  lda #1
  sta vicirq
  jmp defirq

  .align 3

delay
  ldy #7
.l0
  dey
  bne .l0
  .ifdef NTSC
  nop
  .endif
  nop
  rts

init
  ldx #16
.l0
  lda sp, x
  sta $d000, x
  dex
  bpl .l0

  ldx #14
.l1
  lda colors, x
  sta $d020, x
  dex
  bpl .l1

  ldx #7
  lda #13
.l2
  sta $07f8, x
  dex
  bpl .l2

  lda #$ff
  sta $d01d
  ldx #60
.l3
  sta $0340, x
  sta $0341, x
  dex
  dex
  dex
  bpl .l3

  lda #$f0
  ldx #62
.l4
  sta $0340, x
  dex
  dex
  dex
  bpl .l4

  lda #0
  sta $3fff

  rts

sp
  .byte 24, 250
  .byte 64, 250
  .byte 104, 250
  .byte 144, 250
  .byte 184, 250
  .byte 224, 250
  .byte 8, 250
  .byte 48, 250
  .byte $c0

colors
  .byte 8, 9, 0, 0, 0, 14, 12, 0, 6, 2, 4, 5, 3, 7, 1
