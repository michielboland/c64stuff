
  ; ass.bc - Michiel Boland
  ; 2020-04-03


irqvec   = $0314
joy      = $dc00
joytmp   = 253
color    = 254
flag     = 704
ta       = $dc04
tasave   = 251
cry      = 53265
ec       = 53280

  .include "bootstrap.s"

  sei
  lda #199
  sta tasave
  sta ta
  lda #76
  sta tasave+1
  sta ta+1
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1
  cli
  lda #0
  sta color
  sta ec
  lda #11
  sta cry
  lda #4
  sta flag
  rts

irq
  lda joy
  cmp joy
  bne irq

  sta joytmp
  cld

  lda #1
  bit joytmp
  bne noup

  lda tasave
  clc
  adc #1
  sta tasave
  sta ta
  lda tasave+1
  adc #0
  sta tasave+1
  sta ta+1
noup
  lda #2
  bit joytmp
  bne nodown

  lda tasave
  sec
  sbc #1
  sta tasave
  sta ta
  lda tasave+1
  sbc #0
  sta tasave+1
  sta ta+1
nodown
  lda flag
  bit joytmp
  bne notleft
  lda flag
  eor #12
  sta flag
  ldx color
  inx
  cpx #endcolors-colors
  bcc not9
  ldx #0
not9
  stx color
  lda colors,x
  sta ec
notleft
  lda #16
  bit joytmp
  bne nofire

  lda #199
  sta tasave
  sta ta
  lda #76
  sta tasave+1
  sta ta+1
nofire
  jmp $ea31

colors
  .byte 0,6,9,2,11,4,8,14,12,5,10,3,15,7,13,1
endcolors=*

