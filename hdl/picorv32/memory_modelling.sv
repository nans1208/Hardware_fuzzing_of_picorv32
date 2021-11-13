module memory_modelling (input logic clk, 
	                input logic [3:0] mem_la_wstrb, 
			input logic [31:0] mem_la_wdata, 
			input logic [31:0] mem_la_addr, 
			input logic mem_la_read,
			input logic mem_la_write,
			input logic mem_instr,
			input logic mem_valid,
			output logic mem_ready, 
			output logic [31:0] mem_rdata);
	
  logic [31:0] foobar [logic [31:0]];
  int index = 0;

  always @(posedge clk) begin
          instr_parameters instr_inst;
          instr_inst = new();     
	  // instr_inst.randomize();
	  // $display (" opcode = %0x \n func3 = %0x \n func7 = %0x \n rd = %0x \n r1 = %0x \n r2 = %0x \n imm = %0x \n", instr_inst.opcode, instr_inst.func3, instr_inst.func7, instr_inst.rd, instr_inst.r1, instr_inst.r2, instr_inst.imm);
	  // foobar[index] = instruction_generator(instr_inst.opcode, instr_inst.func3, instr_inst.func7, instr_inst.rd, instr_inst.r1, instr_inst.r2, instr_inst.imm);
  end

  always @(posedge clk) begin
    // On every clock cycle checking for reading
    mem_ready <= 1;
    if (mem_la_read) begin
      mem_rdata = mem_read (mem_la_addr, mem_instr);
    end
    // On evry clock cycle checking for writing
    if(mem_la_write == 1) begin
      mem_write (mem_la_addr, mem_la_wstrb, mem_la_wdata);
    end

    $display ("Size of the mem = %0x and values are %0p \n", foobar.size(), foobar);
  end

  // Read function
  function logic [31:0] mem_read(input logic [31:0] m_addr, input logic mem_valid);
    logic [31:0] mem_rdata;
        mem_rdata = foobar[m_addr >> 2];
    return mem_rdata;
  endfunction

  // Write task
  task mem_write(input logic [31:0] mem_addr, input logic [3:0] write_strobe, input logic [31:0] wdata);
     logic [31:0] m_addr;

       m_addr = mem_addr >> 2;
       if (write_strobe[0]) foobar[m_addr][ 7: 0] = wdata[ 7: 0];
       if (write_strobe[1]) foobar[m_addr][15: 8] = wdata[15: 8];
       if (write_strobe[2]) foobar[m_addr][23:16] = wdata[23:16];
       if (write_strobe[3]) foobar[m_addr][31:24] = wdata[31:24];
  endtask

  // Function to generate random instructions
  function logic [31:0] instruction_generator (bit [6:0] opcode, bit [2:0] func3, bit [6:0] func7, bit [4:0] rd, bit [4:0] r1, bit [4:0] r2, bit [31:0] imm);
	  bit [31:0] instruction;
          /* verilator lint_off CASEINCOMPLETE */
          case (opcode)
		  7'h33 : begin // OP
			    instruction = {(func7 << 25), (r2 << 20), (r1 << 15), (func3 << 12), (rd << 7), opcode};
		          end
		  7'h13 : begin // OP-IMM
			    if(func3 == 3'h1 || func3 == 3'h5) begin
                                 instruction = {(func7 << 25), (imm[4:0] << 20), (r1 << 15), (func3 << 12), (rd << 7), opcode};
			    end
			    else begin
                                 instruction = {(imm[11:0] << 20), (r1 << 15), (func3 << 12), (rd << 7), opcode};
			    end
		          end
		  7'h63 : begin // BRANCH
			  instruction = {imm[12], imm[10:5], (r2 << 20), (r1 << 15), (func3 << 12), imm[4:1], imm[11], opcode};
		  	  end
		  7'h37 : begin // LUI
			    instruction = {imm[31:12], (rd << 7), opcode};
		          end
		  7'h17 : begin // AUIPC
			    instruction = {imm[31:12], (rd << 7), opcode};
		          end
		  7'h6F : begin // JAL
			    instruction = {imm[20], imm[10:1], imm[11], imm[19:12], (rd << 7), opcode};
		  	  end
		  7'h67 : begin // JALR
			    instruction = {imm[11:0], (r1 << 15), (func3 << 12), (rd << 7), opcode};
		          end
		  7'h03 : begin // LOAD
			    instruction = {imm[11:0], (r1 << 15), (func3 << 12), (rd << 7), opcode};
		          end
		  7'h23 : begin // STORE
			    instruction = {imm[11:5], (r2 << 20), (r1 << 15), (func3 << 12), imm[4:0], opcode};
		          end
	  endcase

	  return instruction;
  endfunction

endmodule
