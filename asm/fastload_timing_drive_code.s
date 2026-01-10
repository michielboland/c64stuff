drivecode

  sei

  lda #1
.sync
  bit pb
  beq .sync ; wait for data low

  ldy #$08
  sty pb ; pull down clock

  ldx #11
.l0
  dex
  bne .l0 ; keep clock low for at least 60 us

  ldx #0

.next
  txa
  pha

  ldy #$00 ; release clock line
  sty pb

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

  ldy #$08
  nop
  sty pb ; pull down clock

  pla
  tax
  inx
  bne .next

  cli

  rts
