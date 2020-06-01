cry = $d011
rc = $d012
ec = $d020
vicirq = $d019
vicirqm = $d01a
fudge = 251
register = 252
value1 = 253
value2 = 254

initialfudge = 64

cra = $dc0d

irqvec = $0314

defirq = $ea31

  .include "bootstrap.s"

  sei
  lda #%01111111
  sta cra
  lda cra
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec + 1
  lda #46
  sta rc
  lda #27
  sta cry
  lda #1
  sta vicirqm
  sta vicirq
  lda #initialfudge
  sta fudge
  cli
  lda #33
  sta register
  lda #2
  sta value1
  lda #6
  sta value2
  rts

irq
  lda #1
  sta vicirq

  lda rc
.l0
  cmp rc
  beq .l0
  jsr delay
  lda rc
  cmp rc
  bne .l1
  bit 0
  nop
.l1
  jsr delay
  lda rc
  cmp rc
  beq *+2
  beq *+2
  jsr delay
  lda rc
  cmp rc
  beq *+2


  lda fudge
  lsr a
  bcs *+2
  lsr a
  bcs *+2
  bcs *+2
  lsr a
  bcc .l2
  bcs *+2
  nop
.l2
  beq .l4
  sec
.l3
  bne *+2
  sbc #1
  bne .l3
.l4

  ldy #7
  ldx register
.l5
  lda value1
  sta $d000, x
  lda value2
  sta $d000, x
  .rept 21
  nop
  .endr

  dey
  bne .l5

  jmp defirq

delay
  ldy    #7
.l1 dey
  bne    .l1
  nop
  rts
