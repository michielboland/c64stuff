  .include "bootstrap.s"

viccry   = 53265
vicrc    = 53266
vicirq   = 53273
vicirqm  = 53274
vicec    = 53280
vicbc    = 53281
icr      = 56333

  lda #0
  sta vicec
  sta vicbc
  lda #0
  sta 251
  sta 253
  lda #4
  sta 252
  lda #216
  sta 254
  ldx #0
l2
  ldy #39
l1
  lda #160
  sta (251),y
  lda line,y
  sta (253),y
  dey
  bpl l1
  inx
  cpx #25
  beq end
  lda 251
  clc
  adc #40
  sta 251
  lda 252
  adc #0
  sta 252
  lda 253
  clc
  adc #40
  sta 253
  lda 254
  adc #0
  sta 254
  jmp l2
end
  sei
  lda #$7f
  sta icr
  lda icr
  lda #<nmi
  sta $fffa
  lda #>nmi
  sta $fffb
  lda #<irq
  sta $fffe
  lda #>irq
  sta $ffff
  lda #$35
  sta 1
  lda #151
  sta vicrc
  lda #27
  sta viccry
  lda #1
  sta vicirq
  sta vicirqm
  cli
loop
  .rept 7
  nop
  .endr
  bne loop

irq
  bit 0
  .rept 6
  nop
  .endr
  dec vicirq
nmi
  rti

  .macro BAR
    .rept 2
    .byte \1
    .endr
  .endm

line
  BAR 12
  BAR 12
  BAR 0
  BAR 1
  BAR 2
  BAR 3
  BAR 4
  BAR 5
  BAR 6
  BAR 7
  BAR 8
  BAR 9
  BAR 10
  BAR 11
  BAR 12
  BAR 13
  BAR 14
  BAR 15
  BAR 12
  BAR 12
