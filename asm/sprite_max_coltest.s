; Ultimax

* = $e000

nmi_handler
  rti
rst_handler
  ldx #0
  lda #14
clr
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  inx
  bne clr
  lda #8
  sta 53270
  lda #27
  sta 53265
  lda #3
  sta 53269
  lda #50
  sta 53249
  sta 53251
  lda #24
  sta 53248
  sta 53250
  lda #0
  sta 53264
  lda #1
  sta 53287
  sta 53288
  lda #255
  sta 53272
  lda #4
  sta 53274
  sta 53273
  lda 53278
  lda #14
  sta 53280
  lda #6
  sta 53281
  cli
loop
  jmp loop
irq_handler
  lsr 53273
  lda 53278
  rti

* = $f000

  .byte 128

* = $f800

  .byte %11110000
  .byte %01111000
  .byte %00111100
  .byte %00011110
  .byte %00001111
  .byte %10000111
  .byte %11000011
  .byte %11100001

* = $fff8

  .byte 192
  .byte 192
  .word nmi_handler
  .word rst_handler
  .word irq_handler

