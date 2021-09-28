	; Programmable VIC-II effect
	; generator. (NTSC required.)

	; Copyright 2004 Michiel Boland

	; A 'program' consists of
	; sequences of four bytes:
	;  delay (low byte)
	;  delay (high byte)
	;  VIC-II register offset
	;  VIC-II register value

	; Location 2 contains the
	; number of instructions in
	; the program. The program
	; itself is in the tape buffer.

n	= 2
program	= $0340

irqvec	= $0314

vicbase	= $d000
viccry	= $d011
vicrc	= $d012
vicirq	= $d019
vicirqen	= $d01a

cia1tb	= $dc06
cia1icr	= $dc0d
cia1crb	= $dc0f

defirq	= $ea31

fudgefac	= 28

	.include "bootstrap.s"

start:	sei

	; Disable cia irqs.
	lda #$7f
	sta cia1icr
	; Clear pending cia interrupts
	; that might have been posted
	; during the last three
	; instructions.
	lda cia1icr

	; Program timer
	lda #64
	sta cia1tb
	lda #0
	sta cia1tb+1

	; Set raster on which to
	; interrupt.
	lda #240
	sta vicrc
	lda #27
	sta viccry

	; Create initial program
	lda #(eidata-idata)/4
	sta n
	ldx #0
p:	lda idata,x
	sta program,x
	inx
	cpx #eidata-idata
	bne p

	; Wait until the raster is 0
	; to make sure we are not in
	; any bad line situation for
	; at least a few lines.
	; Also, the vic delays reset
	; of the raster counter by 1
	; cycle when it moves from 311
	; to 0. Therefore it is vital
	; that our synchronise routine
	; is not executed while the
	; raster counter is zero.
notras0:	lda vicrc
	bne notras0

	; Synchronise to the raster
	; counter.
	lda vicrc
l0:	cmp vicrc
	beq l0
	jsr delay
	lda vicrc
	cmp vicrc
	bne l1
	bit 0
	nop
l1:	jsr delay
	lda vicrc
	cmp vicrc
	beq *+2
	beq *+2
	jsr delay
	lda vicrc
	cmp vicrc
	beq *+2

	; Load and start the timer.
	lda #$11
	sta cia1crb

	; Enable raster interrupts.
	lda #1
	sta vicirqen
	; Clear pending vic interrupts
	; to avoid spurious irq right
	; after we do a cli.
	sta vicirq

	lda #<irq
	sta irqvec
	lda #>irq
	sta irqvec+1

	cli
	rts

delay:	ldy #7
l5:	dey
	bne l5
	nop
	nop
	rts

irq:	lda cia1tb
	sec
	sbc #fudgefac
	; All official 6502 opcodes take
	; at most seven cycles. 
	; Delay a bit to sync with the
	; timer.
	lsr a
	bcs *+2
	lsr a
	bcs *+2
	bcs *+2
	lsr a
	bcc l6
	bit 0
	nop
l6:	ldy #0
	beq donep

doprog:	tya
	asl a
	asl a
	tax
	lda program+1,x
	beq quick
	nop
	; XXX - possibly inline the
	; bigdelay to get of rid of
	; write cycles.
next:	jsr bigdelay
	sec
	sbc #1
	bne next
quick:	lda program,x
	lsr a
	bcs *+2
	lsr a
	bcs *+2
	bcs *+2
	lsr a
	bcc urk
	bcs *+2
	nop
urk:	beq l12
	sec
l11:	bne *+2
	sbc #1
	bne l11

l12:	lda program+2,x
	sta hack+1
	lda program+3,x
hack:	sta vicbase

	iny
donep:	cpy n
	nop
	bne doprog

	lda #1
	sta vicirq
	jmp defirq

	; Delay 243 cycles.

bigdelay:	pha
	tya
	pha
	ldy #43
bd1:	dey
	bne bd1
	bit 0
	pla
	tay
	pla
	rts

	; A sample program to illustrate
	; DMA-delay
idata:	.word 0
	.byte 17,28
	.word 44
	.byte 17,27
eidata:
