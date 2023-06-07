a = 251

  .include "bootstrap.s"

  sei

  lda 53265
  sta crysav
  and #$ef
  sta 53265
  lda 53280
  sta ecsav

  lda #$2f
  sta 54296
  lda #1
  sta 54295
  lda #240
  sta 54278
  lda #17
  sta 54276

  ldy #0

nextfreq

  ; wait for pop to subside
  ldx #60
.l0
  bit 53265
  bpl .l0
.l1
  bit 53265
  bmi .l1
  dex
  bne .l0

  sty 53280
  lda filtlo, y
  sta 54293
  lda filthi, y
  sta 54294

  lda #0
  sta a
  sta a + 1
  sta a + 2
  lda #1
  sta a + 3

  clc
loop

  lda a
  adc a + 2
  sta a

  lda a + 1
  adc a + 3
  sta a + 1

  lda a + 2
  adc #0
  sta a + 2
  sta 54272

  lda a + 3
  adc #0
  sta a + 3
  sta 54273

  bcc loop

  iny
  cpy #12
  bcc nextfreq

  lda crysav
  sta 53265
  lda ecsav
  sta 53280

  cli

  rts

filtlo
  .byte $04, $05, $00, $02, $00, $00, $00, $00, $00, $00, $00, $07
filthi
  .byte $00, $00, $01, $01, $02, $04, $08, $10, $20, $40, $80, $ff
crysav
  .byte 0
ecsav
  .byte 0
