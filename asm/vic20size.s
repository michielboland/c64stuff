  .include "vic20bootstrap.s"

tmp      = 251
c        = 252

via1pra  = $9111
via1ddra = $9113
via2prb  = $9120
via2ddrb = $9122

  ldy #0
cls
  lda #160
  sta $1e00,y
  sta $1f00,y
  tya
  asl
  rol
  rol
  and #3
  sta $9600,y
  ora #4
  sta $9700,y
  iny
  bne cls

  sei
  lda #<irq
  sta $0314
  lda #>irq
  sta $0315
  cli

loop
  jmp loop

irq
  inc c
  lda #$0f
  bit c
  beq read
  jmp $eabf
read
  lda via1ddra
  sta ddrasave
  lda via2ddrb
  sta ddrbsave
  lda #0
  sta via1ddra
  sta via2ddrb
  lda via1pra
  lsr
  lsr
  lsr
  ror joy_up
  lsr
  ror joy_down
  lsr
  ror joy_left
  lsr
  ror joy_fire
  lda via2prb
  asl
  ror joy_right
  lda ddrasave
  sta via1ddra
  lda ddrbsave
  sta via2ddrb

  bit joy_up
  bmi test_down
  bit joy_fire
  bpl up_fire
  ; move screen up
  ldx $9001
  beq test_down
  dex
  stx $9001
  jmp test_down
up_fire
  ; decrease #rows
  lda $9003
  tax
  and #$81
  sta tmp
  txa
  and #$7e
  lsr
  beq test_down
  sbc #0
  asl
  ora tmp
  sta $9003
test_down
  bit joy_down
  bmi test_left
  bit joy_fire
  bpl down_fire
  ; move screen down
  ldx $9001
  inx
  beq test_left
  stx $9001
  jmp test_left
down_fire
  ; increase #rows
  lda $9003
  tax
  and #$81
  sta tmp
  txa
  and #$7e
  lsr
  adc #1
  cmp #$40
  bcs test_left
  asl
  ora tmp
  sta $9003
test_left
  bit joy_left
  bmi test_right
  bit joy_fire
  bpl left_fire
  ; move screen left
  lda $9000
  tax
  and #$80
  sta tmp
  txa
  and #$7f
  beq test_right
  tax
  dex
  txa
  ora tmp
  sta $9000
  jmp test_right
left_fire
  ; decrease #columns
  lda $9002
  tax
  and #$80
  sta tmp
  txa
  and #$7f
  beq test_right
  tax
  dex
  txa
  ora tmp
  sta $9002
test_right
  bit joy_right
  bmi done
  bit joy_fire
  bpl right_fire
  ; move screen right
  lda $9000
  tax
  and #$80
  sta tmp
  txa
  and #$7f
  cmp #$7f
  bcs done
  adc #1
  ora tmp
  sta $9000
  jmp done
right_fire
  ; increase #columns
  lda $9002
  tax
  and #$80
  sta tmp
  txa
  and #$7f
  cmp #$7f
  bcs done
  adc #1
  ora tmp
  sta $9002
done
  jmp $eabf

ddrasave  .byte 0
ddrbsave  .byte 0
joy_up    .byte 0
joy_down  .byte 0
joy_left  .byte 0
joy_right .byte 0
joy_fire  .byte 0
