; Ultimax

* = $e000

nmi_handler
  rti
irq_handler
  pha
  tya
  pha
  lda 53273
  sta 53273
  and #8
  beq done
  bit 53265
  bpl done
  ldy #0
  lda 53267
  sta (2),y
  inc 2
  lda 53268
  sta (2),y
  inc 2
  bne trunc
  inc 3
trunc
  lda 3
  cmp #7
  bcc done
  lda 2
  sbc #232
  bcc done
  lda #0
  sta 53274
  inc 53280
done
  pla
  tay
  pla
  rti
rst_handler
  cld
  lda #11
  sta 53280
  lda #15
  sta 53281
  lda #27
  sta 53265
  lda #8
  sta 53270
  lda #28
  sta 53272
  lda #4
  sta 3
  lda #0
  sta 2
cls
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  inx
  bne cls
  lda #8
  sta 53274
  sta 53273
  cli
.loop
  jmp .loop

; graphics
* = $f000
  .include "binary_charset.s"

* = $fffa

  .word nmi_handler
  .word rst_handler
  .word irq_handler

