  .include "bootstrap.s"

end   = 4 ; ctrl-D
cr    = 13
right = 29
up    = 145
left  = 157

linprt = $bdcd ; print integer represented by a (hi) x (lo)
strout = $ab1e

scratch = 2

  lda #$2f
  sta 54296
  lda #$f8
  sta 54295
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
  cmp #left
  bne *+5
  jsr subsmall
  cmp #right
  bne *+5
  jsr addsmall
printfilt
  jsr setfilt
  lda filt
  asl
  tay
  ldx filters, y
  lda filters + 1, y
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
  beq .l0
  sec
  sbc #1
  sta filt
.l0
  pla
  rts

addsmall
  pha
  lda filt
  clc
  adc #1
  cmp #maxfilt
  beq .l0
  sta filt
.l0
  pla
  rts

setfilt
  lda filt
  sta 53280
  asl
  tay
  lda filters + 1, y
  sta scratch
  lda filters, y
  tax
  .rept 3
  lsr scratch
  ror
  .endr
  sta hi
  txa
  and #7
  sta lo

  lda #0
  ldx lo
  jsr printit
  lda #0
  ldx hi
  jsr printit

  ldy lo
  lda hi
  sty 54293
  sta 54294
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
  .byte 0

lo
  .byte 0
hi
  .byte 0
filters
  .word 2, 3, 4, 5, 6, 7, 8, 10, 11, 13, 16, 19, 23, 27, 32, 38, 45, 54, 64
  .word 76, 91, 108, 128, 152, 181, 215, 256, 304, 362, 431, 512, 609, 724
  .word 861, 1024, 1218, 1448, 1722, 2047
maxfilt = (* - filters) / 2
