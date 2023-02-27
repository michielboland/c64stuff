; 8K cartridge

* = $8000

YOFFSET = 3
YBITS = %00011000

cry = 53265
rc  = 53266
bg = 11
fg = 12

  .word coldboot
  .word warmboot
  .byte $c3, $c2, $cd, $38, $30 ; CBM80

coldboot
  jsr $fd15 ; make restore work properly
  lda #$03
  sta $dd00
  sta $dd02
  cld
  ldx #0
  lda #fg
clrcolor
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  inx
  bne clrcolor

vicehack
  lda $8000,x
  sta $8000,x
  lda $8100,x
  sta $8100,x
  lda $8200,x
  sta $8200,x
  lda $8300,x
  sta $8300,x
  inx
  bne vicehack

  ; make sure stack does not use vulnerable memory
  ldx #$fe
  txs

warmboot
  lda #fg
  sta 53281

  ldx #0
  lda #' '
clr
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  inx
  bne clr

  ldy #31
fill
  tya
  asl a
  asl a
  asl a
  adc #7
  tax
  lda idle_data,y
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  sta $3800,x
  dey
  bpl fill

  lda #0
  sta $3fff

  lda #8
  sta 53270
  lda #((YOFFSET + 1) & 7) | YBITS
  sta cry
  lda #22
  sta 53272
  lda #fg
  sta 53280
  lda #bg
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
  lda #((\1 + YOFFSET) & 7) | YBITS
  .if \2 == 0
  ; VSP via DEN toggle
  ldy #((\1 + YOFFSET) & 7) | (YBITS & ~16)
  .else
  ldy #((\1 + \2 + YOFFSET) & 7) | YBITS
  .endif
  ldx #\1 + YOFFSET
  cpx rc
  bne *-3
  sty cry
  sta cry
  .endm

  .macro IDLE
  ldx #\1 + YOFFSET
  cpx rc
  bne *-3
  bit $ffff
  lda #((\2 + YOFFSET) & 7) | YBITS
  sta cry
  .endm

  .macro VSP
  BADLINE \1, \2
  IDLE \1 + 7, \1 + 2
  .endm

loop
  bit cry
  bpl *-3

  ; generate some grey dots
  lda 53281
  .rept 6
  sta 53281
  .endr

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

  bit 0

  jmp top

  ; each VSP block is 32 byte
  ; align to make sure we don't cross
  ; page boundaries in branch instructions

  .align 5

top
  .if YOFFSET = 7
  ; Hack to make sure badline does not get triggered early
  ; Alignment slightly off now but that does not matter
  ldx #52
  cpx rc
  bne *-3
  lda #1|YBITS
  sta cry
  bit 0
  nop
  nop
  .endif
  .if YOFFSET = 0
  VSP 48, 0
  .else
  VSP 48, 1
  .endif
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
  .if YOFFSET < 3
  VSP 237, 1
  BADLINE 246, 2
  .else
  BADLINE 237,1
  .endif
  ldx #250
  cpx rc
  bne *-3
  ; Prepare for first badline at top of screen
  ; Also open top/bottom border to make things visible
  ; if YOFFSET is not 3
  .if YOFFSET == 0
  lda #0
  .else
  .if YOFFSET == 7
  lda #7 | (YBITS & ~8)
  .else
  lda #((YOFFSET + 1) & 7) | (YBITS & ~8)
  .endif
  .endif
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

  .align 5
idle_data
  .byte %00000001
  .byte %00000010
  .byte %00000100
  .byte %00001000
  .byte %00010000
  .byte %00100000
  .byte %01000000
  .byte %10000000

  .byte %00000011
  .byte %00000110
  .byte %00001100
  .byte %00011000
  .byte %00110000
  .byte %01100000
  .byte %11000000
  .byte %10000001

  .byte %00000111
  .byte %00001110
  .byte %00011100
  .byte %00111000
  .byte %01110000
  .byte %11100000
  .byte %11000001
  .byte %10000011

  .byte %00001111
  .byte %00011110
  .byte %00111100
  .byte %01111000
  .byte %11110000
  .byte %11100001
  .byte %11000011
  .byte %10000111

* = $9fff

  .byte 0
