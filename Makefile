PRG=crunch.prg border.prg sprite.prg sp.prg
DEPENDS=bootstrap.s
all: $(PRG)
$(PRG): $(DEPENDS)
.PHONY: clean
%.prg: %.s
	vasm6502_oldstyle -dotdir -Fbin -o $@ $<
clean:
	rm -f $(PRG)
