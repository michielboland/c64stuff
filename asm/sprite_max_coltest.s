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
  lda #63
  sta 53249
  sta 53251
  lda #38
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

  ; delay for at least one field so IRQs occur every other field
  ; (NTSC has phase inverted because of odd number of lines)

  lda #80
.l1
  cmp 53266
  bne .l1
  lda #79
.l2
  cmp 53266
  bne .l2

  lda #4
  bit 56320
  bne .noleft
  dec 53248
  dec 53250
.noleft
  asl
  bit 56320
  bne .noright
  inc 53248
  inc 53250

.noright
  lsr 53273
  lda 53278
  rti

* = $f000

  .byte 128

* = $f800

  .byte %00111100
  .byte %01100110
  .byte %01101110
  .byte %01101110
  .byte %01100000
  .byte %01100010
  .byte %00111100
  .byte %00000000

* = $fff8

  .byte 192
  .byte 192
  .word nmi_handler
  .word rst_handler
  .word irq_handler

