  .include "bootstrap.s"

  lda #137
  sta 53311

reg = 251
pb_shifted = 252

  ldx #0
  stx reg

loop
  lda #0
  sta pb_shifted
  lda pb, x
  lsr a
  ror pb_shifted
  lsr a
  ror pb_shifted
  lsr a
  ror pb_shifted
  sta pb_shifted + 1

  lda pr, x
  ora pb_shifted
  sta 53308

  lda y, x
  asl a
  asl a
  ora pb_shifted + 1
  sta 53309
  
  ldy #0
write_regs
  lda reg
  sta 53310
  inc reg
  iny
  cpy #16
  bcc write_regs
  
  inx
  cpx #16
  bcc loop
  rts

y
  .byte  0, 31, 10, 20, 12, 16,  7, 24, 12,  7, 16, 10, 15, 24, 15, 20
pb
  .byte 16, 16, 15, 17, 22, 11, 26,  6, 10,  8, 15, 16, 16, 11, 26, 16
pr
  .byte 16, 16, 23,  9, 22, 10, 15, 17, 21, 20, 23, 16, 16, 10, 15, 16
