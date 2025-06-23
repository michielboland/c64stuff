  .include "bootstrap.s"

cls = $e544
row = 12
scrbase = 1024
colbase = 55296

  lda #255
  sta 53269
  lda #203
  ldx #15
  sec
.l0
  sta 53248, x
  sbc #21
  dex
  dex
  bpl .l0
  lda #12
  sta 53280
  sta 53281
  jsr cls
  lda #101
  sta scrbase + 40 * row
  lda #103
  sta scrbase + 40 * row + 39
  lda #11
  sta colbase + 40 * row
  sta colbase + 40 * row + 39
  .byte 2
