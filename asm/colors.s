  .include "bootstrap.s"

viccry   = 53265
vicrc    = 53266
vicirq   = 53273
vicirqm  = 53274
vicec    = 53280
vicbc    = 53281

joy      = $dc00

  lda #12
  sta vicec
  sta vicbc
  lda #0
  sta 251
  sta 253
  lda #4
  sta 252
  lda #216
  sta 254
  ldx #0
l2
  ldy #39
l1
  lda #160
  sta (251),y
  txa
  sta (253),y
  dey
  bpl l1
  inx
  cpx #16
  beq end
  lda 251
  clc
  adc #40
  sta 251
  lda 252
  adc #0
  sta 252
  lda 253
  clc
  adc #40
  sta 253
  lda 254
  adc #0
  sta 254
  jmp l2
end
  sei
  lda #<nmi
  sta $fffa
  lda #>nmi
  sta $fffb
  lda #<rst
  sta $fffc
  lda #>rst
  sta $fffd
  lda #<irq
  sta $fffe
  lda #>irq
  sta $ffff
  lda #$7f
  sta $dc0d
  lda $dc0d
  lda raster
  sta vicrc
  lda #27
  sta viccry
  lda #1
  sta vicirqm
  sta vicirq
  lda #$35
  sta 1
  ldx #11
  cli
loop
  bne loop
nmi
  lda #$37
  sta 1
  brk
rst
  lda #$37
  sta 1
  jmp ($fffc)
irq
  lda joy
  cmp joy
  bne irq
  sta joytmp
  lda #1
  bit joytmp
  bne noup
  lda raster
  cmp rmin
  bne .l1
  lda raster + 1
  cmp rmin + 1
  beq noup
.l1
  lda raster
  sec
  sbc #1
  sta raster
  lda raster + 1
  sbc #0
  sta raster + 1
noup
  lda #2
  bit joytmp
  bne nodown
  lda raster
  cmp rmax
  bne .l1
  lda raster + 1
  cmp rmax + 1
  beq nodown
.l1
  lda raster
  clc
  adc #1
  sta raster
  lda raster + 1
  adc #0
  sta raster + 1
nodown
  lda #4
  bit joytmp
  bne noleft
  lda raster
  and #$fe
  sta raster
noleft
  lda #8
  bit joytmp
  bne noright
  lda raster
  ora #$01
  sta raster
noright
  lda raster
  sta vicrc
  lda raster + 1
  lsr
  ror
  ora #27
  sta viccry
  lda vicrc
.l1
  cmp vicrc
  beq .l1
  lda vicrc
.l2
  cmp vicrc
  beq .l2
  lsr vicirq
  rti
raster
  .word 51
rmin
  .word 0
rmax
  ; safe for ntsc
  .word 262
joytmp
  .byte 255
