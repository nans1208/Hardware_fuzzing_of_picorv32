#include <verilated.h>
#include "Vpicorv32core.h"
#include "verilated_vcd_c.h"
#include <time.h>
#include "svdpi.h"
#include "Vpicorv32core__Dpi.h"

vluint64_t main_time = 0;
vluint64_t seed = 0;

double sc_time_stamp() {
	return main_time;
}

// Below function generates the instructions based on the random values of the opcode, func3, func7, r1, r2, rd and immediate data
uint32_t instruction_generator(uint8_t OPCODE, uint8_t FUNC3, uint8_t FUNC7, uint8_t RD, uint8_t R1, uint8_t R2, uint32_t IMM){
    uint32_t rand=0x00000000;


    switch(OPCODE){
        case 0x33: //0110011: OP it covers add, sub, sll, slt, sltu, xor, srl, sra, or & and
            rand=(FUNC7<<25)+(R2<<20)+(R1<<15)+(FUNC3<<12)+(RD<<7)+OPCODE;
        break;
        case 0x13: //0010011: OP-IMM it covers addi, slti, sltui, xori, ori, andi, slli, srli, srai
            if(FUNC3==0x01 || FUNC3==0x05)
                rand=(FUNC7<<25)+((IMM&0x1F)<<20)+(R1<<15)+(FUNC3<<12)+(RD<<7)+OPCODE;
            else
                rand=((IMM&0xFFF)<<20)+(R1<<15)+(FUNC3<<12)+(RD<<7)+OPCODE;
        break;
        // case 0x63: //1100011: BRANCH
        //     rand=((IMM&0x1000)<<14)+((IMM&0x7E0)<<20)+(R2<<20)+(R1<<15)+(FUNC3<<12)+((IMM&0x1E)<<7)+((IMM&0x800)>>4)+OPCODE;
        // break;
        // case 0x37: //0110111: LUI
        //     rand=((IMM&0xFFFFF000))+(RD<<7)+OPCODE;
        // break;
        // case 0x17: //0010111: AUIPC
        //     rand=((IMM&0xFFFFF000))+(RD<<7)+OPCODE;
        // break;
        //case 0x6F: //1101111: JAL
        //    rand=((IMM&0x100000)<<11)+((IMM&0x7FE)<<20)+((IMM&0x800)<<12)+((IMM&0xFF000)<<4)+(RD<<7)+OPCODE;
        //break;
        //case 0x67: //1100111: JALR
        //    rand=((IMM&0xFFF)<<20)+(R1<<15)+(RD<<7)+OPCODE;
        //break;
        case 0x03: //0000011: LOAD
            rand=((IMM&0xFFF)<<20)+(R1<<15)+(FUNC3<<12)+(RD<<7)+OPCODE;
        break;
        case 0x23: //0100011: STORE
            rand=((IMM&0xFE0)<<20)+(R2<<20)+(R1<<15)+(FUNC3<<12)+((IMM&0x1F)<<7)+OPCODE;
        break;
        //case 0x0F: //0001111: MISC-MEM
        //    if(FUNC3==0x00)
        //        rand=((IMM&0xFF)<<20)+(FUNC3<<12)+OPCODE;
        //    else
        //        rand=(FUNC3<<12)+OPCODE;
        //break;
        //case 0x73: //1110011: SYSTEM
        //    rand=IMM+OPCODE;
        //break;
    }
    return rand;
}

// Below function have constraints to choose the respective function value depending upon the opcode selected.
svBitVecVal number_of_inst_gen(int number_of_instructions) {

	uint32_t instruction;
        //uint8_t opcode [7] = {0x33, 0x13, 0x37, 0x03, 0x23, 0x0f, 0x73};
        uint8_t opcode [4] = {0x13, 0x33, 0x3, 0x23};
        uint8_t r1 [14] = {0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa, 0xb, 0xc, 0xd, 0xe};
        uint8_t r2 [14] = {0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa, 0xb, 0xc, 0xd, 0xe};
        uint8_t rd [14] = {0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa, 0xb, 0xc, 0xd, 0xe};
        uint8_t func3 [8] = {0x0, 0x1,0x2, 0x3, 0x4, 0x5, 0x6, 0x7};
        uint8_t func3_index;
        uint8_t func7;
        uint8_t func7_for_opcode_33[2] = {0x0, 0x20};
        uint8_t func7_index;
        uint32_t imm;
        uint32_t index_for_opcode;
	uint32_t index_r1;
	uint32_t index_r2;
	uint32_t index_rd;

	srand(seed);
	for (int i = 0; i < number_of_instructions; i++) { 
	  index_for_opcode = rand() % 4;
	  imm = rand();
	  func3_index = rand() % 8;
	  func7 = rand();
	  if (opcode[index_for_opcode] == 0x33) {
		  if ((func3[func3_index] == 0x0) || (func3[func3_index] == 0x5)) {
		          func7_index = rand() % 2;
                          func7 = func7_for_opcode_33[func7_index];
		  }
		  else {
			  func7 = 0;
		  }
	  }
	  if (opcode[index_for_opcode] == 0x13) {
		  if (func3[func3_index] == 0x5) {
		          func7_index = rand() % 2;
                          func7 = func7_for_opcode_33[func7_index];
		  }
		  else {
			  func7 = 0;
		  }
	  }
	  if (opcode[index_for_opcode] == 0x23) {
		  func3_index = 0;
	  }
	   if (opcode[index_for_opcode] == 0x03) {
		  func3_index = 0;
	  }

	  index_r1 = rand() % 14;
	  index_r2 = rand() % 14;
          index_rd = rand() % 14;
          instruction = instruction_generator(opcode[index_for_opcode], func3[func3_index], func7, rd[index_rd], r1[index_r1], r2[index_r2], imm);

	  //printf ("DEBUG : value of inst = %0x opcode = %0x, index_for_opcode = %0x, func3 = %0x func7= %0x, imm = %0x rd = %0x r1 = %0x, r2 = %0x \n", instruction, opcode[index_for_opcode], index_for_opcode, func3[func3_index], func7, imm, rd[index_rd], r1[index_r1], r2[index_r2]);
          seed++;
	  return instruction;
	}
}

int main (int argc, char** argv, char** env) {

	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vpicorv32core* top = new Vpicorv32core{contextp};

	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	Verilated::threadContextp()->coveragep()->write();

	top->trace(tfp, 100000);
	tfp->open("./sim.vcd");

	top->clk = 0;
	top->eval();

        // Providing clock to the rtl
	for (int i = 0; i < 1000000; i++) {
          contextp->timeInc(1);
	  if ((main_time % 10) == 1) {
                  top->clk = 1;
		  top->eval();
	  }
	  else if ((main_time % 10) == 6) {
		  top-> clk = 0;
		  top->eval();
	  }
	  tfp->dump(main_time);
	  main_time++;
	}
	tfp->close();
	top->final();
      	delete top;
	delete tfp;
	delete contextp;
	return 0;
}
