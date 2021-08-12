  .include "vic20bootstrap.s"

rc = $9004
ec = $900f

screen = $1e00
color_ram = $9600

space = $1200

sp = 251
cp = 253

rows = 17
columns = 24

  ldx #15
.l:
  lda #0
  sta space,x
  lda #$f0
  sta space+16,x
  lda #$ff
  sta space+32,x
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
.l:
  lda vm_data,y
  sta (sp),y
  lda color_data,y
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

  lda #10
  sta $9000 ; horizontal centering
  lda #17
  sta $9001 ; vertical centering
  lda #columns | $80
  sta $9002
  lda #rows << 1 | $01
  sta $9003 ; # rows, set 8x16 char mode
  lda #$fc
  sta $9005 ; character set starts at $1000
  lda #$80
  sta $900e ; auxiliary color

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

loop:
  nop
  nop
  nop
  nop
  nop
  lda #$19
  sta ec
  lda #$a9
  sta ec
  lda #$b9
  sta ec
  lda #$c9
  sta ec
  lda #$d9
  sta ec
  lda #$e9
  sta ec
  lda #$f9
  sta ec
  lda #$99
  sta ec
  lda #$09
  sta ec
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

vm_data:
  .byte 34,33,32,34,33,32,34,33,32,34,33,32,34,33,32,34,33,32,34,33,32,34,33,32

color_data:
  .byte 0,0,0,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8
