  .include "bootstrap.s"

spbase = 64 * 13

  sei
  lda #$7f
  sta $dc0d
  lda $dc0d
  lda #<irq
  sta $0314
  lda #>irq
  sta $0315

  ldx #46
.l0
  lda vic,x
  sta $d000,x
  dex
  bpl .l0
  lda #0
  ldx #61
.l1
  sta spbase + 1,x
  dex
  bne .l1
  lda #%10110110
  sta spbase
  sta spbase + 1
  ldx #7
  lda #13
.l2
  sta 2040,x
  dex
  bpl .l2

  cli

  rts

irq
  ldy #6
.l0
  dey
  bpl .l0
  nop
  lda $d01e
  lda $d01e
  tay
  lsr a
  lsr a
  lsr a
  lsr a
  tax
  lda hex,x
  pha
  tya
  and #$f
  tax
  lda hex,x
  sta 1065,y
  pla
  sta 1064,y
  lda #1
  sta $d019
  jmp $ea31
vic
  .byte 28,51, 36,51, 44,51, 52,51, 60,51, 68,51, 76,51, 84,51
  .byte 0, 27, 50, 0, 0, $ff, 8, 0, 20, 1, 1, 0, 0, 0, 0, 0
  .byte 14, 6, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1
hex
  .byte '0','1','2','3','4','5','6','7','8','9',1,2,3,4,5,6
