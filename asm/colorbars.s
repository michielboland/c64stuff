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
  lda #252
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
  jmp .loop

; graphics
* = $f000

  .rept 8
  .byte $ff
  .endr

* = $f800
colors
  .macro BAR
    .rept 2
    .byte \1
    .endr
  .endm

  .rept 25
    BAR 12
    BAR 12
    BAR 0
    BAR 1
    BAR 2
    BAR 3
    BAR 4
    BAR 5
    BAR 6
    BAR 7
    BAR 8
    BAR 9
    BAR 10
    BAR 11
    BAR 12
    BAR 13
    BAR 14
    BAR 15
    BAR 12
    BAR 12
  .endr

* = $fffa

  .word nmi_handler
  .word rst_handler
  .word irq_handler
