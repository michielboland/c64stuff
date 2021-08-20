  .include "vic20bootstrap.s"

rc = $9004

screen = $1e00
color_ram = $9600
p = 251
q = 253

  jmp start

register
  .byte 4
line
  .byte 151
color
  .byte 6
cycles
  .word 505

start
  lda #8
  sta $900f

  sei

init
  lda #0
  sta offset
  sta offset+1
  sta p
  sta q
  lda #>screen
  sta p+1
  lda #>color_ram
  sta q+1

loop
  lda line
notras
  cmp rc
  bne notras
ras
  cmp rc
  beq ras
  jsr delay
  bit $9003
  bmi skip4a
  bit 0
  nop
skip4a
  jsr delay
  bit $9003
  bmi *+2
  bmi *+2
  jsr delay
  bit $9003
  bpl *+2

  lda offset+1
  sta tmp
  ldy offset
  tya
  lsr tmp
  ror
  lsr tmp
  ror
  lsr tmp
  ror
  tax
  inx
delay8
  bit 0
  dex
  bpl delay8
  tya
  lsr
  bcs *+2
  lsr
  bcs *+2
  bcs *+2
  lsr
  bcc skip4b
  bit 0
  nop
skip4b
  ldx register
  lda $9000,x
  sta (p),y
  lda color
  sta (q),y
  eor #4
  sta color
  iny
  sty offset
  bne compare
  inc p+1
  inc q+1
  inc offset+1
compare
  cpy cycles
  bcc next
  lda offset+1
  sbc cycles+1
  bcs reset
next
  jmp loop
reset
  jmp init

delay
  ldy #9
.l
  dey
  bne .l
  nop
  nop
  rts

offset = *
tmp = * + 2
