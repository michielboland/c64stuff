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
at_offset:
  cmp rc
  beq at_offset
  ; LSB of raster counter is now guaranteed to be zero
  jsr delay ; delay 62 cycles
  bit $9003
  bmi .l
  bit 0
  nop
.l:
  jsr delay
  bit $9003
  bmi *+2
  bmi *+2
  jsr delay
  bit $9003
  bpl *+2

  .rept 16
  nop
  .endr

nextbar:
  lda colors,x
  sta ec
  ldy #100
.l:
  dey
  bne .l
  nop
  nop
  nop
  dex
  bpl nextbar
  jmp start

delay:
  ldy #8
.l:
  dey
  bne .l
  bit 0
  rts

colors:
  .byte $08,$19,$f9,$b9,$d9,$79,$99,$c9,$39,$a9,$e9,$59,$89,$49,$29,$69,$09
