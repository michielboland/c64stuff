  .include "bootstrap.s"

; c64 pixel aspect ration is 663750 : 709379
; (14.75/2 : 4*4.43361875/18*8)
; which is roughly 160 : 171 (closest Diophantine approximation)
; So to output something that looks like a square you need to draw
; a 171x160 rectangle.

cls = $e544
print = $ab1e

rvs_on = 18
rvs_off = rvs_on + $80
; 3 pixels wide
bar = 181
cr = 13

  lda #12
  sta 53280
  sta 53281
  lda #11
  sta 646
  jsr cls
  lda #<s
  ldy #>s
  ldx #20
next
  jsr printline
  dex
  bne next
  rts
printline
  txa
  pha
  lda #<s
  ldy #>s
  jsr print
  pla
  tax
  rts
s
  .byte rvs_on, "                     ", rvs_off, bar, cr, 0
