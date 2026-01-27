  .include "bootstrap.s"


st = $90
tmp = 251
delay = 44967

cry = $d011
icr = $dc0d

; KERNAL routines

second = $ff93
tksa   = $ff96
acptr  = $ffa5
ciout  = $ffa8
untlk  = $ffab
unlsn  = $ffae
listen = $ffb1
talk   = $ffb4
chrout = $ffd2

  .macro SENDCMD
  lda #8
  jsr listen
  lda #$6f
  jsr second
  ldx #0
.l\@
  lda \1, x
  jsr ciout
  inx
  cpx #\2
  bcc .l\@
  jsr unlsn
  .endm

  lda #$7f
  sta icr
  lda icr
.l0
  bit cry
  bpl .l0
  lda #11
  sta cry
 
  SENDCMD cmd1, cmd1len
  SENDCMD cmd2, cmd2len

  ; wait (22 * delay + 11) cycles

  lda #<delay
  sta tmp
  lda #>delay
  sta tmp+1
  sec
.l1
  lda tmp
  sbc #1
  sta tmp
  lda tmp+1
  sbc #0
  sta tmp+1
  ora tmp
  bne .l1

  lda #0
  sta st
  lda #8
  jsr talk
  lda #$6f
  jsr tksa
.nextin
  jsr acptr
  bit st
  bvs .eoi
  jsr chrout
  jmp .nextin
.eoi
  jsr untlk

  lda #27
  sta cry
  lda #$81
  sta icr
  rts

cmd1
  .byte 'M-W'
  .word $0300
  .byte 3
  jmp ($fffc)
cmd1len = *-cmd1
cmd2
  .byte 'M-E'
  .word $0300
cmd2len = *-cmd2
