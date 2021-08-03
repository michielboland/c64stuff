*=$0fff

  .word *+2
  .word .z
  .word 10
  .byte $9e ; SYS
  .asciiz "4109"
.z
  .word 0
