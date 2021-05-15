PRG=crunch.prg border.prg sprite.prg sp.prg xhak.prg bc.prg colors.crt pal.prg \
	motion.prg square.prg blank.prg joytest.prg 50demo2.prg 50demo3.prg \
	colorbars.prg fullcolorbars.prg color-squares.crt sprite_dma.prg \
	comp.prg
DEPENDS=bootstrap.s
all: $(PRG)
$(PRG): $(DEPENDS)
.PHONY: clean
%.prg: %.s
	vasm6502_oldstyle -dotdir -Fbin -o $@ $<
color-squares.crt: color-squares.prg
	cartconv -t ulti -i $< -o $@
colors.crt: colors.prg
	cartconv -t ulti -i $< -o $@
clean:
	rm -f *.prg *.crt
