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
  beq .l0
  ldy #$ff
  .byte 44
.l0
  ldy #0
  sty 54295

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
  .word 0, 89, 178, 267, 356, 445, 534, 623, 712, 801, 890, 979, 1068, 1157
  .word 1246, 1335, 1424, 1513, 1602, 1691, 1780, 1869, 1958, 2047

maxfilt = (* - filters) / 2
