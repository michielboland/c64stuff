  .include "bootstrap.s"

viccry   = $d011
vicrc    = $d012
viclpx   = $d013
vicec    = $d020
cia1ddrb = $dc03

  sei
  lda #$0b
  sta viccry
.l0
  lda vicrc
  bne .l0
  lda vicrc
.l1
  cmp vicrc
  beq .l1
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

loop
  lda vicrc
  sta vicec ; color register update should coincide with end of hblank
  .ifdef NTSC
  nop
  .endif
  .rept 26
  nop
  .endr
  jmp loop

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
