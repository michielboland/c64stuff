PRG=crunch.prg sprite.prg sp.prg xhak.prg bc.prg colors.prg pal.prg \
	motion.prg square.prg blank.prg joytest.prg 50demo2.prg 50demo3.prg \
	colorbars.prg fullcolorbars.prg sprite_dma.prg comp.prg bump.prg \
	50demo2_ntsc.prg 50demo3_ntsc.prg greydots.prg sprite_addr_tester.prg \
	lptest_ntsc.prg sp_ntsc.prg coltest.prg colorbars-alt.prg \
	joytest_ntsc.prg sweep.prg filter_adjust.prg serial.prg \
	calibration-image.prg calibration-image_ntsc.prg confused.prg \
	confused_ntsc.prg combined_wave.prg filter_log_sweep.prg \
	filter_log_sweep_ntsc.prg log_sweep.prg log_sweep_ntsc.prg mix.prg \
	raster.prg raster_ntsc.prg sprite_mc.prg sprite_mc_ntsc.prg \
	stripes.prg
CRT=color-squares.crt vicii-registers.crt test5.crt sprite_max_coltest.crt \
	vsp_tester.crt lptest2.crt vsp_tester_ntsc.crt maxtest.crt fringe.crt
VIC20PRG=vic20colors.prg vic20colorbars.prg vic20colorbars_ntsc.prg \
	vic20colors_ntsc.prg vic20rasterscan.prg vic20rasterscan_ntsc.prg \
	vic20size.prg vic20mix.prg vic20bar-glitch.prg \
	vic20bar-glitch_ntsc.prg
DEPENDS=bootstrap.s
VIC20DEPENDS=vic20bootstrap.s
all: prg crt vic20prg
prg: $(PRG)
crt: $(CRT)
vic20prg: $(VIC20PRG)
$(PRG): $(DEPENDS)
$(VIC20PRG): $(VIC20DEPENDS)
bump.prg: bump_sprite_data.s
.PHONY: clean all prg crt vic20prg
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
serial.prg filter_adjust.prg: input_byte.s
vsp_tester_ntsc.prg: vsp_tester.s
joytest_ntsc.prg: joytest.s
raster_ntsc.prg: raster.s
vic20colorbars_ntsc.prg: vic20colorbars.s
vic20bar-glitch_ntsc.prg: vic20bar-glitch.s
vic20colors_ntsc.prg: vic20colors.s
sprite_mc_ntsc.prg: sprite_mc.s
filter_log_sweep.prg: generated/filter_log_sweep_table.s
filter_log_sweep_ntsc.prg: filter_log_sweep.s \
	generated/filter_log_sweep_table_ntsc.s
log_sweep.prg: generated/log_sweep_table.s
log_sweep_ntsc.prg: log_sweep.s generated/log_sweep_table_ntsc.s
generated/filter_log_sweep_table.s: generate_log_sweep_table.py
	mkdir -p generated/
	python3 $< > $@
generated/filter_log_sweep_table_ntsc.s: generate_log_sweep_table.py
	mkdir -p generated/
	python3 $< --ntsc > $@
generated/log_sweep_table.s: generate_log_sweep_table.py log_sweep_table.args
	mkdir -p generated/
	python3 $< `cat log_sweep_table.args` > $@
generated/log_sweep_table_ntsc.s: generate_log_sweep_table.py log_sweep_table.args
	mkdir -p generated/
	python3 $< `cat log_sweep_table.args` --ntsc > $@
clean:
	rm -rf *.prg *.crt generated/
