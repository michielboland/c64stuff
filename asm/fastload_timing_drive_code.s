drivecode

  sei

  ldy #$08
  sty pb ; pull down clock

  ldx #0

.next
  txa
  pha

  ldy #$00 ; release clock line
  sty pb

  ldy #$08 ; prepare to pull down clock

.wait2
  lda pb
  bne .wait2 ; wait for data (and clock) high

  ; from world of code
  txa
  .rept 4
  lsr a
  .endr
  sta pb
  asl a
  and #$0f
  sta pb
  txa
  and #$0f
  sta pb
  asl a
  and #$0f
  sta pb

  sty pb ; pull down clock

  pla
  tax
  inx
  bne .next

  cli

  rts
