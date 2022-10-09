  .include "vic20bootstrap.s"

cr0 = $9000
cr1 = $9001
cr2 = $9002
cr3 = $9003
cr4 = $9004
crF = $900f

offset = 30

  .macro FIRST
  sta crF
  .rept 18
  nop
  .endr

  sty crF
  .rept 6
  nop
  .endr

  .endm

  .macro SECOND
  sta crF
  .rept 12
  nop
  .endr

  sty crF
  .rept 4
  nop
  .endr

  sta crF
  .rept 4
  nop
  .endr

  sty crF
  .endm

  .macro DELAY11
  bit 0
  nop
  nop
  nop
  nop
  nop
  nop
  .endm

init:
  lda #13
  sta cr0
  lda #offset+3
  sta cr1
  lda #$95
  sta cr2
  lda #$30
  sta cr3

  ; clear screen
  jsr $e55f
  sei

start:

  lda #offset
not_offsetreached:
  cmp cr4
  bne not_offsetreached
not_nextline:
  cmp cr4
  beq not_nextline
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

  ldx #9
.l2
  dex
  bpl .l2
  nop
  nop

  ldx #24

nextbar:
  lda colors_left,x
  ldy colors_right,x

  FIRST
  DELAY11
  SECOND
  DELAY11

  FIRST
  DELAY11
  SECOND
  DELAY11

  FIRST
  DELAY11
  SECOND
  DELAY11

  FIRST
  DELAY11
  SECOND

  dex
  bmi js
  jmp nextbar
js:
  jmp start

  .align 3

delay:
  ldy #9
.l:
  dey
  bne .l
  nop
  nop
  rts

  .align 5
colors_left:
  .byte $08,$68,$28,$48,$88,$58,$e8,$a8,$38,$c8,$c8,$98,$98,$98,$78,$78,$d8,$d8,$d8,$b8,$b8,$f8,$f8,$f8,$18

  .align 5
colors_right:
  .byte $08,$08,$68,$28,$48,$88,$58,$e8,$a8,$a8,$38,$a8,$38,$c8,$c8,$98,$c8,$98,$78,$78,$d8,$78,$d8,$b8,$f8

