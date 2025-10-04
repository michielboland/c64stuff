  .include "bootstrap.s"

  ldx #7
  ldy #15
.l
  lda sprite_positions, y
  sta $d000, y
  dey
  lda sprite_positions, y
  sta $d000, y
  dey
  lda #14
  sta $d027, x
  lda sprite_pointers, x
  sta $07f8, x
  dex
  bpl .l

  lda #$80
  sta $d010
  lda #$ff
  sta $d015
  sta $d017
  lda #0
  sta $d01b
  sta $d01c
  sta $d01d
  rts

sprite_positions
  .byte 89, 208
  .byte 113, 208
  .byte 137, 208
  .byte 161, 208
  .byte 185, 208
  .byte 209, 208
  .byte 233, 208
  .byte 1, 208

sprite_pointers
  .byte s0 >> 6
  .byte s1 >> 6
  .byte s2 >> 6
  .byte s0 >> 6
  .byte s1 >> 6
  .byte s2 >> 6
  .byte s0 >> 6
  .byte s1 >> 6

  .align 6
s0
  .rept 21
  .byte %10000000
  .byte %01000000
  .byte %00100000
  .endr

  align 6
s1
  .rept 21
  .byte %00010000
  .byte %00001000
  .byte %00000100
  .endr
  
  .align 6
s2
  .rept 21
  .byte %00000010
  .byte %00000001
  .byte %00000000
  .endr



