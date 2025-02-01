; Ultimax

* = $e000

nmi_handler
irq_handler
  rti
rst_handler
  lda #12
  sta 53280
  sta 53281
  lda #27
  sta 53265
  lda #8
  sta 53270
  lda #12
  sta 53272
  ldx #0
.clr
  lda colors,x
  sta $d800,x
  lda colors+$100,x
  sta $d900,x
  lda colors+$200,x
  sta $da00,x
  lda colors+$300,x
  sta $db00,x
  inx
  bne .clr
.loop
  stx $d800
  inx
  stx $d801
  inx
  stx $d802
  inx
  lda $d800
  sta $d803
  lda $d801
  sta $d804
  lda $d802
  sta $d805
.l0
  bit 53265
  bpl .l0
.l1
  bit 53265
  bmi .l1
  jmp .loop

; graphics
* = $f000
  .rept $800
  .byte $ff
  .endr

* = $f800
colors
  .macro BG
  .rept 81
  .byte \1
  .endr
  .byte 6, \1, 2, \1, 4, \1, 5, \1, 3, \1, 7
  .rept 3
  .byte \1
  .endr
  .byte 9, \1, 8, \1, 14, \1, 10, \1, 13
  .rept 5
  .byte \1
  .endr
  .byte 0, \1, 11, \1, 12, \1, 15, \1, 1
  .rept 82
  .byte \1
  .endr
  .endm
  BG 0
  BG 11
  BG 12
  BG 15
  BG 1

* = $fffa

  .word nmi_handler
  .word rst_handler
  .word irq_handler

