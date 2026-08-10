  .include "vic20bootstrap.s"

cr0 = $9000
cr1 = $9001
cr2 = $9002
cr3 = $9003
cr4 = $9004
crf = $900f

  ; workaround for NTSC pivic with PAL ROM
  lda #5
  sta cr0
  lda #25
  sta cr1
  sei
  lda #<isr
  sta $0314
  lda #>isr
  sta $0315
  cli
  rts

isr
  ldx #$0b
  lda #60 ; roughly halfway down the screen
.l0
  cmp cr4
  bne .l0
.l1
  cmp cr4
  beq .l1
  
  ; LSB of raster counter is now guaranteed to be zero
  jsr delay ; delay 62 cycles
  bit cr3
  bmi .l
  bit 0
  nop
.l:
  jsr delay
  bit cr3
  bmi *+2
  bmi *+2
  jsr delay
  bit cr3
  bpl *+2

  stx crf
  ldx #$1b
  stx crf
  jmp $eabf

delay:
  ldy #8
.l
  dey
  bne .l
  bit 0
  rts
