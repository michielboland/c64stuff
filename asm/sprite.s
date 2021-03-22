  .include "bootstrap.s"

cls = $e544
spbase = 64 * 13

  jsr cls
  sei
  lda #<nmi
  sta $fffa
  lda #>nmi
  sta $fffb
  lda #<rst
  sta $fffc
  lda #>rst
  sta $fffd
  lda #<irq
  sta $fffe
  lda #>irq
  sta $ffff
  lda #$7f
  sta $dc0d
  lda $dc0d

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
  lda #128
  sta spbase
  lda #64
  sta spbase + 1
  ldx #7
  lda #13
.l2
  sta 2040,x
  dex
  bpl .l2

  lda #$35
  sta 1
  cli

  ; Rather roundabout way to ensure IRQ routine is executed at each of the
  ; 7 possible places.
  ; There is probably something shorter but I can't be bothered right now.
.l3
  lda (0,x)
  lda (0,x)
  lda (0,x)
  lda (0,x)
  lda (0,x)
  lda (0,x)
  lda (0,x)
  clv
  bvc .l3
  brk
irq
  pha
  txa
  pha
  tya
  pha
  ldy #9
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
  pla
  tay
  pla
  tax
  pla
  ; Pad irq routine to multiple of 7 cycles.
  nop
  bit 0
  rti
nmi
  lda #$37
  sta 1
  brk
rst
  lda #$37
  sta 1
  jmp ($fffc)
vic
  .byte 24,51, 33,51, 42,51, 51, 51, 60,51, 69,51, 78,51, 87,51
  .byte 0, 27, 50, 0, 0, $ff, 8, 0, 20, 1, 1, 0, 0, 0, 0, 0
  .byte 14, 6, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1
hex
  .byte '0','1','2','3','4','5','6','7','8','9',1,2,3,4,5,6
