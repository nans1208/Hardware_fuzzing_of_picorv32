RUNS = 10
RUN_LIST := $(shell seq 1 1 $(RUNS))

default:
	@echo  "rand_inst  : Use this instruction to verilate core and fuzz 2^16 instructions"
	@echo  "open_waves : Use this instruction to open waveforms"
	@echo  "clean      : Use this instruction to clean the log files"

rand_inst:
	$(info RUN_LIST is $(RUN_LIST))
	verilator --cc --exe --build ./c_tests/core_clk_rst.c +define+SIZE_OF_THE_BUS=32 +define+PICORV32 -I./hdl/include model_parameters.v -I./hdl/picorv32 memory_modelling.sv picorv32core.v picorv32.v --top-module picorv32core --trace --timescale 1ns --Mdir ./log_rand_inst  --coverage
	$(foreach run,$(RUN_LIST),$(shell mkdir log_run$(run)))
	$(foreach run,$(RUN_LIST),./log_rand_inst/Vpicorv32core;mv log_rand_inst/coverage.dat log_run$(run)/coverage.dat;mv mutated_initial_val.hex log_run$(run)/mutated_initial_val.hex;)

open_waves:
	open -a gtkwave sim.vcd

clean:
	rm -rf log_* sim* log_run* coverage* mutated*
