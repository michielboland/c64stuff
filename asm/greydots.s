  .include "bootstrap.s"

fudgefac = 25

irqvec =   $0314

vicsx0 =   $d000
vicsy0 =   $d001
vicsxmsb = $d010
viccry =   $d011
vicrc =    $d012
vicse =    $d015
vicsexy =  $d017
vicirq =   $d019
vicirqm =  $d01a
vicbsp =   $d01b
vicscm =   $d01c
vicsexx =  $d01d
vicec =    $d020
vicbc =    $d021
vicsc0 =   $d027

cia1tb =   $dc06
cia1icr =  $dc0d
cia1crb =  $dc0f

setup
  sei
  lda #$7f
  sta cia1icr
  lda cia1icr
  lda #62
  sta cia1tb
  lda #0
  sta cia1tb+1
  lda #42
  sta vicrc
  lda #27
  sta viccry
  lda #0
  sta vicse

.l0
  bit viccry
  bpl .l0
.l1
  bit viccry
  bmi .l1
  lda vicrc
.l2
  cmp vicrc
  beq .l2
  jsr delay
  lda vicrc
  cmp vicrc
  bne .l3
  bit 0
  nop
.l3
  jsr delay
  lda vicrc
  cmp vicrc
  beq *+2
  beq *+2
  jsr delay
  lda vicrc
  cmp vicrc
  beq *+2

  lda #$11
  sta cia1crb
  lda #1
  sta vicirqm
  sta vicirq
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec+1
  cli
  jmp initsprite

delay
  ldy #7
.l0
  dey
  bne .l0
  nop
  rts

irq
  lda cia1tb
  sec
  sbc #fudgefac
  lsr a
  bcs *+2
  lsr a
  bcs *+2
  bcs *+2
  lsr a
  bcc setbordercolor
  bit 0
  nop
setbordercolor
  ldy vicec
  lda vicbc
  sta vicec
  sty vicbc
shortdelay
  ldx #3
.l0
  dex
  bpl .l0
  nop
nudgebordercolor
.l0
  ldy #7
.l1
  nop
  nop
  nop
  sta vicec
  cpy #0
  beq .l3
  ldx #7
.l2
  dex
  bpl .l2
  bit 0
  dey
  bpl .l1
.l3
  ldy vicec
  lda vicbc
  sta vicec
  sty vicbc
  lsr vicirq
  jmp $ea31

initsprite
  lda #0
  sta vicsexx
  sta vicsexy
  sta vicscm
  lda #1
  sta vicse
  sta vicsxmsb
  sta vicbsp
  lda #15
  sta vicsc0
  lda #80
  sta vicsx0
  lda #51
  sta vicsy0
  lda #13
  sta 2040
  lda #0
  ldx #62
.l0
  sta 832,x
  dex
  bpl .l0
  lda #128
  ldx #21
.l1
  sta 832,x
  dex
  dex
  dex
  bpl .l1
  rts
