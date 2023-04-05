; Ultimax

* = $e000

nmi_handler
irq_handler
  rti
rst_handler
  lda #15
  sta 53280
  sta 53281
  lda #$5b
  sta 53265
  lda #10
  sta 53282
  lda #13
  sta 53283
  lda #14
  sta 53284
  lda #8
  sta 53270
  lda #$fc
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
  .byte %01110011
  .endr
  .rept 8
  .byte %10011100
  .endr
  .rept 8
  .byte %11100111
  .endr
  .rept 8
  .byte %00111001
  .endr
  .rept 8
  .byte %11001110
  .endr

* = $f800
colors
  .rept 6
  .rept 40
  .byte 11
  .endr
  .rept 40
  .byte 2
  .endr
  .rept 40
  .byte 5
  .endr
  .rept 40
  .byte 6
  .endr
  .endr
  .rept 40
  .byte 11
  .endr

* = $fc00
  .rept 6
  .rept 8
  .byte $00,$01,$02,$03,$04
  .endr
  .rept 8
  .byte $40,$41,$42,$43,$44
  .endr
  .rept 8
  .byte $80,$81,$82,$83,$84
  .endr
  .rept 8
  .byte $c0,$c1,$c2,$c3,$c4
  .endr
  .endr
  .rept 8
  .byte $00,$01,$02,$03,$04
  .endr

* = $fffa

  .word nmi_handler
  .word rst_handler
  .word irq_handler

