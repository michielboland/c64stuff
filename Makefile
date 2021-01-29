PRG=crunch.prg border.prg sprite.prg sp.prg xhak.prg bc.prg colors.prg pal.prg \
	motion.prg square.prg blank.prg joytest.prg 50demo2.prg 50demo3.prg \
	colorbars.prg
DEPENDS=bootstrap.s
all: $(PRG)
$(PRG): $(DEPENDS)
.PHONY: clean
%.prg: %.s
	vasm6502_oldstyle -dotdir -Fbin -o $@ $<
clean:
	rm -f $(PRG)
