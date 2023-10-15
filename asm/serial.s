  .include "bootstrap.s"

drive  = 9
sec    = $6f

max_track = 40

; temp storage for print_hex
phtmp  = 2
st     = $90
mapptr = $a7

; burst cmd status
bst    = $fa

; buffer pointer for send_drive_cmd
scbuf  = $fb
; buffer pointer for recv_burst_data
rbbuf  = $fb
; length of string to send to drive
sclen  = $fd
; buffer size fo recv_burst_data
rbsize = $fd

sector_buf = $c000
chs_map    = $c200 ; track/head/sector/status

strout = $ab1e

ta1    = $dc04
sdr1   = $dc0c
icr1   = $dc0d
cra1   = $dc0e
pra2   = $dd00

reu_command  = $df01
reu_c64base  = $df02
reu_reubase  = $df04
reu_translen = $df07
reu_control  = $df0a

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
  lda #<\1
  ldy #>\1
  jsr strout
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

  .macro RECV_BURST
  lda #<\1
  sta rbbuf
  lda #>\1
  sta rbbuf+1
  lda #<\2
  sta rbsize
  lda #>\2
  sta rbsize+1
  jsr recv_burst_data
  .endm

  .macro TOGGLE_CLK
  lda pra2
  eor #$10 ; toggle clock
  sta pra2
  .endm

  .macro PUTC
  lda #\1
  jsr chrout
  .endm

  jsr send_burst
  SEND_CMD query_disk_format_cmd, 3
  jsr recv_burst_cmd_status
  bcc .ok
  jmp burst_error
.ok
  bit bst
  bmi .mfm
  PRINT gcr_disk
  jmp ioinit
.mfm
  RECV_BURST disk_format_buf, 6
  lda disk_format_buf
  and #$30
  cmp #$20
  beq .l0
  PRINT not_a_512_byte_sector_disk
  rts
.l0
  lda disk_format_buf + 1
  cmp #9
  beq .l1
  PRINT not_9_sectors_per_track
  rts
.l1
  SEND_CMD sector_interleave_cmd,4 ; is this necessary?

read_all_sectors
  ; re-initialize parameters, in case of re-run
  lda #0
  sta head
  sta track
  sta next_track
  sta reubase
  sta reubase+1
  sta reubase+2
  sta has_errors
  lda #1
  sta sector
  lda #<chs_map
  sta mapptr
  lda #>chs_map
  sta mapptr+1
.next_head_track
  lda #9+1
  sec
  sbc sector
  cmp #2+1
  bcc .l0
  lda #2 ; for some reason, loading more than 2 sectors does not work
.l0
  sta nsectors
  SEND_CMD read_cmd, 7
.next_sector
  lda nsectors
  beq .next_head_track
  dec nsectors
  jsr print_track
  jsr recv_burst_cmd_status
  bcs .err
  RECV_BURST sector_buf, 512
  jsr copy_sector_buf_to_reu
  jmp .l1
.err
  lda #1
  sta has_errors
  jsr skip_sector_in_reu
  lda #0
  sta nsectors
.l1
  PUTC 13
  jsr update_map
  jsr next
  bcc .next_sector
  jsr write_map_to_reu
  lda has_errors
  beq .l2
  lda #10
  .byte $2c
.l2
  lda #13
  sta $d020
  rts

burst_error
  jsr print_hex
  PUTC ' '
  jsr ioinit
  jmp recv_and_print_drive_status

print_track
  lda track
  jsr print_hex
  lda head
  jsr print_hex
  lda sector
  jmp print_hex

update_map
  ldy #0
  lda track
  sta (mapptr),y
  iny
  lda head
  sta (mapptr),y
  iny
  lda sector
  sta (mapptr),y
  iny
  lda bst
  sta (mapptr),y
  lda mapptr
  clc
  adc #4
  sta mapptr
  bcc .l0
  inc mapptr+1
.l0
  rts

next
  ldx sector
  cpx #9
  inx
  bcc .l1
  ldx #1
  stx sector
  lda head
  eor #$10
  sta head
  bne .l2
  ldx track
  inx
  cpx #max_track
  bcc .l3
  rts
.l3
  stx track
  stx next_track
  rts
.l1
  stx sector
  rts
.l2
  clc
  rts

send_burst
  sei
  lda #$7f
  sta icr1 ; disable CIA interrupts
  bit icr1
  cli
  lda #0
  sta ta1+1
  lda #4
  sta ta1
  lda cra1
  and #$80
  ora #$55 ; timer A CNT
  sta cra1
  lda #$ff
  sta sdr1 ; send one byte
  lda #$08
.l0
  bit icr1 ; wait until byte is sent (perhaps not strictly needed)
  beq .l0
  jmp ioinit

recv_burst_cmd_status
  sei
  lda #$7f
  sta icr1
  bit icr1
  cli
  TOGGLE_CLK
  lda #$08
.l0
  bit icr1
  beq .l0
  lda sdr1
  sta bst
  and #$0f
  cmp #2
  rts

recv_burst_data
  ldy #0
.next
  lda rbsize
  bne .l0
  lda rbsize+1
  bne .l1
  jmp ioinit
.l1
  dec rbsize+1
.l0
  dec rbsize
  TOGGLE_CLK
  lda #$08
.l2
  bit icr1
  beq .l2
  lda sdr1
  inc $d020 ; debug
  sta (rbbuf),y
  inc rbbuf
  bne .next
  inc rbbuf+1
  jmp .next

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
  pla
  tax
  lda phtmp

copy_sector_buf_to_reu
  lda #0
  sta reu_control
  lda #<sector_buf
  sta reu_c64base
  lda #>sector_buf
  sta reu_c64base+1
  lda reubase
  sta reu_reubase
  lda reubase+1
  sta reu_reubase+1
  lda reubase+2
  sta reu_reubase+2
  lda #<512
  sta reu_translen
  lda #>512
  sta reu_translen+1
  lda #%10010000 ; c64 -> REU with immediate execution
  sta reu_command
skip_sector_in_reu
  lda reubase
  clc
  adc #<512
  sta reubase
  lda reubase+1
  adc #>512
  sta reubase+1
  lda reubase+2
  adc #0
  sta reubase+2
  rts

write_map_to_reu
  lda #0
  sta reu_control
  lda #<chs_map
  sta reu_c64base
  lda #>chs_map
  sta reu_c64base+1
  lda reubase
  sta reu_reubase
  lda reubase+1
  sta reu_reubase+1
  lda reubase+2
  sta reu_reubase+2
  lda mapptr
  sec
  sbc #<chs_map
  sta reu_translen
  lda mapptr+1
  sbc #>chs_map
  sta reu_translen+1
  lda #%10010000 ; c64 -> REU with immediate execution
  sta reu_command
  rts

gcr_disk
  .byte 'GCR DISK',13,0
not_a_512_byte_sector_disk
  .byte 'NOT A 512 BYTE PER SECTOR DISK',13,0
not_9_sectors_per_track
  .byte 'NOT 9 SECTORS PER TRACK',13,0
hexchars
  .byte '0123456789ABCDEF'
read_cmd
  .byte 'U0'
  .byte 0 ; side 0 ( $10 = side 1 )
  .byte 0 ; track
  .byte 1 ; sector
  .byte 0 ; # sectors
  .byte 0 ; next track
head       = read_cmd + 2
track      = read_cmd + 3
sector     = read_cmd + 4
nsectors   = read_cmd + 5
next_track = read_cmd + 6
inquire_disk_cmd
  .byte 'U0',%00000100,0
query_disk_format_cmd
  .byte 'U0',%00001010,0
sector_interleave_cmd
  .byte 'U0',%00001000,1
disk_format_buf
  .byte 0 ; burst status byte (from offset track)
  .byte 0 ; number of sectors (per track)
  .byte 0 ; logical track number
  .byte 0 ; minimum sector
  .byte 0 ; maximum sector
  .byte 0 ; interleave
reubase
  .byte 0
  .byte 0
  .byte 0
has_errors
  .byte 0
