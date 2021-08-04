  .include "vic20bootstrap.s"

hcenter = $9000
vcenter = $9001
cols = $9002
rows = $9003
rc = $9004
mp = $9005
ec = $900f
offset = 34

  ; clear screen
  jsr $e55f

  lda #8
  sta hcenter
  lda #16
  sta vcenter
  lda #35
  sta rows
  lda #154
  sta cols
  lda #$fc
  sta mp

  sei

rc_notzero:
  ; Wait until raster is zero
  lda rc
  bne rc_notzero
rc_zero:
  cmp rc
  beq rc_zero
  ; LSB of raster counter is now guaranteed to be zero
  jsr delay ; delay 62 cycles
  bit rows
  bmi .l
  bit 0
  nop
.l:
  jsr delay
  bit rows
  bmi *+2
  bmi *+2
  jsr delay
  bit rows
  bpl *+2

loop:
  nop
  nop
  nop
  nop
  lda #$88
  sta ec
  lda #$98
  sta ec
  lda #$a8
  sta ec
  lda #$b8
  sta ec
  lda #$c8
  sta ec
  lda #$d8
  sta ec
  lda #$e8
  sta ec
  lda #$f8
  sta ec
  lda #$09
  sta ec
  nop
  nop
  nop
  jmp loop

delay:
  ldy #9
.l:
  dey
  bne .l
  nop
  nop
  rts

  *=$1200
  .rept 16
  .byte 0
  .endr
