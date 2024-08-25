PRG=crunch.prg border.prg sprite.prg sp.prg xhak.prg bc.prg colors.prg pal.prg \
	motion.prg square.prg blank.prg joytest.prg 50demo2.prg 50demo3.prg \
	colorbars.prg fullcolorbars.prg color-squares.crt sprite_dma.prg \
	comp.prg bump.prg vicii-registers.crt vic20colors.prg \
	vic20colorbars.prg vic20colorbars_ntsc.prg vic20colors_ntsc.prg \
	vic20rasterscan.prg vic20rasterscan_ntsc.prg 50demo2_ntsc.prg \
	50demo3_ntsc.prg vic20size.prg test5.crt sprite_max_coltest.crt \
	vsp_tester.crt vic20mix.prg greydots.prg sprite_addr_tester.prg \
	lptest_ntsc.prg sp_ntsc.prg lptest2.crt vsp_tester_ntsc.crt \
	coltest.prg maxtest.crt colorbars-alt.prg fringe.crt joytest_ntsc.prg \
	sweep.prg filter_adjust.prg serial.prg calibration-image.prg \
	calibration-image_ntsc.prg confused.prg confused_ntsc.prg \
	combined_wave.prg
DEPENDS=bootstrap.s
all: $(PRG)
$(PRG): $(DEPENDS)
bump.prg: bump_sprite_data.s
.PHONY: clean
%.prg: %.s
	vasm6502_oldstyle -dotdir -Fbin -o $@ $<
%.crt: %.prg
	cartconv -t ulti -i $< -o $@
vsp_tester.crt: vsp_tester.prg
	cartconv -t normal -i $< -o $@
vsp_tester_ntsc.crt: vsp_tester_ntsc.prg
	cartconv -t normal -i $< -o $@
50demo2_ntsc.prg: 50demo2.s
50demo3_ntsc.prg: 50demo3.s
calibration-image_ntsc.prg: calibration-image.s
confused_ntsc.prg: confused.s
vsp_tester_ntsc.prg: vsp_tester.s
joytest_ntsc.prg: joytest.s
clean:
	rm -f *.prg *.crt
