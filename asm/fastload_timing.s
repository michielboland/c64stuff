  .include "bootstrap.s"

drive  = 8
ctl    = $6f

second = $ff93
ciout  = $ffa8
unlsn  = $ffae
listen = $ffb1

rc     = $d012

pa     = $dd00
pb     = $1800

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

  sei

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

  ldy #$23
  sty pa ; pull down data

  ldx #0

.sync1
  inx
  beq .timeout
  bit pa
  bvs .sync1 ; wait for clock low

  ldx #0

.next

  ldy #0

.wait2
  iny
  beq .timeout
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

  sta $0400, x
  inc $d020
  inx
  bne .next

  jmp .test

.timeout
  lda #2
  sta $d021
  jmp *

  .include "fastload_timing_drive_code.s"
