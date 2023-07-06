  .include "bootstrap.s"

end   = 4 ; ctrl-D
cr    = 13
down  = 17
right = 29
up    = 145
left  = 157

linprt = $bdcd ; print integer represented by a (hi) x (lo)
strout = $ab1e

scratch = 2

  jmp printfilt
start
  jsr $ffe4
  beq *-3
  cmp #end
  bne *+3
  rts
  cmp #cr
  bne *+5
  jsr toggle
  cmp #down
  bne *+5
  jsr sublarge
  cmp #up
  bne *+5
  jsr addlarge
  cmp #left
  bne *+5
  jsr subsmall
  cmp #right
  bne *+5
  jsr addsmall
printfilt
  jsr adjust
  jsr setfilt
  ldx filt
  lda filt + 1
  jsr printit
  lda #<padret
  ldy #>padret
  jsr strout
  jmp start

printit
  jsr linprt
  lda #<spc
  ldy #>spc
  jmp strout

subsmall
  pha
  lda filt
  sec
  sbc smallinc
  sta filt
  lda filt + 1
  sbc #0
  sta filt + 1
  pla
  rts

addsmall
  pha
  lda filt
  clc
  adc smallinc
  sta filt
  lda filt + 1
  adc #0
  sta filt + 1
  pla
  rts

sublarge
  pha
  lda filt
  sec
  sbc largeinc
  sta filt
  lda filt + 1
  sbc #0
  sta filt + 1
  pla
  rts

addlarge
  pha
  lda filt
  clc
  adc largeinc
  sta filt
  lda filt + 1
  adc #0
  sta filt + 1
  pla
  rts

adjust
  lda filt + 1
  bpl .l0
  lda #0
  sta filt
  sta filt + 1
  rts
.l0
  cmp #8
  bcc .l1
  lda #255
  sta filt
  lda #7
  sta filt + 1
.l1
  rts

setfilt
  lda filt
  and #7
  tax
  lda #0
  jsr printit
  lda filt + 1
  sta scratch
  lda filt
  .rept 3
  lsr scratch
  ror
  .endr
  ldy filt
  sty 54293
  sta 54294
  tax
  lda #0
  jsr printit
  rts

toggle
  pha
  lda 53265
  eor #16
  sta 53265
  pla
  rts

spc
  .byte " ", 0
padret
  .byte "     ", cr, up, 0

filt
  .word 0
smallinc
  .byte 1
largeinc
  .byte 16
