  .include "bootstrap.s"

irqvec   = $0314
joy      = $dc00
xlo      = 251
xhi      = 252
ylo      = 253
yhi      = 254 ; unused for now
sp       = 2040
joytmp   = sp-1

cra      = $dc0d
spbase   = 11*64

vics0x   = 53248
vics0y   = 53249
vicsxmsb = 53264
viccry   = 53265
vicrc    = 53266
vicse    = 53269
vicsexy  = 53271
vicirq   = 53273
vicirqm  = 53274
vicsexx  = 53277
vicssc   = 53278
vicbc    = 53281
vics0c   = 53287

  ldx #60
  lda #0
cls0
  sta spbase+2,x
  dex
  bne cls0
  lda #%10110110
  sta spbase
  sta spbase+1
  sta spbase+2
  ldx #7
  lda #11
cls1
  sta sp,x
  dex
  bpl cls1

  lda #24
  sta xlo
  lda #0
  sta xhi
  sta yhi
  lda #56
  sta ylo

  jsr setsp
  lda #255
  sta vicse
  lda #0
  sta vicsxmsb
  sta vicsexy
  sta vicsexx
  lda #12
  sta vics0c
  lda #1
  sta vicbc
  sei
  lda #127
  sta cra
  lda cra
  lda vicssc
  lda #4
  sta vicirqm
  sta vicirq
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1
  cli
  rts

setsp
  lda xhi
  cmp #1
  bcc xok
  bne resetx
  lda xlo
  cmp #248
  bcc xok
resetx
  lda #0
  sta xlo
  sta xhi
xok
  ldx #0
  lda xhi
  beq setsp1
  dex
setsp1
  stx vicsxmsb
  lda xlo
  ldx #14
setsp2
  sta vics0x,x
  dex
  dex
  bpl setsp2

  lda ylo
  ldx #14
setsp3
  sta vics0y,x
  dex
  dex
  bpl setsp3
  rts


irq
  lda vicrc
  cmp #255
  bne wait1
wait0
  lda vicrc
  bne wait0
wait1
  bit viccry
  bmi wait1
wait2
  lda vicrc
  cmp #56
  bcc wait2

  lda joy
  cmp joy
  bne irq

  sta joytmp

  lda #1
  bit joytmp
  bne noup

  dec ylo
noup
  lda #2
  bit joytmp
  bne nodown

  inc ylo
nodown
  lda #4
  bit joytmp
  bne notleft

  ldx xlo
  cpx #0
  bne left2
  ldx xhi
  beq left1
  dex
  stx 252
  ldx #0
  beq left2
left1
  ldx #1
  stx xhi
  ldx #248
left2
  dex
  stx xlo
notleft
  lda #8
  bit joytmp
  bne notright

  ldx xhi
  beq right1
  ldx xlo
  cpx #247
  bcc right1
  ldx #0
  stx xlo
  stx xhi
  beq notright
right1
  inc xlo
  bne notright
  inc xhi
notright
  jsr setsp
  lda vicssc
  lda #4
  sta vicirq
  jmp $ea31

