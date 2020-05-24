  .include "bootstrap.s"

bc = $d020

.l0
  inc bc
  bne .l0
  beq .l0
