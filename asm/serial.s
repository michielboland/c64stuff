; A program to read MS-DOS floppies with a 1571 and an Ultimate64.
; This requires burst mode on CIA1 and a 512K REU.
; To speed up the transfer you probably also should disable VIC-II badlines.
;
; Once read the contents of the REU can be saved to storage.
; The first 368640 bytes contain the disk image.
; These are followed by 2880 status bytes, four for each sector
; (track/head/sector/status)
;
; The program will print a dot for a good read or an E for a bad sector.
; After each track it will report how long the transfer has taken thus far.
; At the end of the transfer you will see how long the transfer took in
; total. The time to transfer an entire disk should be slightly less than
; two minutes. This is still relatively slow, but probably the best one
; can do without custom drive code.
;
; The border will turn green if the transfer was a complete success.
; If one or more read errors occurred, the border will turn red at the end.

  .include "bootstrap.s"

; Assume 1571 is device #9 - change the number here, or set the device #
; using the switches on the back of the drive.

drive  = 9

; For now we only support standard 9 sectors/track, 512 bytes/sector disks

sectors_per_track = 9
sector_size = 512

; We can only transfer one sector at a time. In theory the transfer could
; be made faster if we can get te 1571 to read and send a complete track
; in one go, but that would require custom code on the drive.
; The best we can do for now is use software interleaving to take into
; account that sectors are lost while we are transferring data to the host.

interleave = 4

; secondary address (used after TALK/LISTEN)
chan15 = $6f

; MS-DOS disks contain 9 * 2 * 40 = 720 sectors.

max_track = 40

; Zero page storage

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

; Other memory locations

; PAL/NTSC flag (used to initialize the TOD clock)
palnts  = $02a6

sector_buf = $c000
chs_map    = $c200 ; track/head/sector/status

; The status byte will be $a1 for a good sector, something greater than
; that for a bad sector.
; We currently do not retry reading a bad sector.
; Instead we just skip and move to the next sector.
; Bad sectors are filled with $37 ('7') so you can easily spot these.
; TODO - status 2 probably means the entire track is bad, and 
; we should just skip the entire track instead of trying to read
; every sector of that track.

; Useful BASIC function

strout = $ab1e

; CIA registers

ta1     = $dc04
todten1 = $dc08
todsec1 = $dc09
todmin1 = $dc0a
todhr1  = $dc0b
sdr1    = $dc0c
icr1    = $dc0d
cra1    = $dc0e
pra2    = $dd00

; REU registers

reu_command  = $df01
reu_c64base  = $df02
reu_reubase  = $df04
reu_translen = $df07
reu_control  = $df0a

; KERNAL routines

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

; Program starts here

  jsr send_burst
  SEND_CMD query_disk_format_cmd, 3
  jsr recv_burst_cmd_status
  bcc .ok
  jmp burst_error
.ok
  bit bst
  bmi .mfm
  PRINT gcr_disk
  jmp exit
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
  cmp #sectors_per_track
  beq .l1
  PRINT not_9_sectors_per_track
  rts
.l1
  SEND_CMD sector_interleave_cmd,4
  jsr timer_start

read_all_sectors
  ; re-initialize parameters, in case of re-run
  lda #0
  sta head
  sta track
  sta next_track
  sta reupage
  sta reupage+1
  sta has_errors
  lda #1
  sta sector
  lda #<chs_map
  sta mapptr
  lda #>chs_map
  sta mapptr+1
.next_head_track
  lda #sectors_per_track
  sta nsectors
.next_read
  lda #0
  sta last_sector_errored
  SEND_CMD read_cmd, 7
.next_sector
  lda nsectors
  beq .next_head_track
  lda last_sector_errored
  bne .next_read
  dec nsectors
  jsr recv_burst_cmd_status
  bcs .err
  PUTC '.'
  RECV_BURST sector_buf, sector_size
  jsr copy_sector_buf_to_reu
  jmp .l1
.err
  PUTC 'E'
  lda #1
  sta has_errors
  sta last_sector_errored
  jsr skip_sector_in_reu
.l1
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
exit
  jmp ioinit

burst_error
  jsr print_hex
  PUTC ' '
  jmp recv_and_print_drive_status

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
  dex
  txa
  clc
  adc #interleave
  cmp #sectors_per_track
  bcc .l0
  sbc #sectors_per_track
.l0
  tax
  inx
  stx sector
  cpx #1
  bne .l2
  lda reupage
  clc
  adc #sectors_per_track*2
  sta reupage
  lda reupage+1
  adc #0
  sta reupage+1
  lda head
  eor #$10
  sta head
  bne .l2
  jsr timer_print
  ldx track
  inx
  cpx #max_track
  bcc .l3
  rts
.l3
  stx track
  stx next_track
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
  bit icr1 ; wait until byte is sent
  beq .l0
  rts

recv_burst_cmd_status
  lda burst_mode
  bne .l1
  sei
  lda #$7f
  sta burst_mode
  sta icr1
  bit icr1
  cli
  TOGGLE_CLK
.l1
  lda #$08
.l0
  bit icr1
  beq .l0
  ldx sdr1
  TOGGLE_CLK
  txa
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
  rts
.l1
  dec rbsize+1
.l0
  dec rbsize
  lda #$08
.l2
  bit icr1
  beq .l2
  ldx sdr1
  TOGGLE_CLK
  txa
  sta (rbbuf),y
  inc rbbuf
  bne .next
  inc rbbuf+1
  jmp .next

send_drive_cmd
  jsr clear_burst_mode
  lda #0
  sta st
  lda #drive
  jsr listen
  lda #chan15
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
  bne .nextout
  jmp unlsn
.dnp
  ldx #5 ; device not present error
  jmp ($0300)

recv_and_print_drive_status
  jsr clear_burst_mode
  lda #drive
  jsr talk
  lda #chan15
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
  rts

skip_sector_in_reu
  lda #$80 ; fix C64 address
  sta reu_control
  lda #$37 ; fill pattern to indicate error
  sta sector_buf
  bne reu_shared
copy_sector_buf_to_reu
  lda #0
  sta reu_control
reu_shared
  lda #<sector_buf
  sta reu_c64base
  lda #>sector_buf
  sta reu_c64base+1
  lda #0
  sta reu_reubase
  lda sector
  sec
  sbc #1
  asl a
  adc reupage
  sta reu_reubase+1
  lda #0
  adc reupage+1
  sta reu_reubase+2
  lda #<sector_size
  sta reu_translen
  lda #>sector_size
  sta reu_translen+1
  lda #%10010000 ; c64 -> REU with immediate execution
  sta reu_command
  rts

write_map_to_reu
  lda #0
  sta reu_control
  lda #<chs_map
  sta reu_c64base
  lda #>chs_map
  sta reu_c64base+1
  lda #0
  sta reu_reubase
  lda reupage
  sta reu_reubase+1
  lda reupage+1
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

clear_burst_mode
  lda #0
  sta burst_mode
  jsr ioinit
  ; 50/60Hz bit will be butchered by ioinit above
  jmp fix_tod

timer_start
  lda #$10
  sta todhr1
  lda #0
  sta todmin1
  sta todsec1
  sta todten1
  lda todten1
fix_tod
  lda palnts
  lsr a
  lda cra1
  bcs .pal
  and #$7f
  .byte $2c
.pal
  ora #$80
  sta cra1
  rts

timer_print
  lda todhr1
  lda todmin1
  jsr print_hex
  PUTC ':'
  lda todsec1
  jsr print_hex
  PUTC '.'
  lda todten1
  ora #'0'
  jsr chrout
  PUTC 13
  PUTC $91
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
  .byte 'U0',%00001000,interleave
disk_format_buf
  .byte 0 ; burst status byte (from offset track)
  .byte 0 ; number of sectors (per track)
  .byte 0 ; logical track number
  .byte 0 ; minimum sector
  .byte 0 ; maximum sector
  .byte 0 ; interleave
reupage
  .byte 0
  .byte 0
has_errors
  .byte 0
burst_mode
  .byte 0
last_sector_errored
  .byte 0
