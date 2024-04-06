  .include "bootstrap.s"

viccry   = $d011
vicrc    = $d012
vicirq   = $d019
vicirqen = $d01a
vicec    = $d020

cia1tb  = $dc06
cia1icr = $dc0d
cia1crb = $dc0f

nmivec = $fffa
rstvec = $fffc
irqvec = $fffe

LINE = 46

  sei
  lda #$7f
  sta cia1icr
  lda cia1icr
  .ifdef NTSC
  lda #194
  .else
  lda #188
  .endif
  sta cia1tb
  lda #0
  sta cia1tb+1
  lda #$10
  sta cia1crb
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1
  lda #<nmi
  sta nmivec
  sta rstvec
  lda #>nmi
  sta nmivec+1
  sta rstvec+1
  lda #LINE
  sta 53266
  lda #27
  sta viccry
  lda #1
  sta vicirqen
  sta vicirq
  lda #$35
  sta 1
  cli
  ldy #0
  ldx #8

loop
  cpx cia1tb
  bcc loop
  nop
  nop
  nop
  nop
  jmp loop
restore
  sei
  lda #0
  sta vicirqen
  lsr vicirq
  lda #$7f
  sta cia1icr
  lda #$81
  sta cia1icr
  lda #$37
  sta 1
  lda #27
  sta viccry
  lda #14
  sta vicec
  cli
  rts

irq
  lda #<irq2
  sta irqvec
  lda #>irq2
  sta irqvec+1
  lda #LINE+1
  sta vicrc
  lsr vicirq
  cli
  .rept 18
  nop
  .endr
  .byte 2

irq2
  pla
  pla
  pla
  lda #LINE
  sta vicrc
  lsr vicirq
  .rept 13
  nop
  .endr
  .ifdef NTSC
  nop
  .endif
  lda vicrc
  cmp #LINE+2
  bne *+2
  dec vicec
  inc vicec
  lda #0
  sta vicirqen
  lda #<irq3
  sta irqvec
  lda #>irq3
  sta irqvec+1
  lda #$82
  sta cia1icr
  lda #$11
  .rept 3
  nop
  .endr
  bit 0
  .ifdef NTSC
  nop
  .endif
  sta cia1crb
  bit cia1icr
  lda #11
  sta viccry
  rti

irq3
  inc vicec
  dec vicec
  bit cia1icr
  bit viccry
  bmi reset
  rti
reset
  lda #$7f
  sta cia1icr
  lda #1
  sta vicirqen
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1
  lda #27
  sta viccry
  lda #0
  sta cia1crb
  cpy #0
  bne exit
  rti
exit
  pla
  pla
  pla
  jmp restore

nmi
  iny
  rti
