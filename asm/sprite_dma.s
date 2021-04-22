irqvec   = $0314

  .include "bootstrap.s"

  sei
  lda #$7f
  sta 56333
  lda 56333
  lda #248
  sta 53266
  lda #27
  sta 53265
  lda #1
  sta 53274
  sta 53273
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1
  cli
  lda #0
  sta $3fff
  clc
  ldy #7
  ldx #14
.l0
  tya
  asl a
  asl a
  asl a
  adc #24
  sta 53248,x
  tya
  sec
  sbc #4
  sta 53249,x
  lda #11
  sta 2040,y
  lda #1
  sta 53287,y
  dex
  dex
  dey
  bpl .l0
  lda #255
  sta 704
  sta 705
  sta 706
  ldx #60
  lda #0
.l1
  sta 707,x
  dex
  bpl .l1
  lda #255
  sta 53269
  sta 53277
  lda #0
  sta 53271
  rts

irq:
  lda #19
  sta 53265
  lda 53266
.l0:
  cmp 53266
  beq .l0
  jsr delay
  lda 53266
  cmp 53266
  bne .l1
  bit 0
  nop
.l1:
  jsr delay
  lda 53266
  cmp 53266
  beq .l2
.l2:
  beq .l3
.l3:
  jsr delay
  lda 53266
  cmp 53266
  beq .l4
.l4:
  lda #27
  sta 53265

  .rept 13
  nop
  .endr
  dec 53281
  inc 53281 

  lda #254
  sta 53269

  .rept 23
  nop
  .endr
  dec 53281
  inc 53281 

  lda #252
  sta 53269

  .rept 23
  nop
  .endr
  dec 53281
  inc 53281 

  lda #248
  sta 53269

  .rept 19
  nop
  .endr
  bit 0
  dec 53281
  inc 53281 

  lda #240
  sta 53269

  .rept 18
  nop
  .endr
  bit 0
  dec 53281
  inc 53281 

  lda #224
  sta 53269

  .rept 17
  nop
  .endr
  bit 0
  dec 53281
  inc 53281 

  lda #192
  sta 53269

  .rept 16
  nop
  .endr
  bit 0
  dec 53281
  inc 53281 

  lda #128
  sta 53269

  .rept 17
  nop
  .endr
  dec 53281
  inc 53281 

  lda #0
  sta 53269

  .rept 14
  nop
  .endr
  bit 0
  dec 53281
  inc 53281 

  lda #255
  sta 53269

  lda #1
  sta 53273
  jmp $ea31

delay:
  ldy #7
.l0:
  dey
  bne .l0
  nop
  rts
