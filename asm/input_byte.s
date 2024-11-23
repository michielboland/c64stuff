  .ifndef chrin
chrin  = $ffcf
  .endif
  .ifndef ibtmp
ibtmp  = 2
  .endif

input_byte
  lda #0
  sta ibtmp
.l1
  jsr chrin
  cmp #13
  bne .l0
  lda ibtmp
  clc
  rts
.l0
  sec
  sbc #'0'
  bcc .err
  cmp #10
  bcs .err
  asl ibtmp
  bcs .err
  tax
  lda ibtmp
  asl a
  bcs .err
  asl a
  bcs .err
  adc ibtmp
  bcs .err
  sta ibtmp
  txa
  adc ibtmp
  bcs .err
  sta ibtmp
  bcc .l1
.err
  jsr chrin
  cmp #13
  bne .err
  sec
  rts
