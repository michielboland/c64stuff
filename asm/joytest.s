  .include "bootstrap.s"

pra  = $dc00
prb  = $dc01
ddra = $dc02
ddrb = $dc03
icr  = $dc0d

interrupt = $03fc
ddrasave  = $03fd
ddrbsave  = $03fe
vicecsave = $03ff

viccry = $d011
vicrc  = $d012
vicec  = $d020

; turn off CIA interrupts
  lda #$7f
  sei
  sta icr
  lda icr
  cli
; remap nmi
  lda #<nmi
  sta $fffa
  lda #>nmi
  sta $fffb
  lda #$2f
  sta 0
  lda #$25
  sta 1
; set ports to input
  lda ddra
  sta ddrasave
  lda ddrb
  sta ddrbsave
  lda #0
  sta ddra
  sta ddrb
  lda vicec
  sta vicecsave
; turn off display
  lda #11
  sta viccry

  lda #0
  sta interrupt

notras0
  lda vicrc
  bne notras0
  lda vicrc
l0
  cmp vicrc
  beq l0
  jsr delay
  lda vicrc
  cmp vicrc
  bne l1
  bit 0
  nop
l1
  jsr delay
  lda vicrc
  cmp vicrc
  beq *+2
  beq *+2
  jsr delay
  lda vicrc
  cmp vicrc
  beq *+2

loop
  lda pra
  ldy prb
  eor #$ff
  sta vicec
  lsr
  lsr
  lsr
  lsr
  sta vicec
  tya
  eor #$ff
  sta vicec
  lsr
  lsr
  lsr
  lsr
  sta vicec
  lda #0
  nop
  sta vicec
  lda interrupt
  bne done
  .ifdef NTSC
  nop
  .endif
  jmp loop
done
  lda #$27
  sta 1
  lda ddrasave
  sta ddra
  lda ddrbsave
  sta ddrb
  lda vicecsave
  sta vicec
  lda #27
  sta viccry
  lda #$81
  sta icr
  rts

  .align 3
delay
  ldy #7
.l0
  dey
  bne .l0
  .ifdef NTSC
  nop
  .endif
  nop
  rts
nmi
  inc interrupt
  rti
