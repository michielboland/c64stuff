  .include "bootstrap.s"

vicec    = 53280
vicbc    = 53281

  lda #1
  sta vicec
  sta vicbc
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
  lda line,y
  sta (253),y
  dey
  bpl l1
  inx
  cpx #25
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
  beq end

  .macro BAR
    .rept 5
    .byte \1
    .endr
  .endm

line
  BAR 13
  BAR 15
  BAR 5
  BAR 12
  BAR 8
  BAR 11
  BAR 9
  BAR 0
