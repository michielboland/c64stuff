  .include "bootstrap.s"

drive    = 8
ctl      = $6f

counter  = $fb
runs     = $fd

stkey    = $91

linprt   = $bdcd
second   = $ff93
ciout    = $ffa8
unlsn    = $ffae
listen   = $ffb1
chrout   = $ffd2
plot     = $fff0

rc       = $d012

pa       = $dd00
pb       = $1800

expected = $c000
actual   = $0400

  jsr compute_expected
  jsr reset_counters
  jsr move_cursor

  ldx #8
  ldy #0
.loop
  lda #drive
  jsr listen
  lda #ctl
  jsr second
  lda #'M'
  jsr ciout
  lda #'-'
  jsr ciout
  lda #'W'
  jsr ciout
  tya
  jsr ciout
  lda #3
  jsr ciout
  txa
  pha
  lda #$20
  tax
  jsr ciout
.block
  lda drivecode, y
  jsr ciout
  iny
  dex
  bne .block
  jsr unlsn
  pla
  tax
  dex
  bne .loop

.test
  lda #drive
  jsr listen
  lda #ctl
  jsr second
  lda #'M'
  jsr ciout
  lda #'-'
  jsr ciout
  lda #'E'
  jsr ciout
  lda #0
  jsr ciout
  lda #3
  jsr ciout
  jsr unlsn

  sei

  ldy #$23
  sty pa ; pull down data

.sync1
  bit pa
  bvs .sync1 ; wait for clock low

  ldx #0

.next
.wait2
  bit pa
  bvc .wait2 ; wait for clock high

  ldy #$03 ; prepare to release data line

.hold
  lda rc
  cmp #50
  bcc .ok
  and #7
  cmp #2
  beq .hold ; avoid bad line

.ok
  sty pa ; release data line

  cmp (0,x) ; delay
  cmp (0,x)
  cmp (0,x)

  ldy #$23 ; prepare to pull down data

  lda pa
  lsr a
  lsr a
  eor pa
  lsr a
  lsr a
  eor pa
  lsr a
  lsr a
  eor pa

  sty pa ; pull down data

  sta actual, x
  inc $d020
  inx
  bne .next

  cli
  jsr compare
  bit stkey
  bmi .test
  rts

  .include "fastload_timing_drive_code.s"

compute_expected
  ldx #0
  ldy #0
.l1
  lda lsn, x
  inx
  .rept 16
  sta expected, y
  iny
  .endr
  bne .l1
.l3
  ldx #0
.l2
  lda msn, x
  .rept 4
  asl a
  .endr
  ora expected, y
  sta expected, y
  inx
  iny
  cpx #16
  bcc .l2
  cpy #0
  bne .l3
  rts

reset_counters
  lda #0
  sta counter
  sta counter + 1
  sta runs
  sta runs + 1
  rts

move_cursor
  sec
  jsr plot
  cpx #7
  bcs .ok
  ldx #7
.ok
  clc
  jmp plot

compare
  sec
  jsr plot
  ldy #0
  clc
  jsr plot
  ldy #0
  ldx #0
.l0
  lda actual, x
  cmp expected, x
  beq .ok
  iny
  bne .ok
  inc counter + 1 ; edge case, all bytes are bad
.ok
  inx
  bne .l0
  tya
  clc
  adc counter
  sta counter
  tax
  lda counter + 1
  adc #0
  sta counter + 1
  jsr linprt
  inc runs
  bne .l1
  inc runs + 1
.l1
  lda #'/'
  jsr chrout
  ldx runs
  lda runs + 1
  jmp linprt

lsn
  .byte 12, 4, 14, 6, 8, 0, 10, 2
  .byte 13, 5, 15, 7, 9, 1, 11, 3
msn
  .byte 15, 7, 13, 5, 11, 3, 9, 1
  .byte 14, 6, 12, 4, 10, 2, 8, 0
