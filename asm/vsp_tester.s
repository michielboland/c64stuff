; Ultimax

* = $e000

YOFFSET = 3
YBITS = %00011000

cry = 53265
rc  = 53266
bg = 11
fg = 12

  lda #fg
  sta 53281

  ldx #0
clr
  txa
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  lda #fg
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  inx
  bne clr

  lda #8
  sta 53270
  lda #((YOFFSET + 1) & 7) | YBITS
  sta cry
  lda #47
  sta rc
  lda #28
  sta 53272
  lda #fg
  sta 53280
  lda #bg
  sta 53281

  ; Wait until a complete frame has been displayed initially
  ; This way the SRAM in the VIC-II is guaranteed to contain
  ; the last line displayed (as opposed to garbage)
wait
  bit cry
  bpl *-3
  bit cry
  bmi *-3

  .macro BADLINE
  lda #((\2 + YOFFSET) & 7) | YBITS
  ldy #((\2 + \3 + YOFFSET) & 7) | YBITS
  ldx #\1 + YOFFSET
  cpx rc
  bne *-3
  sty cry
  sta cry
  .endm

  .macro IDLE
  ldx #\1 + YOFFSET
  cpx rc
  bne *-3
  bit $ffff
  lda #((\2 + YOFFSET) & 7) | YBITS
  sta cry
  .endm

  .macro VSP
  BADLINE \1, \1, \2
  IDLE \1 + 7, \1 + 2
  .endm

loop
  bit cry
  bpl *-3
  bit cry
  bmi *-3

  ; sync to raster counter for predictable results
sync
  lda rc
.l0:
  cmp rc
  beq .l0
  jsr delay
  lda rc
  cmp rc
  bne .l1
  bit 0
  nop
.l1:
  jsr delay
  lda rc
  cmp rc
  beq *+2
  beq *+2
  jsr delay
  lda rc
  cmp rc
  beq *+2

  bit 0

  jmp top

  ; each VSP block is 32 byte
  ; align to make sure we don't cross
  ; page boundaries in branch instructions

  .align 5

top
  VSP 48, 1
  VSP 57, 2
  VSP 66, 3
  VSP 75, 4
  VSP 84, 5
  VSP 93, 6
  VSP 102, 7
  VSP 111, 1
  VSP 120, 2
  VSP 129, 3
  VSP 138, 4
  VSP 147, 5
  VSP 156, 6
  VSP 165, 7
  VSP 174, 1
  VSP 183, 2
  VSP 192, 3
  VSP 201, 4
  VSP 210, 5
  VSP 219, 6
  VSP 228, 7
  VSP 237, 1
  .if YOFFSET < 3
  VSP 246, 2
  .endif
  lda #((YOFFSET + 1) & 7) | YBITS
  sta cry

  jmp loop

  .align 3
delay
  ldy #7
.l0
  dey
  bne .l0
  nop
  rts

* = $f000
  .include "binary_charset.s"

* = $f800

  .macro B7
  .byte 0,0,0,0,0,0,0,\1
  .endm

  B7 %00000001
  B7 %00000010
  B7 %00000100
  B7 %00001000
  B7 %00010000
  B7 %00100000
  B7 %01000000
  B7 %10000000

  B7 %00000011
  B7 %00000110
  B7 %00001100
  B7 %00011000
  B7 %00110000
  B7 %01100000
  B7 %11000000
  B7 %10000001

  B7 %00000111
  B7 %00001110
  B7 %00011100
  B7 %00111000
  B7 %01110000
  B7 %11100000
  B7 %11000001
  B7 %10000011

  B7 %00001111
  B7 %00011110
  B7 %00111100
  B7 %01111000
  B7 %11110000
  B7 %11100001
  B7 %11000011
  B7 %10000111

* = $fffa

  .word $e000
  .word $e000
  .word $e000

