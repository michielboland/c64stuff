  .include "bootstrap.s"

ctrl3 = 54290
env3  = 54300

  sei
  lda #<isr
  sta $0314
  lda #>isr
  sta $0315
  lda #127
  sta 56333
  lda 56333
  lda #251
  sta 53266
  lda #27
  sta 53265
  lda #1
  sta 53274
  sta 53273
  cli
  rts

isr
  ; Slight hack to position the border effect properly.
  lda 53266
.wait_for_new_raster
  cmp 53266
  beq .wait_for_new_raster
  .rept 9
  nop
  .endr

  lda #1
  sta ctrl3

  ; Synchronize to the envelope counter.
  ; We need to do four comparisons since the LFSR that triggers the counter
  ; increment can in be one of 9 states.
  ; The algorithm could be a bit more transparent.

  lda env3
  cmp env3
  bne .A
  bit 0
  nop
.A
  lda env3
  cmp env3
  bne .B
  nop
  nop
  nop
  nop
.B
  nop
  nop
  lda env3
  cmp env3
  beq *+2
  bit 0
  lda env3
  cmp env3
  bne *+2

  ; We are now synchronized to the envelope counter.
  ; FIXME do something more useful.

  inc 53280
  dec 53280

  lda #0
  sta ctrl3

  lda #1
  sta 53273

  jmp $ea31
