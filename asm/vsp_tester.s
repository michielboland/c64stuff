; Ultimax

* = $e000

YOFFSET = 0
YBITS = %01011000

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
  lda #15
  sta 53280
  lda #0
  sta 53281
  lda #7
  sta 53282
  lda #8
  sta 53283
  lda #9
  sta 53284
  

  .macro DELAY
  .rept 1
  nop
  .endr
  .endm

  .macro BADLINE
  lda #\1 + YOFFSET
  cmp 53266
  bne *-3
  DELAY
  lda #((\2 + YOFFSET) & 7) | YBITS
  ldy #((\2 + \3 + YOFFSET) & 7) | YBITS | 32
  sty 53265
  sta 53281
  sta 53265
  .endm

  .macro IDLE
  lda #\1 + YOFFSET
  cmp 53266
  bne *-3
  DELAY
  lda #((\2 + YOFFSET) & 7) | YBITS
  sta 53265
  .endm

  .macro VSP
  BADLINE \1, \1, \2
  IDLE \1 + 7, \1 + 2
  .endm

loop

  bit 53265
  bpl *-3
  bit 53265
  bmi *-3

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
  BADLINE 246, 6, 2

  jmp loop

* = $f000
  .include "binary_charset.s"

* = $ff00

  jmp $e000

* = $fffa

  .word $ff00
  .word $ff00
  .word $ff00

