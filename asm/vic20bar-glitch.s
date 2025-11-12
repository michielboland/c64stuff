  .include "vic20bootstrap.s"

cr0 = $9000
cr1 = $9001
cr2 = $9002
cr3 = $9003
cr4 = $9004
cr5 = $9005
crf = $900f

screen = $1e00
color_ram = $9600

glyph = $1200

sp = 251
cp = 253

  .ifdef NTSC
rows = 8
columns = 25
  .else
rows = 10
columns = 30
  .endif

  ldx #15
.l:
  lda glyph_def,x
  sta glyph,x
  dex
  bpl .l

  lda #<screen
  sta sp
  lda #>screen
  sta sp+1
  lda #<color_ram
  sta cp
  lda #>color_ram
  sta cp+1
  ldx #rows

do_row:
  ldy #columns-1
  lda #32
.l:
  sta (sp),y
  sta (cp),y
  dey
  bpl .l
  lda sp
  clc
  adc #columns
  sta sp
  lda sp+1
  adc #0
  sta sp+1
  lda cp
  clc
  adc #columns
  sta cp
  lda cp+1
  adc #0
  sta cp+1
  dex
  bne do_row

  ldx #$18 ; pre-load base colour since there is no time to do this later

  .ifdef NTSC
  lda #$1
  .else
  lda #4
  .endif
  sta cr0 ; horizontal centering
  lda #5
  sta cr1 ; vertical centering
  lda #columns | $80
  sta cr2
  lda #rows << 1 | $01
  sta cr3 ; # rows, set 8x16 char mode
  lda #$fc
  sta cr5 ; character set starts at $1000

  sei

rc_notzero:
  ; Wait until raster is zero
  lda cr4
  bne rc_notzero
rc_zero:
  cmp cr4
  beq rc_zero
  ; LSB of raster counter is now guaranteed to be zero
  jsr delay ; delay 62 cycles
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
  .rept 18
  nop
  .endr
  bit 0
  .else
  nop
  bit 0
  .endif

loop:
  lda #$8e ; 2
  sta crf  ; 6
  stx crf  ; 10
  lda #$aa ; 12
  sta crf  ; 16
  stx crf  ; 20
  lda #$c4 ; 22
  sta crf  ; 26
  stx crf  ; 30
  lda #$9d ; 32
  sta crf  ; 36
  stx crf  ; 40
  lda #$fb ; 42
  sta crf  ; 36
  stx crf  ; 50
  lda #$ef ; 52 ; secret column (ntsc)
  sta crf  ; 55
  stx crf  ; 60
  nop      ; 62
  .ifndef NTSC
  nop      ; 64
  nop      ; 66
  nop      ; 68
  .endif
  jmp loop ; 65 / 71

delay:
  .ifdef NTSC
  ldy #8
  .else
  ldy #9
  .endif
.l:
  dey
  bne .l
  .ifdef NTSC
  bit 0
  .else
  nop
  nop
  .endif
  rts

glyph_def
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00001100
  .byte %00001000
  .byte %00000100
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
