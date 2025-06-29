  .include "vic20bootstrap.s"

cr0 = $9000
cr1 = $9001
cr2 = $9002
cr3 = $9003
cr4 = $9004
crf = $900f

offset = 34

  .ifdef NTSC
  lda #1
  .else
  lda #5
  .endif
  sta cr0
  .ifdef NTSC
  lda #offset + 2
  .else
  lda #offset + 4
  .endif
  sta cr1
  .ifdef NTSC
  lda #25 | $80
  .else
  lda #29 | $80
  .endif
  sta cr2
  lda #17 << 1 ; add extra row for security
  sta cr3

  ; clear screen
  jsr $e55f
  sei

start:
  ldx #16
  lda #offset
not_offsetreached:
  cmp cr4
  bne not_offsetreached
at_offset:
  cmp cr4
  beq at_offset
  ; LSB of raster counter is now guaranteed to be zero
  jsr delay ; delay 62 (PAL) / 56 (NTSC) cycles
  bit cr3
  bmi .l
  bit 0
  nop
.l:
  jsr delay
  bit cr3
  bmi *+2
  bmi *+2
  jsr delay
  bit cr3
  bpl *+2

  .ifdef NTSC
  ldy #6
  .else
  ldy #41
  .endif
.l1:
  dey
  bne .l1

nextbar:
  lda colors,x
  sta crf
  .ifdef NTSC
  ldy #100
  .else
  ldy #110
  .endif
.l:
  dey
  bne .l
  nop
  nop
  .ifdef NTSC
  nop
  .endif
  dex
  bpl nextbar
  jmp start

delay:
  .ifdef NTSC
  ldy #8
  .else
  ldy #9
  .endif
.l0:
  dey
  bne .l0
  .ifdef NTSC
  bit 0
  .else
  nop
  nop
  .endif
  rts

colors:
  .byte $08,$f9,$e9,$d9,$c9,$b9,$a9,$99,$89,$79,$69,$59,$49,$39,$29,$19,$09
