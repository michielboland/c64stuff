; Ultimax

* = $e000

nmi_handler
irq_handler
  rti
rst_handler
  ldx #0
copyvic
  lda 53248,x
  sta $0400,x
  inx
  bne copyvic
  txa
cls
  sta $0500,x
  sta $0600,x
  sta $0700,x
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  inx
  bne cls
  lda #12
  sta 53280
  sta 53281
  lda #27
  sta 53265
  lda #8
  sta 53270
  lda #28
  sta 53272
.loop
  jmp .loop

; graphics
* = $f000
  .include "binary_charset.s"

* = $fffa

  .word nmi_handler
  .word rst_handler
  .word irq_handler

