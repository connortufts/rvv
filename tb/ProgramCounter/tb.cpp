// PC
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <iostream>

#include "VProgramCounter.h"

#define START_ADDR 0x00
#define INCREMENT 0x4

int main(int argc, char** argv){
    Verilated::commandArgs(argc, argv);
    VProgramCounter dut;

    dut.clk = 0;
    dut.load = false;
    dut.addrLoad = 0;
    dut.resetN = !false;
    dut.enable = true;
    dut.eval();

    // perform initial reset
    dut.resetN = !true;
    dut.eval();
    dut.resetN = !false;
    dut.eval();
    if(dut.addrOut != START_ADDR){
        std::cerr << std::hex
                  << "FAIL: reset initial test\n"
                  << "Expected PC = 0x" << START_ADDR << "\n"
                  << "Observed PC = 0x" << (int)dut.addrOut
                  << std::dec << std::endl;
        return EXIT_FAILURE;
    }

    // make sure it sticks for one cycle
    dut.clk = 1;
    dut.eval();
    dut.clk = 0;
    dut.eval();
    if(dut.addrOut != START_ADDR){
        std::cerr << std::hex
                  << "FAIL: post reset test\n"
                  << "Expected PC = 0x" << START_ADDR << "\n"
                  << "Observed PC = 0x" << (int)dut.addrOut
                  << std::dec << std::endl;
        return EXIT_FAILURE;
    }

    // increment once
    dut.clk = 1;
    dut.eval();
    dut.clk = 0;
    dut.eval();
    if(dut.addrOut != (START_ADDR + INCREMENT)){
        std::cerr << std::hex
                  << "FAIL: increment test\n"
                  << "Expected PC = 0x" << (START_ADDR + INCREMENT) << "\n"
                  << "Observed PC = 0x" << (int)dut.addrOut
                  << std::dec << std::endl;
        return EXIT_FAILURE;
    }
    
    // pause once
    dut.enable = false;
    dut.clk = 1;
    dut.eval();
    dut.enable = true;
    dut.clk = 0;
    dut.eval();
    if(dut.addrOut != (START_ADDR + INCREMENT)){
        std::cerr << std::hex
                  << "FAIL: pause test\n"
                  << "Expected PC = 0x" << (START_ADDR + INCREMENT) << "\n"
                  << "Observed PC = 0x" << (int)dut.addrOut
                  << std::dec << std::endl;
        return EXIT_FAILURE;
    }

    // load
    dut.addrLoad = 0xF0;
    dut.load = true;
    dut.clk = 1;
    dut.eval();
    dut.load = false;
    dut.clk = 0;
    dut.eval();
    if(dut.addrOut != (0xF0)){
        std::cerr << std::hex
                  << "FAIL: load test\n"
                  << "Expected PC = 0x" << (0xF0) << "\n"
                  << "Observed PC = 0x" << (int)dut.addrOut
                  << std::dec << std::endl;
        return EXIT_FAILURE;
    }
    
    std::cout << "All tests passed" << std::endl;
    return EXIT_SUCCESS;
}
