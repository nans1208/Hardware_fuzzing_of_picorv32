#include <verilated.h>
#include "Vpicorv32core.h"
#include "verilated_vcd_c.h"

vluint64_t main_time = 0;

double sc_time_stamp() {
	return main_time;
}

uint64_t PicoRV32_inst(uint8_t OPCODE, uint8_t FUNC3, uint8_t FUNC7, uint8_t RD, uint8_t R1, uint8_t R2, uint32_t IMM){
    uint32_t rand=0x00000000;

    switch(OPCODE){
        case 0x33: //0110011: OP
            rand=(FUNC7<<25)+(R2<<20)+(R1<<15)+(FUNC3<<12)+(RD<<7)+OPCODE;
        break;
        case 0x13: //0010011: OP-IMM
            if(FUNC3==0x01 || FUNC3==0x05)
                rand=(FUNC7<<25)+((IMM&0x1F)<<20)+(R1<<15)+(FUNC3<<12)+(RD<<7)+OPCODE;
            else
                rand=((IMM&0xFFF)<<20)+(R1<<15)+(FUNC3<<12)+(RD<<7)+OPCODE;
        break;
        case 0x63: //1100011: BRANCH
            rand=((IMM&0x1000)<<14)+((IMM&0x7E0)<<20)+(R2<<20)+(R1<<15)+(FUNC3<<12)+((IMM&0x1E)<<7)+((IMM&0x800)>>4)+OPCODE;
        break;
        case 0x37: //0110111: LUI
            rand=((IMM&0xFFFFF000))+(RD<<7)+OPCODE;
        break;
        case 0x17: //0010111: AUIPC
            rand=((IMM&0xFFFFF000))+(RD<<7)+OPCODE;
        break;
        case 0x6F: //1101111: JAL
            rand=((IMM&0x100000)<<11)+((IMM&0x7FE)<<20)+((IMM&0x800)<<12)+((IMM&0xFF000)<<4)+(RD<<7)+OPCODE;
        break;
        case 0x67: //1100111: JALR
            rand=((IMM&0xFFF)<<20)+(R1<<15)+(RD<<7)+OPCODE;
        break;
        case 0x03: //0000011: LOAD
            rand=((IMM&0xFFF)<<20)+(R1<<15)+(FUNC3<<12)+(RD<<7)+OPCODE;
        break;
        case 0x23: //0100011: STORE
            rand=((IMM&0xFE0)<<20)+(R2<<20)+(R1<<15)+(FUNC3<<12)+((IMM&0x1F)<<7)+OPCODE;
        break;
        case 0x0F: //0001111: MISC-MEM
            if(FUNC3==0x00)
                rand=((IMM&0xFF)<<20)+(FUNC3<<12)+OPCODE;
            else
                rand=(FUNC3<<12)+OPCODE;
        break;
        case 0x73: //1110011: SYSTEM
            rand=IMM+OPCODE;
        break;
    }
    return rand;
}

int main (int argc, char** argv, char** env) {

	uint32_t read_data;
	uint32_t write_data;
	uint32_t addr;

	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vpicorv32core* top = new Vpicorv32core{contextp};

	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;

	top->trace(tfp, 100000);
	tfp->open("./sim.vcd");

	top->clk = 0;
	top->eval();

        // Reading from the memory
	for (int i = 0; i < 500; i++) {
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
