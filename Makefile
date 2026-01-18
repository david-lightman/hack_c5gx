# -------------------------------------------------------------------------- #
# Makefile for Nand2Tetris FPGA (Cyclone V) Project
# Uses Quartus Standard Flow
# -------------------------------------------------------------------------- #

# Project Name (Must match your .qpf/.qsf filename without extension)
PROJECT := n2t_c5gx
TOP_LEVEL := baseline_c5gx

# Simulation
TESTBENCH := tb_soc2
SIM_DIR := simulation
SIM_TOOL := vsim

# Quartus Executables
QUARTUS_SH := quartus_sh
QUARTUS_PGM := quartus_pgm
VSIM := vsim
VLOG := vlog
VLIB := vlib

# Output Directory (Standard Quartus output)
OUTPUT_DIR := output_files
SOF_FILE := $(OUTPUT_DIR)/$(PROJECT).sof

# -------------------------------------------------------------------------- #
# Targets
# -------------------------------------------------------------------------- #

.PHONY: all make clean sim sim-gui upload help

# Default Target
all: make

help:
	@echo "Available targets:"
	@echo "  make       : Run full compilation (Synthesis, Fitting, Assembly, Timing)"
	@echo "  clean      : Clean project databases and temporary files"
	@echo "  sim        : Run batch simulation (ModelSim/Questa)"
	@echo "  sim-gui    : Run GUI simulation (ModelSim/Questa)"
	@echo "  upload     : Program the FPGA (requires .sof file)"

# -------------------------------------------------------------------------- #
# Compilation (Using Standard Flow)
# -------------------------------------------------------------------------- #

# Run the standard "compile" flow (Syn -> Fit -> Asm -> Timing)
make: $(SOF_FILE)

$(SOF_FILE): *.v *.qsf
	@echo "Starting Quartus Compilation Flow..."
	$(QUARTUS_SH) --flow compile $(PROJECT)

# -------------------------------------------------------------------------- #
# Simulation
# -------------------------------------------------------------------------- #

# Compile Verilog for Simulation
$(SIM_DIR)/work/_info: *.v
	@echo "Compiling for Simulation..."
	mkdir -p $(SIM_DIR)
	cd $(SIM_DIR) && $(VLIB) work
	# Compile all Verilog files in parent dir + testbench
	cd $(SIM_DIR) && $(VLOG) -work work +incdir+.. ../*.v
	touch $(SIM_DIR)/work/_info

# Batch Simulation
sim: $(SIM_DIR)/work/_info
	@echo "Running Simulation (Batch)..."
	cp rom.hack $(SIM_DIR)/ 2>&1 >/dev/null || :
	cd $(SIM_DIR) && $(VSIM) -c -do "run -all; quit" $(TESTBENCH)

# GUI Simulation
sim-gui: $(SIM_DIR)/work/_info
	@echo "Opening Simulation GUI..."
	cd $(SIM_DIR) && $(VSIM) -gui -do "add wave -r /*; run 2000ns" $(TESTBENCH) &

# -------------------------------------------------------------------------- #
# Upload
# -------------------------------------------------------------------------- #

# Program the board
# -m JTAG: Mode JTAG
# -o "p;...": Operation Program
# If cable detection fails, run 'quartus_pgm -l' and add -c "Cable Name"
upload: $(SOF_FILE)
	@echo "Programming FPGA..."
	$(QUARTUS_PGM) -m JTAG -o "p;$(SOF_FILE)"

# -------------------------------------------------------------------------- #
# Cleanup
# -------------------------------------------------------------------------- #

clean:
	@echo "Cleaning Project..."
	$(QUARTUS_SH) --clean $(PROJECT)
	rm -rf $(SIM_DIR)
