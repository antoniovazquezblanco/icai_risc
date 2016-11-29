PROJECT = ICAI_RISC
PROJECT_TOP = TopLevel
PROJECT_FAMILY = "Cyclone II"
PROJECT_DEVICE = EP2C20F484C7
PROJECT_BOARD = DE1Pins
PROJECT_FLAGS =
SRCS = $(wildcard src/*.src.vhd)
SRCS_ROM = src/ROMC1.vhd
SRCS_ROM += src/ROMC2.vhd
SRCS += $(SRCS_ROM)
TESTS = $(wildcard src/*.tst.vhd)
TEST_ENTITIES = $(addsuffix _vhd_tst, $(basename $(basename $(notdir $(TESTS)))))
ASSIGNMENT_FILES = $(PROJECT).qpf $(PROJECT).qsf
export PATH := /opt/altera/modelsim_ase/bin:$(PATH)


ifeq ($(shell uname -p),x86_64)
	PROJECT_FLAGS += --64bit
endif

.PHONY = all clean map fit asm sta program test prj rom

all: prj map fit asm sta

rom: $(SRCS_ROM)

prj: $(ASSIGNMENT_FILES)

map: $(PROJECT).map.rpt

fit: $(PROJECT).fit.rpt

asm: $(PROJECT).asm.rpt

sta: $(PROJECT).sta.rpt

$(ASSIGNMENT_FILES):
	quartus_sh --prepare -f $(PROJECT_FAMILY) -d $(PROJECT_DEVICE) -t $(PROJECT_TOP) $(PROJECT)
	-cat src/$(PROJECT_BOARD) >> $(PROJECT).qsf

$(PROJECT).map.rpt: $(SRCS) $(ASSIGNMENT_FILES)
	quartus_map --read_settings_files=on $(addprefix --source=,$(SRCS)) $(PROJECT)

$(PROJECT).fit.rpt: $(PROJECT).map.rpt
	quartus_fit --read_settings_files=on --part=$(PROJECT_DEVICE) $(PROJECT)

$(PROJECT).asm.rpt: $(PROJECT).fit.rpt
	quartus_asm $(PROJECT)

$(PROJECT).sta.rpt: $(PROJECT).fit.rpt
	quartus_sta $(PROJECT)

src/%.vhd:	src/%.S
	icai_risc_as $< -f vhdl -o $@

run:	all
	quartus_pgm --no_banner --mode=jtag -o "P;$(PROJECT).sof"

program: all
	quartus_cpf -c -d EPCS4 $(PROJECT).sof $(PROJECT).pof
	quartus_pgm --no_banner --mode=as -o "P;$(PROJECT).pof"

clean:
	rm -rf *~ src/ROMC*.vhd db/ incremental_db/ $(ASSIGNMENT_FILES) *.rpt $(PROJECT)* work/ vsim.wlf transcript src/*.bak

test:	$(TESTS) $(SRCS)
	export PATH="$$PATH:/opt/altera/modelsim_ase/bin"
	vlib work
	vcom -work work $(SRCS) $(TESTS)
	for entity in $(TEST_ENTITIES); do \
		if [ "$$entity" == "TopLevel_vhd_tst" ]; then \
			continue; \
		fi; \
		vsim work.$$entity -c -do "when -label end_sim {end_sim == '1'} {stop; exit -f;}; run -all;"; \
	done

gtest:	$(TESTS) $(SRCS)
	export PATH="$$PATH:/opt/altera/modelsim_ase/bin"
	vlib work
	vcom -work work $(SRCS) $(TESTS)
	for entity in $(TEST_ENTITIES); do \
		vsim work.$$entity -do "when -label end_sim {end_sim == '1'} {stop; exit -f;}; add wave sim:/$$entity/*; run -all;"; \
	done

toptest:
	export PATH="$$PATH:/opt/altera/modelsim_ase/bin"
	vlib work
	vcom -work work $(SRCS) $(TESTS)
	vsim work.TopLevel_vhd_tst -do "add wave sim:/TopLevel_vhd_tst/*; run -all;";
