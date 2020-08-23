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

  jsr cls
  ldx #62
  lda #255
.l0
  sta 832, x
  dex
  bpl .l0
  ldx #7
  lda #13
.l1
  sta 2040, x
  dex
  bpl .l1
  ldx #46
.l2
  lda vic, x
  sta 53248, x
  dex
  bpl .l2
.l3
  bmi .l3

vic
  .byte  24,  50, 195,  50,  24, 210, 195, 210
  .byte 114,  50,  64,  50, 114, 243,  64, 243
  .byte 160, 155,  56,   0,   0, 255,   8,   0
  .byte  20,  15,   0,   0,   0,   0,   0,   0
  .byte  12,  12,  12,  12,  12,  12,  12,  11
  .byte  11,  11,  11,  15,  15,  15,  15
