cia1pra  = $dc00
cia1prb  = $dc01
cia1ddra = $dc02
cia1ddrb = $dc03
cia1tb   = $dc06
cia1icr  = $dc0d

vicrc  = $d012
vicirq = $d019

irqvec = $0314

fudgefac = 28

counter = 251

  .include "bootstrap.s"
  sei
  lda #$7f
  sta cia1icr
  lda cia1icr
  lda #64
  sta cia1tb
  lda #0
  sta cia1tb+1
  lda #248
  sta vicrc
  lda #27
  sta $d011
notras0
  lda vicrc
  bne notras0
  lda vicrc
l0
  cmp vicrc
  beq l0
  jsr delay
  lda vicrc
  cmp vicrc
  bne l1
  bit 0
  nop
l1
  jsr delay
  lda vicrc
  cmp vicrc
  beq *+2
  beq *+2
  jsr delay
  lda vicrc
  cmp vicrc
  beq *+2
  lda #$11
  sta $dc0f
  lda #1
  sta $d01a
  sta vicirq
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1

  lda #0
  sta counter

  cli
  rts

delay
  ldy #7
l5
  dey
  bne l5
  nop
  nop
  rts

irq
  lda cia1tb
  sec
  sbc #fudgefac
  lsr a
  bcs *+2
  lsr a
  bcs *+2
  bcs *+2
  lsr a
  bcc l6
  bit 0
  nop
l6
  lda counter
  lsr a
  bcs *+2
  lsr a
  bcs *+2
  bcs *+2
  lsr a
  bcc urk
  bcs *+2
  nop
urk
  beq l12
  sec
l11
  bne *+2
  sbc #1
  bne l11

l12
  ldx counter
  lda $d013
  sta $0400,x
  inc 53281
  lda #0
  sta cia1ddra
  sta cia1ddrb
  sta cia1prb
  ldx #$10
  ; toggle LP input
  stx cia1ddrb
  sta cia1ddrb
  lda #$ff
  sta cia1ddra
  sta cia1prb
  lda #$7f
  sta cia1pra
  dec 53281
  lda #1
  sta vicirq
  inc counter
  jmp $ea31
