; Ultimax

* = $e000

YOFFSET = 0

  lda #128
  sta 54290
  sta 54287

  ldx #0
  lda #1
clr
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  inx
  bne clr
  inx
clr2
  lda 54299
  .byte $9d,1,0 ; sta $0001,x
  sta $0100,x
  sta $01ff,x
  sta $02fe,x
  sta $03fd,x
  sta $04fc,x
  sta $05fb,x
  sta $06fa,x
  sta $07f9,x
  sta $08f8,x
  sta $09f7,x
  sta $0af6,x
  sta $0bf5,x
  sta $0cf4,x
  sta $0df3,x
  sta $0ef2,x
  sta $0ff1,x
  inx
  bne clr2
  lda #8
  sta 53270
  lda #25
  sta 53265
  lda #47
  sta 53266
  lda #28
  sta 53272
  lda #14
  sta 53280
  lda #6
  sta 53281
  lda #7
  sta 53283
  lda #8
  sta 53284

  .macro DELAY
  .rept 6
  nop
  .endr
  .endm

  .macro SETY
  lda #\1 + YOFFSET
  cmp 53266
  bne *-3
  DELAY
  lda #((\2 + YOFFSET) & 7) | %01011000
  sta 53282
  sta 53265
  .endm

loop

  bit 53265
  bpl *-3
  bit 53265
  bmi *-3

  SETY 48, 0
  SETY 55, 2
  SETY 57, 1
  SETY 64, 3
  SETY 66, 2
  SETY 73, 4
  SETY 75, 3
  SETY 82, 5
  SETY 84, 4
  SETY 91, 6
  SETY 93, 5
  SETY 100, 7
  SETY 102, 6
  SETY 109, 0
  SETY 111, 7
  SETY 118, 1
  SETY 120, 0
  SETY 127, 2
  SETY 129, 1
  SETY 136, 3
  SETY 138, 2
  SETY 145, 4
  SETY 147, 3
  SETY 154, 5
  SETY 156, 4
  SETY 163, 6
  SETY 165, 5
  SETY 172, 7
  SETY 174, 6
  SETY 181, 0
  SETY 183, 7
  SETY 190, 1
  SETY 192, 0
  SETY 199, 2
  SETY 201, 1
  SETY 208, 3
  SETY 210, 2
  SETY 217, 4
  SETY 219, 3
  SETY 226, 5
  SETY 228, 4
  SETY 235, 6
  SETY 237, 5
  SETY 244, 7
  SETY 246, 6

  jmp loop

* = $f000
  .include "binary_charset.s"

* = $ff00

  jmp $e000

* = $fffa

  .word $ff00
  .word $ff00
  .word $ff00

