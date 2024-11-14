icr1 = $dc0d
cry = 53265
ec = 53280
ptr = 251
resonance = 0

  .include "bootstrap.s"

.l0
  bit cry
  bpl .l0
  lda #11
  sta cry
  lda #(resonance << 4) + 0xf
  sta 54295
  lda #$2f
  sta 54296
  lda #$7f
  sta icr1

loop
  lda counter
  and #7
  sta filtertmp
  lda counter
  sta filtertmp+1
  lda counter+1
  .rept 3
  lsr a
  ror filtertmp+1
  .endr
  lda counter
  sta ptr
  lda counter+1
  .rept 2
  asl ptr
  rol a
  .endr
  and #$1f
  sta ptr+1
  lda ptr
  clc
  adc #<table
  sta ptr
  lda ptr+1
  adc #>table
  sta ptr+1

  lda filtertmp
  ldx filtertmp+1
  sta 54293
  stx 54294

  lda counter
  sta ec

  ldy #2
  lda (ptr), y
  tax

  ; delay X*65536+5 cycles
  cpx #0
  beq .l2
  nop
.l1
  jsr hugedelay
  dex
  bne .l1
.l2

  ldy #1
  lda (ptr), y
  tax

  ; delay X*256+5 cycles
  cpx #0
  beq .l4
  nop
.l3
  jsr delay
  dex
  bne .l3
.l4

  ldy #0
  lda (ptr), y
  lsr a
  lsr a
  lsr a
  tax

  ; delay X*8+5 cycles
  cpx #0
  beq .l6
  nop
.l5
  bit 0
  dex
  bne .l5

.l6
  lda (ptr), y

  ; delay 0-7 cycles
  lsr a
  bcs *+2
  lsr a
  bcs *+2
  bcs *+2
  lsr a
  bcc .l7
  bit 0
  nop
.l7


  lda counter
  clc
  adc #1
  sta counter
  lda counter+1
  adc #0
  sta counter+1
  jmp loop

hugedelay
  txa
  pha
  tya
  pha

  ldx #229
.l0
  ldy #56
.l1
  dey
  bne .l1
  dex
  bne .l0
  nop

  pla
  tay
  pla
  tax
  rts

delay
  tya
  pha

  ldy #45
.l0
  dey
  bne .l0
  nop

  pla
  tay
  rts

counter
  .word 0

filtertmp
  .word 0

  .align 2
table
  .ifdef NTSC
  .include "generated/log_sweep_table_ntsc.s"
  .else
  .include "generated/log_sweep_table.s"
  .endif
