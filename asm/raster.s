  .include "bootstrap.s"

viccry   = $d011
vicrc    = $d012
viclpx   = $d013
vicec    = $d020
cia1ddrb = $dc03

  sei
  lda #$0b
  sta viccry
rasneg
  bit viccry
  bmi rasneg
raspos
  bit viccry
  bpl raspos
  nop
  nop
  lda #$10
  sta cia1ddrb
  lda #0
  sta cia1ddrb
  ldy #2
delay
  dey
  bne delay
  lda viclpx
  sec
  sbc #2
  lsr
  lsr
  eor #7
  lsr
  bcs *+2
  lsr
  bcs *+2
  bcs *+2
  lsr
  bcc loop
  bit 0
  nop
loop
  .ifdef NTSC
  nop
  .endif
  lda vicrc
  sta vicec ; color register update should coincide with end of hblank
  .rept 26
  nop
  .endr
  jmp loop
