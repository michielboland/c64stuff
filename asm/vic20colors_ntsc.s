  .include "vic20bootstrap.s"

rc = $9004
ec = $900f
offset = 34

  lda #2
  sta $9000
  lda #$98
  sta $9002

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
  .byte $08,$f9,$e9,$d9,$c9,$b9,$a9,$99,$89,$79,$69,$59,$49,$39,$29,$19,$09
