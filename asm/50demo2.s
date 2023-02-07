	; Program to display an
	; arbitrary number of sprites
	; in the side border.
	; (PAL required)

	; Copyright 2004 Michiel Boland

	; Location 2 contains the
	; number of lines for which
	; the side border will be
	; opened.

fudgefac	= 26

nlines	= $02

irqvec	= $0314

viccry	= $d011
vicrc	= $d012
viccrx	= $d016
vicirq	= $d019
vicirqen	= $d01a

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
	lda #62
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

	lda #112
	sta nlines
	cli
	; Later addition - you can replace this part
	; with rts and remove everything from post onward
	; to get the original back.
	jmp post

delay:	ldy #7
l5:	dey
	bne l5
	nop
	rts

irq:	ldx nlines
	ldy #8
l6:	lda #7
l7:	cmp cia1tb
	bcc l7
	nop
	lda cia1tb
	sbc #56
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

	; Optional extra bits
	; to illustrate problem with multi-color sprite
	; at X-position $162
	; Also research true start of HBLANK (may vary between chip revs)

post	lda #sprite2>>6
	sta 2040
	lda #sprite>>6
	sta 2041
	lda #$3
	sta $d015
	sta $d010
	lda #2
	sta $d01c
	lda #122
	sta $d000
	lda #250
	sta $d001
	lda #114
	sta $d002
	lda #249
	sta $d003
	lda #0
	sta $d017
	sta $d01d
	sta $d021
	lda #12
	sta $d020
	lda #6
	sta $d025
	lda #2
	sta $d026
	lda #15
	sta $d027
	lda #5
	sta $d028
	rts

	.align 6
sprite
	.rept 7
	.byte 192,0,0
	.endr
	.rept 7
	.byte 128,0,0
	.endr
	.rept 7
	.byte 64,0,0
	.endr

	.align 6
sprite2
	.rept 7
	.byte 16,0,0
	.endr
	.rept 7
	.byte 32,0,0
	.endr
	.rept 7
	.byte 64,0,0
	.endr
