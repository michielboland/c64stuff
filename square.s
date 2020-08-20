  .include "bootstrap.s"

; c64 pixel aspect ration is 663750 : 709379
; (14.75/2 : 4*4.43361875/18*8)
; which is roughly 160 : 171 (closest Diophantine approximation)
; So to output something that looks like a square you need to draw
; a 171x160 rectangle.

; you could argue that c64 pixel aspect is really 8640000 : 9221927
; (768/52/2 : 4*4.43361875/18*8)
; which is approximately 193 / 206
; In that case a square would be 206x193 pixels

cls = $e544
print = $ab1e

rvs_on = 18
home = 19
rvs_off = rvs_on + $80
; 3 pixels wide
bar = 181
bar2 = 182
cr = 13
stripe1 = 163
bar3 = 170

  lda #12
  sta 53280
  sta 53281
  lda #11
  sta 646
  jsr cls
  lda #<s
  ldy #>s
  ldx #24
next
  jsr printline
  dex
  bne next
  lda #<t
  ldy #>t
  jmp print
printline
  stx tmp
  lda #<s
  ldy #>s
  jsr print
  ldx tmp
  rts
s
  .byte rvs_on
  .rept 25
  .byte " "
  .endr
  .byte bar3, cr, 0
t
  .rept 25
  .byte stripe1
  .endr
  .byte home, 0
tmp
  .byte 0
