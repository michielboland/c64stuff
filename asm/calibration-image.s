  .include "bootstrap.s"

viccry = 53265
vicrc  = 53266
vicec  = 53280
vicbc  = 53281

start
  sei

  ; reset VIC-II idle data
  lda #0
  sta 16383

  ; avoid badline at top of screen
  lda #11
  sta viccry

  ; raster will be 251 when we are at the 'bottom' label
  lda #246
.l0
  cmp vicrc
  bne .l0
.l1
  cmp vicrc
  beq .l1

  ; sync to raster
  jsr delay
  lda vicrc
  cmp vicrc
  bne .l2
  bit 0
  nop
.l2
  jsr delay
  lda vicrc
  cmp vicrc
  beq *+2
  beq *+2
  jsr delay
  lda vicrc
  cmp vicrc
  beq *+2

  lda #14
  ldx #6

  ; align horizontally
  ldy #10
.l3
  dey
  bne .l3
  .ifdef NTSC
  nop
  .endif

bottom
  .rept 4
  nop
  .endr
  sta vicec
  .rept 13
  nop
  .endr
  stx vicec
  .rept 8
  nop
  .endr
  bit 0
  .ifdef NTSC
  nop
  ldy #62
  .else
  ldy #111
  .endif

bottom_loop
  .rept 4
  nop
  .endr
  sta vicec
  .rept 13
  nop
  .endr
  stx vicec
  .rept 7
  nop
  .endr
  .ifdef NTSC
  nop
  .endif
  dey
  beq .l0
  bne bottom_loop
.l0
  nop

top
  ldy #27
  sty viccry
  ldy #11
  sta vicec
  stx vicbc
  sty viccry
  .rept 9
  nop
  .endr
  sta vicbc
  stx vicec
  .rept 6
  nop
  .endr
  .ifdef NTSC
  nop
  .endif
  bit 0
  ldy #199

top_loop
  .rept 4
  nop
  .endr
  sta vicec
  stx vicbc
  .rept 11
  nop
  .endr
  sta vicbc
  stx vicec
  nop
  nop
  nop
  .ifdef NTSC
  nop
  .endif
  dey
  beq .l0
  nop
  nop
  bne top_loop
.l0
  bit 0
  jmp bottom

delay
  ldy #7
.l0
  dey
  bne .l0
  .ifdef NTSC
  nop
  .endif
  nop
  rts
