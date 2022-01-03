; Ultimax

* = $e000

nmi_handler
  rti
rst_handler
  ldx #0
  ldy #8
loop
  .rept 62
  sty $d020
  stx $d020
  .endr
  bit 0
  nop
  jmp loop

* = $fffa

  .word nmi_handler
  .word rst_handler
  .word 0

