	; Program to display an
	; arbitrary number of sprites
	; in the side border.
	; (NTSC required)

	; Copyright 2004 Michiel Boland

	; Location 2 contains the
	; number of lines for which
	; the side border will be
	; opened.

nlines	= $02

irqvec	= $0314

viccry	= $d011
vicrc	= $d012
viccrx	= $d016
vicirq	= $d019
vicirqen	= $d01a
vicec	= $d020

cia1tb	= $dc06
cia1icr	= $dc0d
cia1crb	= $dc0f

defirq	= $ea31

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
	lda #249
	sta vicrc
	lda #27
	sta viccry

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

	; Hack
	ldy #2
ld:	dey
	bne ld
	nop
	nop

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

	; Program IRQ vector.
	lda #<irq
	sta irqvec
	lda #>irq
	sta irqvec+1

	lda #64
	sta nlines
	cli
	rts

delay:	ldy #7
l5:	dey
	bne l5
	nop
	nop
	rts

irq:	ldx nlines
	ldy #8
l6:	lda #7
l7:	cmp cia1tb
	bcc l7
	nop
	lda cia1tb
	sbc #58
	lsr a
	bcs *+2
	lsr a
	bcs *+2
	bcs *+2
	lsr a
	bcc l8
	bit 0
	nop
	; Open the side border.
	; DEC/INC is needed rather
	; than simple store instructions
	; to make things work when
	; sprite 0 is active.
l8:	dec viccrx
	sty viccrx
	dex
	bne l6
	lda #1
	sta vicirq
	jmp defirq
