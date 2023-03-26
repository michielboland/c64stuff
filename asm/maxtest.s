; Ultimax

* = $e000

v = 53248
cur = v+2
inst = v+4
ck = v+10

rst_handler
  lda #12
  sta 53280
  lda #15
  sta 53281
  lda #27
  sta 53265
  lda #8
  sta 53270
  lda #18
  sta 53272
  lda seed
  sta v
  lda seed+1
  sta v+1
  lda #11
  ldx #0
clr
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  inx
  bne clr

loop
  .macro LOAD
  lda v
  sta cur
  lda v+1
  sta cur+1
  .endm
  LOAD
  lda #141 ; STA
  sta inst
  lda #2
  sta inst+1
  lda #0
  sta inst+2

  lda #76 ; JMP
  sta inst+3
  lda #<c1
  sta inst+4
  lda #>c1
  sta inst+5

nextfill
  lda cur
  jmp inst

  .macro SHIFT
  asl cur
  rol cur+1
  bit cur+1
  bpl .pl
  bvs .plvc
  bvc .e
.pl
  bvc .plvc
.e
  lda cur
  eor #1
  sta cur
.plvc
  .endm

c1
  SHIFT

  .macro STEP
  inc inst+1
  bne \1
  inc inst+2
  ldx inst+2
  cpx #16
  bne \1
  .endm
  STEP nextfill

  lda #77 ; EOR
  sta inst
  lda #2
  sta inst+1
  lda #0
  sta inst+2
  lda #<c2
  sta inst+4
  lda #>c2
  sta inst+5
  lda #0
  sta ck
  LOAD

nextcompare
  lda cur
  jmp inst
c2
  ora ck
  sta ck
  SHIFT
  STEP nextcompare

  lda ck
  sta 53280
  .rept 4
  lsr a
  .endr
  sta 53281

next
  LOAD
  SHIFT
  lda cur
  sta v
  lda cur+1
  sta v+1
  jmp loop

irq_handler
  .byte 2
seed
  .word $7fff

* = $fffa

  .word rst_handler
  .word rst_handler
  .word irq_handler

