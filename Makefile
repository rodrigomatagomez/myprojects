# ==========================================
# SystemVerilog Workflow - myprojects
# RTL:    rtl/
# VERIF:  verif/
# SIM:    sim/
# ==========================================

SHELL := /bin/bash

RTL_DIR   := rtl
VERIF_DIR := verif
SIM_DIR   := sim

RTL_SRCS   := $(shell find $(RTL_DIR)   -type f \( -name "*.sv" -o -name "*.v" \) 2>/dev/null)
VERIF_SRCS := $(shell find $(VERIF_DIR) -type f \( -name "*.sv" -o -name "*.v" \) 2>/dev/null)

SIM_BIN := $(SIM_DIR)/sim.out
VCD     := $(SIM_DIR)/wave.vcd

IVERILOG  := iverilog
VVP       := vvp
GTKWAVE   := gtkwave
VERILATOR := verilator

VERIBLE_LINT := verible-verilog-lint
VERIBLE_FMT  := verible-verilog-format

FMT_FLAGS  := --inplace --column_limit=100 --indentation_spaces=2
LINT_FLAGS := --rules_config=verible.rules

.PHONY: all
all: lint

# ------------------------------------------
# Create sim directory if missing
# ------------------------------------------
$(SIM_DIR):
	mkdir -p $(SIM_DIR)

# ------------------------------------------
# Lint: Verible + Verilator
# ------------------------------------------
.PHONY: lint
lint:
	@echo "== Verible lint =="
	@if [ -z "$(RTL_SRCS)$(VERIF_SRCS)" ]; then echo "No SV sources found"; exit 1; fi
	$(VERIBLE_LINT) $(LINT_FLAGS) $(RTL_SRCS) $(VERIF_SRCS)
	@echo "== Verilator lint =="
	$(VERILATOR) --lint-only -Wall -sv $(RTL_SRCS) $(VERIF_SRCS)

# ------------------------------------------
# Format: Verible
# ------------------------------------------
.PHONY: fmt
fmt:
	@echo "== Verible format (inplace) =="
	$(VERIBLE_FMT) $(FMT_FLAGS) $(RTL_SRCS) $(VERIF_SRCS)

# ------------------------------------------
# Simulation: Icarus
# ------------------------------------------
.PHONY: sim
sim: $(SIM_DIR)
	@echo "== Compile (iverilog) =="
	$(IVERILOG) -g2012 -o $(SIM_BIN) $(VERIF_SRCS) $(RTL_SRCS)
	@echo "== Run (vvp) =="
	$(VVP) $(SIM_BIN)

# ------------------------------------------
# Waveform
# ------------------------------------------
.PHONY: wave
wave:
	@if [ ! -f "$(VCD)" ]; then \
		echo "No VCD at $(VCD). Use $$dumpfile(\"sim/wave.vcd\") in TB."; \
		exit 1; \
	fi
	$(GTKWAVE) $(VCD)

# ------------------------------------------
# Clean
# ------------------------------------------
.PHONY: clean
clean:
	rm -rf $(SIM_DIR)

