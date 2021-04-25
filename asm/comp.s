  .include "bootstrap.s"

reg = 251
odd = 252
pb_shifted = 253

  lda #0
  jsr setcolors
  lda #1
  jsr setcolors
  rts

setcolors
  sta 53311
  lsr a
  ror a
  sta odd
  ldx #0
  stx reg

outer
  ldy #0

loop
  lda #0
  sta pb_shifted

  bit odd
  bmi load_pb_odd

  lda pb_even, x
  clc
  adc pb_odd, y
  jmp pb_loaded

load_pb_odd
  lda pb_odd, x
  clc
  adc pb_even, y

pb_loaded
  lsr a
  lsr a
  ror pb_shifted
  lsr a
  ror pb_shifted
  lsr a
  ror pb_shifted
  sta pb_shifted + 1

  bit odd
  bmi load_pr_odd

  lda pr_even, x
  clc
  adc pr_odd, y
  jmp pr_loaded

load_pr_odd
  lda pr_odd, x
  clc
  adc pr_even, y
pr_loaded
  lsr a
  ora pb_shifted
  sta 53308

  lda y, x
  asl a
  asl a
  ora pb_shifted + 1
  sta 53309
  
  lda reg
  sta 53310
  inc reg
  iny
  cpy #16
  bcc loop
  
  inx
  cpx #16
  bcc outer
  rts

y
  .byte  0, 31, 10, 20, 12, 16,  7, 24, 12,  7, 16, 10, 15, 24, 15, 20

pb_even
  .byte 16, 16, 16, 16, 23, 10, 27,  5, 11,  8, 16, 16, 16, 10, 27, 16
pr_even
  .byte 16, 16, 22, 10, 21, 10, 14, 18, 22, 21, 23, 16, 16, 11, 14, 16

pb_odd
  .byte 16, 16, 14, 18, 21, 12, 25,  7,  9,  8, 14, 16, 16, 12, 25, 16
pr_odd
  .byte 16, 16, 23,  9, 22, 10, 17, 16, 21, 19, 24, 16, 16, 10, 17, 16
