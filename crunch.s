cry = $d011
rc = $d012
ec = $d020
vicirq = $d019
vicirqm = $d01a
fudge = 251
initialfudge = 34

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
  rts


irq
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

  .macro DELAY
  .rept 25
  nop
  .endr
  bit 0
  .endm

  .rept 4
  lda #28
  sta cry
  sta ec
  DELAY

  lda #29
  sta cry
  sta ec
  DELAY 

  lda #30
  sta cry
  sta ec
  DELAY

  lda #31
  sta cry
  sta ec
  DELAY

  lda #24
  sta cry
  sta ec
  DELAY

  lda #25
  sta cry
  sta ec
  DELAY

  lda #26
  sta cry
  sta ec
  DELAY

  lda #27
  sta cry
  sta ec
  DELAY
  .endr

  lda #1
  sta vicirq
  jmp defirq

delay
  ldy    #7
.l1 dey
  bne    .l1
  nop
  rts
