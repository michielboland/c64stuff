
  ; ass.bc - Michiel Boland
  ; 2020-04-03


irqvec    = $0314
joy       = $dc00
ta        = $dc04
cry       = 53265
ec        = 53280
tadefault = 19655

  .include "bootstrap.s"

  sei
  lda tasave
  sta ta
  lda tasave+1
  sta ta+1
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1
  cli
  lda color
  sta ec
  lda #11
  sta cry
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
  lda #4
  bit joytmp
  bne noleft
  lda #0
  sta colorinc
noleft
  lda #8
  bit joytmp
  bne noright
  lda colorinc
  bne noright
  lda #1
  sta colorinc
  ldx color
  inx
  stx color
  stx ec
noright
  lda #16
  bit joytmp
  bne nofire

  lda #<tadefault
  sta tasave
  sta ta
  lda #>tadefault
  sta tasave+1
  sta ta+1
nofire
  jmp $ea31

color
  .byte 0
colorinc
  .byte 0
joytmp
  .byte 0
tasave
  .word tadefault
