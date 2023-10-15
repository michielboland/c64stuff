  .include "bootstrap.s"

drive  = 9
sec    = $6f

st     = $90

; buffer pointer for send_drive_cmd
scbuf  = $fb
; length of string to send to drive
sclen  = $fd
; temp storage for print_hex
phtmp  = $fe

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

  .macro PRINT
  pha
  tya
  pha
  lda #<\1
  ldy #>\1
  jsr strout
  pla
  tay
  pla
  .endm

  .macro SEND_CMD
  lda #<\1
  sta scbuf
  lda #>\1
  sta scbuf+1
  lda #\2
  sta sclen
  jsr send_drive_cmd
  .endm

  jsr send_burst
  SEND_CMD inquire_disk_cmd, 3
  jsr recv_burst_cmd_status
  jsr print_hex
  jmp recv_and_print_drive_status

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

send_drive_cmd
  lda #0
  sta st
  lda #drive
  jsr listen
  lda #sec
  jsr second
  bit st
  bmi .dnp
.l1
  ldy #0
  ldx sclen
.nextout
  lda (scbuf),y
  jsr ciout
  bit st
  bmi .dnp
  iny
  dex
  bpl .nextout
  jmp unlsn
.dnp
  ldx #5 ; device not present error
  jmp ($0300)

recv_and_print_drive_status
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

print_hex
  sta phtmp
  txa
  pha
  lda phtmp
  .rept 4
  lsr a
  .endr
  tax
  lda hexchars, x
  jsr chrout
  lda phtmp
  and #$0f
  tax
  lda hexchars, x
  jsr chrout
  lda #13
  jsr chrout
  pla
  tax
  lda phtmp
  rts

hexchars
  .byte '0123456789ABCDEF'
inquire_disk_cmd
  .byte 'U0',4

