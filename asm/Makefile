PRG=crunch.prg border.prg sprite.prg sp.prg xhak.prg bc.prg colors.prg pal.prg \
	motion.prg square.prg blank.prg joytest.prg 50demo2.prg 50demo3.prg \
	colorbars.prg fullcolorbars.prg color-squares.crt sprite_dma.prg \
	comp.prg bump.prg vicii-registers.crt vic20colors.prg \
	vic20colorbars.prg vic20colorbars_ntsc.prg
DEPENDS=bootstrap.s
all: $(PRG)
$(PRG): $(DEPENDS)
bump.prg: bump_sprite_data.s
.PHONY: clean
%.prg: %.s
	vasm6502_oldstyle -dotdir -Fbin -o $@ $<
color-squares.crt: color-squares.prg
	cartconv -t ulti -i $< -o $@
vicii-registers.crt: vicii-registers.prg
	cartconv -t ulti -i $< -o $@
clean:
	rm -f *.prg *.crt
