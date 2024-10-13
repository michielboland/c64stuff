palnts = $02a6 ; 0 = ntsc, 1 = pal
ta1lo = $dc04
icr1 = $dc0d
cr1a = $dc0e
cry = 53265
ec = 53280

  .include "bootstrap.s"

.l0
  bit cry
  bpl .l0
  lda #11
  sta cry
  lda #248
  sta 54295
  lda #$7f
  sta icr1
  lda palnts
  asl a
  tax
  lda timer, x
  sta ta1lo
  sec
  sbc #46
  sta fudge
  lda timer+1, x
  sta ta1lo+1
  lda #$11
  sta cr1a
  lda #$81
  sta icr1
  sei
  lda #<isr
  sta $0314
  lda #>isr
  sta $0315
  cli
  rts

isr
  lda ta1lo
  sec
  sbc fudge

  lsr a
  bcs *+2
  lsr a
  bcs *+2
  bcs *+2
  lsr a
  bcc .l0
  bit 0
  nop
.l0
  cmp #7
  bcs * ; debugging aid - if screen remains black we messed up the timing
  inc ec
  dec ec
  lda counter
  clc
  adc #1
  sta counter
  lda counter+1
  adc #0
  sta counter+1
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
  lsr a
  lda #60
  ror a
  ror a
  sta 54296
  ror a
  ror a
  ror a
  and #8
  sta ec
  lda filtertmp
  ldx filtertmp+1
  sta 54293
  stx 54294
  jmp $ea31

counter
  .word 0

filtertmp
  .word 0

fudge
  .byte 0

timer
  .word 2496 ; ntsc round(5*11250000/11/2048)-1
  .word 2404 ; pal  round(5*17734475/18/2048)-1
