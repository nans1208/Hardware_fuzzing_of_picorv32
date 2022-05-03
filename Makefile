default:
	@echo  "rand_inst  : Use this instruction to verilate core and fuzz 2^16 instructions"
	@echo  "open_waves : Use this instruction to open waveforms"
	@echo  "clean      : Use this instruction to clean the log files"

rand_inst:
	verilator --cc --exe --build ./c_tests/core_clk_rst.c +define+SIZE_OF_THE_BUS=32 +define+PICORV32 -I./hdl/include model_parameters.v -I./hdl/picorv32 memory_modelling.sv picorv32core.v picorv32.v --top-module picorv32core --trace --timescale 1ns --Mdir ./log_rand_inst  --coverage
	./log_rand_inst/Vpicorv32core

open_waves:
	open -a gtkwave sim.vcd

clean:
	rm -rf log_* sim* log_run* coverage* mutated*
