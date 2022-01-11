default:
	@echo : "rand_inst  : Use this instruction to verilate core and fuzz 2^32 instructions"
	@echo : "open_waves : Use this instruction to open waveforms"
	@echo : "clean      : Use this instruction to clean the log files"

rand_inst:
	mkdir firmware
	verilator --cc --exe --build ./c_tests/core_clk_rst.c  --coverage-line -I./hdl/picorv32 memory_modelling.sv picorv32core.v picorv32.v --top-module picorv32core --trace --timescale 1ns --Mdir ./log_rand_inst 
	./log_rand_inst/Vpicorv32core

open_waves:
	open -a gtkwave sim.vcd

clean:
	rm -rf log_* sim* firmware coverage*
