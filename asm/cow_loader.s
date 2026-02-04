  .include "bootstrap.s"

cry = $d011
rc = $d012

tmp = 251

; should arrive at $4200 when rc = 1 and cy = 20 (decimal)

counter = $0237

  sei
  lda #11
  sta cry
.l0
  bit cry
  bmi .l0
.l1
  bit cry
  bpl .l1

sync
  lda rc
.l0
  cmp rc
  beq .l0
  jsr delay
  lda rc
  cmp rc
  bne .l1
  bit 0
  nop
.l1
  jsr delay
  lda rc
  cmp rc
  beq *+2
  beq *+2
  jsr delay
  lda rc
  cmp rc
  beq *+2

  ; delay some more
.l2
  bit cry
  bmi .l2

  lda #<counter
  sta tmp
  lda #>counter
  sta tmp+1

  sec
.l3
  lda tmp
  sbc #1
  sta tmp
  lda tmp+1
  sbc #0
  sta tmp+1
  ora tmp
  bne .l3

  ; final adjustment (each loop above takes 22 cycles)
  sta tmp
  sta $d020
  sta $d021
  nop
  nop
  nop

  jmp copy

delay
  ldy #7
.l0
  dey
  bne .l0
  nop
  rts

copy
  ldx #0
.l0
  lda zp,x
  sta $717f,x
  inx
  bne .l0
.l1
  lda loader,x
  sta $4200,x
  inx
  cpx #len
  bne .l1

  lda #$7b
  sta cry
  jmp $4200

  .align 8
zp
  .byte $2f, $37, 0, $aa, $b1, $91, $b3, $22, 0, 0, 0, $4c, 0, $ff, 0, 0
  .byte 0, 0, 0, 0, 0, 0, $19, $16, 0, $a, $76, $a3, 0, 0, 0, 0
  .byte 0, 0, $ff, $aa, $b3, $bd, 0, 0, 0, 0, 0, 1, 8, 3, 8, 3
  .byte 8, 3, 8, 0, $a0, 0, 0, 0, $a0, 0, $ff, 0, 0, 0, 0, 0
  .byte 0, 0, 8, 0, 0, 0, 0, $24, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 0, 0, 0, 3, $4c, 0, 0, 0, 0, 0, 0, 0, 0, $fc, 0, 0
  .byte 0, $a, $76, $a3, $19, 0, $20, 0, 0, $80, 0, 0, 0, 4, 0, $76
  .byte 0, 6, $a3, $e6, $7a, $d0, 2, $e6, $7b, $ad, 1, 2, $c9, $3a, $b0, $a
  .byte $c9, $20, $f0, $ef, $38, $e9, $30, $38, $e9, $d0, $60, $80, $4f, $c7, $52, $58
  .byte 0, $ff, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, $80, 0, 0
  .byte 0, 4, $81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 0, 0, $3c, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  .byte 0, 0, 0, 0, $20, 1, 0, 0, $11, $c, $10, 1, 1, 2, $20, 0
  .byte $27, $e0, 5, $11, 0, $27, $c, $30, 0, $84, $84, $84, $84, $84, $84, $84
  .byte $85, $85, $85, $85, $85, $85, $86, $86, $86, $86, $86, $86, $86, $87, $87, $87
  .byte $87, $87, $87, $e0, $d9, $81, $eb, 0, 0, 0, 0, 0, 0, 0, 0, $20

loader
  sei
  ldx #0
.l0
  lda $717f,x
  sta 0,x
  inx
  bne .l0
  stx $02a1
  stx $02a3
  jsr $fda3
  nop
  nop
  nop
  jsr $426f
  lda #$49
  jsr $eddd
  jsr $edfe
  jsr $426f
  ldx #0
.l1
  lda $42c2,x
  jsr $eddd
  inx
  cpx #$21
  bne .l1
  jsr $edfe
  sei
.l2
  bit $dd00
  bvs .l2
  lda $dd00
  ora #$08
  sta $dd00
  cmp ($00,x)
  and #$c7
  sta $dd00
.l3
  bit $dd00
  bvc .l3
  jsr $4279
  sta $fe
  jsr $4279
  sta $ff
  ldy #0
.l4
  jsr $4279
  bcs .l5
  sta ($fe),y
  iny
  bne .l4
  inc $ff
  bcc .l4
.l5
  jsr $fda3
  jmp $0824
  lda #$08
  jsr $ffb1
  lda #$6f
  jmp $ff93
  stx $fc
  lda $dd00
  ora #$08
  sta $dd00
  ldx #$03
.l6
  bit $dd00
  bvs .l6
  lda $dd00
  and #$f7
  sta $dd00
  jsr $42c1
  lda $dd00
  ora #$08
  sta $dd00
  rol a
  rol $fd
  rol a
  rol $fd
  dex
  bpl .l6
  sec
.l7
  bit $dd00
  bvs .l7
  lda $dd00
  and #$c7
  sta $dd00
  jsr $42c1
  bit $dd00
  bpl .l8
  clc
.l8
  ldx $fc
  lda $fd
  rts
  .byte '&DUTCH DRIVEBOOT*THE COW SAYS MOO'
len = *-loader
