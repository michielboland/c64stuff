*=$07ff

  .word *+2
  .word .z
  .word 10
  .byte $9e ; SYS
  .asciiz "2061"
.z
  .word 0
