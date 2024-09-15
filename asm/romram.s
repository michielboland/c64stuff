
start = $c000

  * = start-2

  .word start

  ldy #0
  sty 251
  sty 253
  lda #$a0
  sta 252
  lda #$e0
  sta 254
loop
  lda (251), y
  sta (251), y
  lda (253), y
  sta (253), y
  iny
  bne loop
  inc 252
  inc 254
  bne loop
  lda 1
  and #%00101000
  ora #%00000101
  sta 1
  rts
