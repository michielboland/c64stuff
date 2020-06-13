  .include "bootstrap.s"

  lda #0
  sta 251
  lda #32
  sta 252
  ldy #0
  ldx #32
l1
  lda #0
  sta (251), y
  iny
  lda #255
  sta (251), y
  iny
  bne l1
  inc 252
  dex
  bpl l1
  ldy #0
  lda #$cc
l2
  sta $0400, y
  sta $0500, y
  sta $0600, y
  sta $0700, y
  iny
  bne l2
  lda #4
  sta 252
  ldx #0
l4
  txa
  sta (251), y
  iny
  sta (251), y
  iny
  bne l3
  inc 252
l3
  inx
  beq l5
  txa
  and #15
  bne l4
  tya
  clc
  adc #8
  tay
  lda 252
  adc #0
  sta 252
  bne l4
l5
  lda #12
  sta 53280
  lda #59
  sta 53265
  lda #24
  sta 53272
l6
  bne l6
