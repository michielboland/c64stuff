  .include "bootstrap.s"

vmatrix_ptr = 251
bitmap_ptr  = vmatrix_ptr
tmp         = 253
row_counter = 254

vmatrix = $0400
bitmap  = $2000

getin = $ffe4

stop      = $03
crsr_left = $9D
crsr_rght = $1D

main
  lda #$37
  sta 53265
  lda #$1C
  sta 53272
  lda #0
  sta 53280
  jsr init_bitmap
  jsr init_line
.l3
  jsr build_screen
.l0
  jsr getin
  cmp #0
  beq .l0
  cmp #stop
  bne .l1
  rts
.l1
  cmp #crsr_left
  bne .l2
  ldx offset
  beq .l0
  dex
.l4
  stx offset
  jmp .l3
.l2
  cmp #crsr_rght
  bne .l0
  ldx offset
  cpx #12
  beq .l0
  inx
  jmp .l4

init_bitmap
  lda #<bitmap
  sta bitmap_ptr
  lda #>bitmap
  sta bitmap_ptr+1
  ldy #0
  ldx #32
.l0
  lda #0
  sta (bitmap_ptr), y
  iny
  lda #255
  sta (bitmap_ptr), y
  iny
  bne .l0
  inc bitmap_ptr+1
  dex
  bne .l0
  rts

init_line
  ldy #39
  lda #$11
.l0
  sta line, y
  dey
  bpl .l0
  rts

build_line
  stx column
  sty row
  lda colors, y
  .rept 4
  asl a
  .endr
  sta tmp
  ldy #0
.l0
  lda colors, x
  ora tmp
  sta cells, y
  inx
  iny
  cpy #6
  bne .l0
  ldy #0
  ldx #8
.l2
  lda cells, y
  sty tmp
  ldy #4
.l1
  sta line, x
  inx
  dey
  bne .l1
  ldy tmp
  iny
  cpy #6
  bne .l2
  rts

build_screen
  lda #<vmatrix
  sta vmatrix_ptr
  lda #>vmatrix
  sta vmatrix_ptr+1
  lda #0
  sta row_counter
.l2
  lsr a
  lsr a
  clc
  adc offset
  tay
  ldx offset
  jsr build_line
  ldy #39
.l0
  lda line, y
  sta (vmatrix_ptr), y
  dey
  bpl .l0
  lda vmatrix_ptr
  clc
  adc #40
  sta vmatrix_ptr
  bcc .l1
  inc vmatrix_ptr+1
.l1
  inc row_counter
  lda row_counter
  cmp #24
  bne .l2
  rts

colors
  .byte 0, 0, 6, 9, 2, 11, 4, 8, 12, 14, 5, 10, 3, 15, 7, 13, 1, 1

offset
  .byte 0
column = *
row    = column + 1
cells  = row + 1
line   = cells + 6
