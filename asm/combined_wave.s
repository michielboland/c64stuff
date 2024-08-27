
viccry = 53265

sid  = $d400
f3   = sid + 14
w3   = sid + 18
o3   = sid + 27

triangle = 0x10
sawtooth = 0x20
pulse    = 0x40

reu_command  = $df01
reu_c64base  = $df02
reu_reubase  = $df04
reu_translen = $df07
reu_control  = $df0a

  .include "bootstrap.s"

  lda #0
  sta f3
  lda #1
  sta f3 + 1

  jsr screen_off

  ldx # triangle
  ldy #0
  jsr sample

  ldx # sawtooth
  iny
  jsr sample

  ldx # triangle | sawtooth
  iny
  jsr sample

  ldx # triangle | pulse
  iny
  jsr sample

  ldx # sawtooth | pulse
  iny
  jsr sample

  ldx # triangle | sawtooth | pulse
  iny
  jsr sample

  ldx # pulse
  iny
  jsr sample

  ldx # 0
  iny
  jsr sample

  jmp screen_on

  ; x:waveform
  ; y:REU bank
sample
  lda #8
  sta w3

  lda #$80 ; fix C64 address
  sta reu_control
  lda #<o3
  sta reu_c64base
  lda #>o3
  sta reu_c64base + 1
  lda #0
  sta reu_reubase
  sta reu_reubase + 1
  sty reu_reubase + 2
  sta reu_translen
  sta reu_translen + 1

  lda #%10010000 ; c64 -> REU with immediate execution
  stx w3
  sta reu_command
  lda #0
  sta w3
  rts

screen_off
  lda viccry
  bpl screen_off
  lda #11
  sta viccry
  rts

screen_on
  lda #27
  sta viccry
  rts

clear_sid
  ldx #24
  lda #0
.l0
  sta sid, x
  dex
  bpl .l0
  rts
