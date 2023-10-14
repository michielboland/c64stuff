  .include "bootstrap.s"

drive  = 9
sec    = $6f

st     = $90

linprt = $bdcd
strout = $ab1e

ta1    = $dc04
sdr1   = $dc0c
icr1   = $dc0d
cra1   = $dc0e
pra2   = $dd00

ioinit = $ff84
second = $ff93
tksa   = $ff96
acptr  = $ffa5
ciout  = $ffa8
untlk  = $ffab
unlsn  = $ffae
listen = $ffb1
talk   = $ffb4
chrout = $ffd2

  lda #<dbg1
  ldy #>dbg1
  jsr strout

  jsr send_burst

  lda #<dbg2
  ldy #>dbg2
  jsr strout

  lda #0
  sta st
  lda #drive
  jsr listen
  lda #sec
  jsr second
  bit st
  bpl .l1
  ; device not present
  lda #<nodev
  ldy #>nodev
  jmp strout
.l1
  ldx #0
  ldy #endbuf-buf
.nextout
  lda buf, x
  jsr ciout
  bit st
  bpl .l2
  jmp unlsn
.l2
  inx
  dey
  bpl .nextout

.l3
  jsr unlsn

  lda #<dbg3
  ldy #>dbg3
  jsr strout

  jsr recv_burst_cmd_status
  tax
  lda #0
  jsr linprt

  lda #<dbg4
  ldy #>dbg4
  jsr strout

  lda #drive
  jsr talk
  lda #sec
  jsr tksa
.nextin
  jsr acptr
  bit st
  bvs .eoi
  jsr chrout
  jmp .nextin
.eoi
  jmp untlk

recv_burst_cmd_status
  sei
  bit icr1
  lda pra2
  eor #$10 ; toggle clock
  sta pra2
  lda #$08
.l0
  bit icr1
  beq .l0
  lda sdr1
  cli
  rts

send_burst
  lda #$7f
  sta icr1 ; disable CIA interrupts
  lda #0
  sta ta1+1
  lda #4
  sta ta1
  lda cra1
  and #$80
  ora #$55 ; timer A CNT
  sta cra1
  bit icr1
  lda #$ff
  sta sdr1 ; send one byte
  lda #$08
.l0
  bit icr1 ; wait until byte is sent
  beq .l0
  jmp ioinit

nodev
  .byte $96,'DEVICE NOT PRESENT',$9a,13,0
dbg1
  .byte 'SEND BURST',13,$91,0
dbg2
  .byte 'SEND CMD  ',13,$91,0
dbg3
  .byte '    <- RECV BURST',13,$91,0
dbg4
  .byte 13,'RECV STATUS',13,$91,0
buf
  .byte 'U0',4

endbuf = *
