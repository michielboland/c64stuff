  .include "bootstrap.s"

  lda #12
  sta 53280
  sta 53281
  lda #0
  sta 251
  sta 253
  lda #4
  sta 252
  lda #216
  sta 254
  ldx #0
l2
  ldy #39
l1
  lda #160
  sta (251),y
  txa
  sta (253),y
  dey
  bpl l1
  inx
  cpx #16
  beq end
  lda 251
  clc
  adc #40
  sta 251
  lda 252
  adc #0
  sta 252
  lda 253
  clc
  adc #40
  sta 253
  lda 254
  adc #0
  sta 254
  jmp l2
end
  .byte 2
