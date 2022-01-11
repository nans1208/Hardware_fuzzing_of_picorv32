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
	
  import "DPI-C" function bit [31:0] number_of_inst_gen (input int number_of_instructions);

  logic [31:0] current_db [logic [31:0]];
  logic [31:0] initial_db [logic [31:0]];
  int file_handle;

  always @(posedge clk) begin
   // On every clock cycle checking for reading
   mem_ready <= 1;
   if (mem_la_read) begin
     mem_rdata = mem_read (mem_la_addr);
   end
   // On every clock cycle checking for writing
   if(mem_la_write == 1) begin
     mem_write (mem_la_addr, mem_la_wstrb, mem_la_wdata);
   end
  end

  // Read function : Reads value from the associative array type memory implementation.
  // Input : Memory address
  // Functionality : 
  // 1. Retrieves the instruction stored in the memory
  // 2. If memory is not present then, it is created and depending upon the memory address data/instruction is stored in the memory.
  //    addr < 32'hFFFF then we store instruction into the memory
  //    addr > 32'hFFFF then we store data into the memory
  // 3. Two database are created one holds only the values created while
  // reading from memory i.e initial_db while other holds both the read and
  // writen values of the memory i.e current_db
  function logic [31:0] mem_read(input logic [31:0] m_addr);
    logic [31:0] mem_rdata;
        /* verilator lint_off WIDTH */
        if (!initial_db.exists(m_addr >> 2)) begin
		if (m_addr > 32'hFFFF) begin
        	     current_db[m_addr >> 2] = $random;
        	     initial_db[m_addr >> 2] = current_db[m_addr >> 2];
	        end
		else begin
                     initial_db[m_addr >> 2] = number_of_inst_gen(1);
                     current_db[m_addr >> 2] = initial_db[m_addr >> 2];
		end
        end
        //file_handle = $fopen("./mutated_initial_val_check.hex", "a");
        file_handle = $fopen("./mutated_initial_val.hex", "a");
        $fdisplay (file_handle, "@%0x %0x", m_addr >> 2, initial_db[m_addr >> 2]);
        $fclose(file_handle);

        mem_rdata = initial_db[m_addr >> 2];
    return mem_rdata;
  endfunction

  // Write task : Write the values to the memory.
  // Input : memory address : address value where the data is stored.
  //         write_strobe  : determines how many bytes are writen in the memory.
  //         wdata : data to be written in the memory
  // Functionality :
  // Writes the value present in the internal register of the core to the memory address given by the instruction. 
  task mem_write(input logic [31:0] mem_addr, input logic [3:0] write_strobe, input logic [31:0] wdata);
     logic [31:0] m_addr;

       m_addr = mem_addr >> 2;
       if (write_strobe[0]) current_db[m_addr][ 7: 0] = wdata[ 7: 0];
       if (write_strobe[1]) current_db[m_addr][15: 8] = wdata[15: 8];
       if (write_strobe[2]) current_db[m_addr][23:16] = wdata[23:16];
       if (write_strobe[3]) current_db[m_addr][31:24] = wdata[31:24];
  endtask

endmodule
