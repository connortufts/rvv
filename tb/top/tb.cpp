#include <iostream>
#include <cstdint>
#include <cstdlib>

#include "Vtop.h"

uint32_t inst[] = {
    //0x00
    0b000000000011'00000'000'00011'0010011,     // addi 3 to reg 3
    //0x04
    0b0000000'00011'00000'010'00000'0100011,    // store reg 3 to addr 0
    //0x08
    0b000000000001'00000'000'00100'0010011,     // addi 1 to reg 4
    //0x0c
    0b0100000'00100'00011'000'00011'0110011,    // sub reg 4 from reg 3
    //0x10
    0b0000000'00011'00000'010'00000'0100011,    // store result to addr 0
    //0x14
    0b1111111'00000'00011'001'11001'1100011,    // branch reg 3 ne 0 back to sub
    //0x18
    0b000000000000'00000'000'00101'0010011,     // clear reg 5 (addi)
    //0x1c
    0b00000000000010010011'00101'0110111,       // lui to reg 5
    //0x20
    0b0000000'00101'00000'010'00000'0100011,    // store reg 5 to addr 0
    //0x24
    0b00000000000000000000'00101'0010111,       // auipc to reg 5
    //0x28
    0b0000000'00101'00000'010'00000'0100011,    // store reg 5 to addr 0
    //0x2c
    0b000000001010'00000'000'00110'0010011,     // addi 10 to reg 6
    //0x30
    0b0000000'00110'00000'010'00100'0100011,    // store reg 6 to addr 4
    //0x34
    0b000000000100'00000'010'00101'0000011,     // lw addr 4 to reg 5
    //0x38
    0b0000000'00101'00000'010'00000'0100011,    // store reg 5 to addr 0
    //0x3c
    0b00000001010000000000'10000'1101111,       // jal ahead, return reg 16
    //0x40
    0b0000000'00000'00000'000'10100'1100011,    // 4 branch always RETURN
    //0x44
    0b000000000000'00000'000'00000'0010011,     // 8 nop (addi 0 0 0)
    //0x48
    0b000000000000'00000'000'00000'0010011,     // 12 nop (addi 0 0 0)
    //0x4c
    0b000000000000'00000'000'00000'0010011,     // 16 nop (addi 0 0 0)
    //0x50
    0b000000000000'10000'000'00000'1100111,     // jalr return JUMP
    //0x54
    0b000000000000'00000'000'00000'0010011,     // nop (addi 0 0 0) BRANCH
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

    while(1){
        top.sysclk = 1;
        top.eval();
        top.instruction = *(uint32_t*)((uint8_t*)inst + top.instructionAddr);
        top.eval();
        std::cout << std::hex << "^ PC: 0x" << top.instructionAddr << " DMEM 0: 0x" << top.dmemview << std::endl;
        top.sysclk = 0;
        top.eval();
        std::cout << std::hex << "V PC: 0x" << top.instructionAddr << " DMEM 0: 0x" << top.dmemview << std::endl;
        if(top.instructionAddr == (sizeof(inst) - 4)){
            break;
        }
    }
    return EXIT_SUCCESS;
}
