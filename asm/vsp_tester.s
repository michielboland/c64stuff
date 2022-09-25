; Ultimax

* = $e000

YOFFSET = 3
YBITS = %00011000

  ldx #0
clr
  txa
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  lda #14
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  inx
  bne clr
  lda #8
  sta 53270
  lda #((YOFFSET + 1) & 7) | YBITS
  sta 53265
  lda #47
  sta 53266
  lda #28
  sta 53272
  lda #14
  sta 53280
  lda #6
  sta 53281

  .macro DELAY
  .rept 4
  nop
  .endr
  .endm

  .macro BADLINE
  lda #\1 + YOFFSET
  cmp 53266
  bne *-3
  DELAY
  lda #((\2 + YOFFSET) & 7) | YBITS
  ldy #((\2 + \3 + YOFFSET) & 7) | YBITS
  sty 53265
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
  .if YOFFSET < 3
  VSP 246, 2
  .endif
  lda #((YOFFSET + 1) & 7) | YBITS
  sta 53265

  jmp loop

* = $f000
  .include "binary_charset.s"

* = $fffa

  .word $e000
  .word $e000
  .word $e000

