  .include "bootstrap.s"

irqvec   = $0314
cra      = $dc0d
vicirq   = 53273
vicirqm  = 53274
cls      = $e544
digits   = 1520
digitcol = 55792

  jsr cls
  ldy #7
  lda #14
  ; workaround color bug on old kernals
.setcolor
  sta digitcol,y
  dey
  bpl .setcolor
  lda #15
  sta 53269
  sta 53271
  sta 53277
  sta 53287
  sta 53288
  sta 53289
  sta 53290
  lda #50
  sta 53249
  lda #102
  sta 53251
  lda #155
  sta 53253
  lda #208
  sta 53255
  lda #13
  sta 2040
  sta 2041
  sta 2042
  sta 2043
  ldx #62
  lda #255
.l1
  sta 832,x
  dex
  bpl .l1
  sei
  lda #127
  sta cra
  lda cra
  lda #0
  sta 53266
  lda #27
  sta 53265
  lda #1
  sta vicirq
  sta vicirqm
  lda #<irq
  sta irqvec
  lda #>irq
  sta irqvec + 1
  jsr clearsid
  cli
.l2
  bne .l2
  brk

irq
  lda #1
  sta vicirq
  ldx #0
  jsr setsp
  inx
  lda toggle
  and #1
  beq skip1
  jsr setsp
skip1
  inx
  lda toggle
  and #1
  bne skip2
  jsr setsp
skip2
  lda toggle
  eor #1
  sta toggle
  inx
  jsr setsp
  lda soundtoggle
  and #1
  ora #128
  sta 54276
  lda counter
  clc
  sed
  adc #1
  sta counter
  lda counter+1
  adc #0
  sta counter+1
  lda counter+2
  adc #0
  sta counter+2
  lda counter+3
  adc #0
  sta counter+4
  cld
  ldx #0
  jsr display_counter
  inx
  jsr display_counter
  inx
  jsr display_counter
  inx
  jsr display_counter
  jmp $ea31

setsp
  txa
  asl
  tay
  lda pos, x
  asl
  sta 53248, y
  bcc clearmsb
  ; set msb
  lda msb, x
  ora 53264
  sta 53264
  jmp move
clearmsb
  lda msb, x
  eor #$ff
  and 53264
  sta 53264
move
  lda #1
  and dir,x
  bne toleft
toright
  lda pos, x
  ; at right edge?
  cmp #148
  bcc moveright
  ; revert
  inc 53280
  inc soundtoggle
  inc dir,x
  jmp moveleft
moveright
  cld
  adc #1
  jmp storepos
toleft
  lda pos, x
  ; at left edge?
  cmp #12
  bcs moveleft
  ; revert
  dec 53280
  dec soundtoggle
  dec dir,x
  jmp moveright
moveleft
  cld
  sbc #1
storepos
  sta pos, x
  rts

clearsid
  lda #0
  ldx #23
.l1
  sta 54272, x
  dex
  bpl .l1
  lda #15
  sta 54296
  lda #240
  sta 54278
  lda #128
  sta 54276
  sta 54273
  rts

display_counter
  txa
  eor #3
  asl
  tay
  lda counter, x
  and #$f
  ora #48
  sta digits+1, y
  lda counter, x
  lsr
  lsr
  lsr
  lsr
  ora #48
  sta digits,y
  rts

pos
  .byte 0
  .byte 34
  .byte 68
  .byte 102
dir
  .byte 0
  .byte 0
  .byte 0
  .byte 0
msb
  .byte 1
  .byte 2
  .byte 4
  .byte 8
  .byte 16
  .byte 32
  .byte 64
  .byte 128
toggle
  .byte 0
soundtoggle
  .byte 0
counter
  .byte 0
  .byte 0
  .byte 0
  .byte 0
