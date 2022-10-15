; Ultimax

* = $e000

YOFFSET = 3
YBITS = %00011000

cry = 53265
rc  = 53266

  lda #14
  sta 53281

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
  sta cry
  lda #47
  sta rc
  lda #28
  sta 53272
  lda #14
  sta 53280
  lda #6
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
  lda #\1 + YOFFSET
  cmp rc
  bne *-3
  nop
  nop
  nop
  lda #((\2 + YOFFSET) & 7) | YBITS
  ldy #((\2 + \3 + YOFFSET) & 7) | YBITS
  sty cry
  sta cry
  .endm

  .macro IDLE
  lda #\1 + YOFFSET
  cmp rc
  bne *-3
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

* = $fffa

  .word $e000
  .word $e000
  .word $e000

