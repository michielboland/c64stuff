  .include "bootstrap.s"

; on 6569R1 this will display two 8-character wide bars in the top row
; with the contents of $3fff between them
;
; ..********...**...********

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
  lda #0
  sta x
  ldx #62
clrsprite
  sta $0340, x
  dex
  bne clrsprite
  lda #128
  sta $0340
  lda #13
  sta 2046
  sta 2047
  ldx #98
  stx 53260
  stx 53261
  inx
  stx 53262
  stx 53263
  lda #192
  sta 53264
  sta 53269
  lda #24
  sta 16383
  bit 53278
  cli
  rts

isr
  lda #1
  sta 53273
  ldx x
  lda $0400, x
  ldy 53278
  beq nocol
  ora #128
  bne update_screen
nocol
  and #127
update_screen
  sta $0400, x
  lda #1
  sta $d800, x
  jsr toggle_sprite_pixel
  ldx x
  inx
  cpx #24
  bcc updatex
  ldx #0
updatex
  stx x
  jsr toggle_sprite_pixel
  jmp $ea31

toggle_sprite_pixel
  lda x
  tax
  lsr
  lsr
  lsr
  tay
  txa
  and #7
  tax
  lda $0340, y
  eor bits, x
  sta $0340, y
  rts

x
  .byte 0

bits
  .byte 128, 64, 32, 16, 8, 4, 2, 1
