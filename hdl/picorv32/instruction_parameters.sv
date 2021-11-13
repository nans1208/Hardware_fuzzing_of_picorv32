class instr_parameters;
	rand bit [6:0] opcode;
	rand bit [2:0] func3;
	rand bit [6:0] func7;
	rand bit [4:0] rd;
	rand bit [4:0] r1;
	rand bit [4:0] r2;
	rand bit [31:0] imm;

        constraint c1 {
		       opcode inside {8'h33, 8'h13, 8'h63, 8'h37, 8'h17, 8'h6f, 8'h67, 8'h03, 8'h23, 8'h0f, 8'h73};
	               r1 inside {[8'h1 : 8'he]};
	               r2 inside {[8'h1 : 8'he]};
	               rd inside {[8'h1 : 8'he]};
	              }

endclass
