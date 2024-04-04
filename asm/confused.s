  .include "bootstrap.s"

viccry   = $d011
vicrc    = $d012
vicirq   = $d019
vicirqen = $d01a

cia1icr = $dc0d

nmivec = $fffa
rstvec = $fffc
irqvec = $fffe

LINE = 43

  sei
  lda #$7f
  sta cia1icr
  lda cia1icr
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1
  lda #<nmi
  sta nmivec
  sta rstvec
  lda #>nmi
  sta nmivec+1
  sta rstvec+1
  lda #LINE
  sta 53266
  lda #27
  sta viccry
  lda #1
  sta vicirqen
  sta vicirq
  lda #$35
  sta 1
  cli
  ldy #0
loop
  cpy #0
  beq loop
  sei
  lda #0
  sta vicirqen
  lsr vicirq
  lda #$81
  sta cia1icr
  lda #$37
  sta 1
  cli
  rts

irq
  ldx vicrc
  cpx #LINE
  bne n
  inx
  stx vicrc
  lsr vicirq
  cli
  .rept 18
  nop
  .endr
  .byte 2
n
  pla
  pla
  pla
  dex
  stx vicrc
  lsr vicirq
  inx
  inx
  bit 0
  .rept 5
  nop
  .endr
  .ifdef NTSC
  nop
  .endif
  cpx vicrc
  bne *+2
  stx 53280
  inx
  stx 53280
  rti

nmi
  iny
  rti
