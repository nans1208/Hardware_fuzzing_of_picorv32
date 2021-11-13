default:
	@echo : "addi" 
	@echo : "nop"
	@echo : "store_load"
	@echo : "jump"
	@echo : "rand_inst"
	@echo : "clean"

addi:
	verilator --cc --exe --build ./c_tests/core_clk_rst.c -I./hdl/picorv32 memory_modelling.sv picorv32core.v picorv32.v --top-module picorv32core --trace --timescale 1ns -DADDI --Mdir ./log_addi
	./log_addi/Vpicorv32core

nop:
	verilator --cc --exe --build ./c_tests/core_clk_rst.c -I./hdl/picorv32 memory_modelling.sv picorv32core.v picorv32.v --top-module picorv32core --trace --timescale 1ns -DNOP --Mdir ./log_nop
	./log_nop/Vpicorv32core

store_load:
	verilator --cc --exe --build ./c_tests/core_clk_rst.c -I./hdl/picorv32 memory_modelling.sv picorv32core.v picorv32.v --top-module picorv32core --trace --timescale 1ns  -DSTORE_LOAD --Mdir ./log_store_load
	./log_store_load/Vpicorv32core

jump:
	verilator --cc --exe --build ./c_tests/core_clk_rst.c -I./hdl/picorv32 memory_modelling.sv picorv32core.v picorv32.v --top-module picorv32core --trace --timescale 1ns  -DJUMP --Mdir ./log_jump
	./log_jump/Vpicorv32core

rand_inst:
	verilator --cc --exe --build ./c_tests/core_clk_rst.c -I./hdl/picorv32 instruction_parameters.sv memory_modelling.sv picorv32core.v picorv32.v --top-module picorv32core --trace --timescale 1ns --Mdir ./log_rand_inst --debug
	./log_rand_inst/Vpicorv32core

clean:
	rm -rf log_* sim*
