#include <iostream>
#include <cstdint>
#include <cstdlib>

#include "Vtop.h"

uint32_t inst[] = {
    0b000000001001'00000'000'00011'0010011,     // addi 9
    0b0000000'00011'00000'010'00000'0100011,    // store 0
    0b000000000001'00000'000'00100'0010011,     // addi 1
    0b0100000'00100'00011'000'00011'0110011,    // sub
    0b0000000'00011'00000'010'00000'0100011,    // store 0
    0b1111111'00000'00000'000'11001'1100011,    // branch back to sub
};

int main(int argc, char** argv){
    Verilated::commandArgs(argc, argv);
    Vtop top;

    top.viewaddr = 0;
    top.sysclk = 0;
    top.sysreset = 1;
    top.eval();
    top.sysreset = 0;
    top.eval();
    top.sysreset = 1;
    top.eval();

    for(int a = 0; a < 6 + 3; ++a){
        top.sysclk = 1;
        top.eval();
        top.instruction = *(uint32_t*)((uint8_t*)inst + top.instructionAddr);
        top.eval();
        std::cout << std::hex << "^ PC: 0x" << top.instructionAddr << " DMEM 0: 0x" << top.dmemview << std::endl;
        top.sysclk = 0;
        top.eval();
        std::cout << std::hex << "V PC: 0x" << top.instructionAddr << " DMEM 0: 0x" << top.dmemview << std::endl;
    }
    return EXIT_SUCCESS;
}
