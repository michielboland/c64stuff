  .include "bootstrap.s"

irqvec = $0314
sav = hak + 1

  ldx #0
.l0
  lda #0
  sta 53248,x
  inx
  lda #48
  sta 53248,x
  inx
  cpx #16
  bcc .l0

  lda #0
  sta 53271
  sta 53277
  lda #255
  sta 53269

hak
  lda #51
  sta 53266
  lda #27
  sta 53265

  sei
  lda #127
  sta 56333
  lda 56333
  lda #1
  sta 53274
  sta 53273
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1
  cli
  rts

irq
  inc 53280
  inc 53281
  dec 53280
  dec 53281
  lda sav
  eor #1
  sta sav
  sta 53266
  lda #1
  sta 53273
  jmp $ea31
