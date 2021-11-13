`timescale 1 ns / 1 ps

module picorv32core (input clk);

        // Core0
	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	reg [31:0] mem_rdata;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;

	reg [3:0] rst_counter;

	wire resetn = &rst_counter;
	always @(posedge clk) begin
		if (rst_counter < 4'hF) begin
			rst_counter <= rst_counter + 1;
		end
	end

/* verilator lint_off PINMISSING */
	picorv32 picorv32_core (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   ),
		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb)
	);

    memory_modelling memory_modelling_inst(
	                  .clk(clk), 
	                  .mem_la_wstrb(mem_la_wstrb),
			  .mem_la_wdata(mem_la_wdata),
			  .mem_la_addr(mem_la_addr),
			  .mem_la_write(mem_la_write),
			  .mem_la_read(mem_la_read),
			  .mem_instr(mem_instr),
			  .mem_valid(mem_valid),
			  .mem_ready(mem_ready),
			  .mem_rdata(mem_rdata)
		          );

    //initial begin
    //  `ifdef NOP
    //     $readmemh("./firmware/firmware_nop.hex", memory_modelling_inst.foobar);
    //  `elsif ADDI
    //     $readmemh("./firmware/firmware_addi.hex", memory_modelling_inst.foobar);
    //  `elsif STORE_LOAD
    //     $readmemh("./firmware/firmware_store_load.hex", memory_modelling_inst.foobar);
    //  `elsif JUMP
    //     $readmemh("./firmware/firmware_jump.hex", memory_modelling_inst.foobar);
    //  `else
    //     $readmemh("./firmware/firmware_rand.hex", memory_modelling_inst.foobar);
    //  `endif
    //end

endmodule
