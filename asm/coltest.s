  .include "bootstrap.s"

irqvec = $0314

  sei
  lda #127
  sta 56333
  lda 56333
  lda #1
  sta 53274
  sta 53273
  lda #24
  sta 53266
  lda #27
  sta 53265
  lda #<isr
  sta irqvec
  lda #>isr
  sta irqvec+1
  lda #23
  sta x
  lda #20
  sta y
  lda #0
  tax
clrsprite
  sta $0340, x
  inx
  cpx #62
  bcc clrsprite
  lda #1
  sta $0340, x
  cli
  rts

isr
  lda #1
  sta 53273
  ldx y
  lda poslo, x
  sta 251
  lda poshi, x
  sta 252
  ldy x
  lda (251), y
  ldx 53278
  beq nocol
  ora #128
  bne update_screen
nocol
  and #127
update_screen
  sta (251), y
  lda 252
  clc
  adc #212
  sta 252
  lda #1
  sta (251), y
  jsr toggle_sprite_pixel
  ldx x
  ldy y
  inx
  cpx #24
  bcc updatexy
  ldx #0
  iny
  cpy #21
  bcc updatexy
  ldy #0
updatexy
  stx x
  sty y
  jsr toggle_sprite_pixel
  jmp $ea31

toggle_sprite_pixel
  ldx y
  lda sposlo, x
  sta 251
  lda #3
  sta 252
  lda x
  tax
  lsr
  lsr
  lsr
  tay
  txa
  and #7
  tax
  lda (251), y
  eor bits, x
  sta (251), y
  rts

x
  .byte 0
y
  .byte 0

poslo
  .byte 0, 40, 80, 120, 160, 200, 240, 24, 64, 104, 144, 184, 224
  .byte 8, 48, 88, 128, 168, 208, 248, 32

poshi
  .byte 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 7

sposlo
  .byte 64, 67, 70, 73, 76, 79, 82, 85, 88, 91, 94, 97, 100, 103
  .byte 106, 109, 112, 115, 118, 121, 124

bits
  .byte 128, 64, 32, 16, 8, 4, 2, 1
