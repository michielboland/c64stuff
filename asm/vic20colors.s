  .include "vic20bootstrap.s"

rc = $9004
ec = $900f
offset = 34

  ; clear screen
  jsr $e55f
  sei

start:
  ldx #16
  lda #offset
not_offsetreached:
  cmp rc
  bne not_offsetreached
  lda rc
not_nextline:
  cmp rc
  beq not_nextline
  jsr delay
  lda rc
  cmp rc
  bne .l
  bit 0
  nop
.l:
  jsr delay
  lda rc
  cmp rc
  beq *+2
  beq *+2
  jsr delay
  lda rc
  cmp rc
  beq *+2

nextbar:
  lda colors,x
  sta ec
  ldy #110
.l:
  dey
  bne .l
  nop
  nop
  dex
  bpl nextbar
  jmp start

delay:
  ldy #22
.l0:
  dey
  bne .l0
  nop
  nop
  nop
  rts

colors:
  .byte $08,$19,$f9,$b9,$d9,$79,$99,$c9,$39,$a9,$e9,$59,$89,$49,$29,$69,$09
