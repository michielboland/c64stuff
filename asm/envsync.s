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

  lda env3
  sta 2024
  lda env3
  sta 2025
  lda env3
  sta 2026
  lda env3
  sta 2027
  lda env3
  sta 2028
  lda env3
  sta 2029
  lda env3
  sta 2030
  lda env3
  sta 2031
  lda env3
  sta 2032
  lda env3
  sta 2033
  lda env3
  sta 2034
  lda env3
  sta 2035
  lda env3
  sta 2036
  lda env3
  sta 2037
  lda env3
  sta 2038
  lda env3
  sta 2039

  lda #0
  sta ctrl3

  lda 2
  bne .l5
  nop
.l5

  lda #0
  sta 252
  lda 2
  clc
  adc #1
  and #$0f
  sta 2
  asl a
  asl a
  clc
  adc 2
  .rept 3
  asl a
  rol 252
  .endr

  sta 251
  lda 252
  clc
  adc #4
  sta 252
  ldy #15
.l4
  lda 2024,y
  sta (251),y
  dey
  bpl .l4

  lda #1
  sta 53273

  jmp $ea31
