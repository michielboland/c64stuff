  .include "bootstrap.s"

cls = $e544

  lda #12
  sta 53280
  sta 53281
  lda #11
  sta 646
  jsr cls
  lda #101
  sta 1504
  lda #103
  sta 1543
  .byte 2
