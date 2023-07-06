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
  lda #9
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

  lda #17
  sta 54276

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

  lda #9
  sta 54276

  iny
  cpy #36
  bcc nextfreq

  lda crysav
  sta 53265
  lda ecsav
  sta 53280

  lda #0
  sta 54276

  cli

  rts

filtlo
  .byte 4, 5, 6, 7
  .byte 0, 2, 4, 6
  .byte 0, 4, 0, 4
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
  .byte 0, 0, 0, 0
filthi
  .byte 0, 0, 0, 0
  .byte 1, 1, 1, 1
  .byte 2, 2, 3, 3
  .byte 4, 5, 6, 7
  .byte 8, 10, 12, 14
  .byte 16, 20, 24, 28
  .byte 32, 40, 48, 56
  .byte 64, 80, 96, 112
  .byte 128, 160, 192, 224

crysav
  .byte 0
ecsav
  .byte 0
