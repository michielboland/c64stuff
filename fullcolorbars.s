  .include "bootstrap.s"

viccry   = $d011
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
  nop
  lda #1
  sta vicec
  nop
  lda #13
  sta vicec
  lda #15
  sta vicec
  lda #5
  sta vicec
  lda #12
  sta vicec
  lda #8
  sta vicec
  lda #11
  sta vicec
  lda #9
  sta vicec
  nop
  nop
  nop
  nop
  jmp loop
