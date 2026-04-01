// PC
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <iostream>

#include "VProgramCounter.h"
#include "verilated.h"

int main(int argc, char** argv){
    Verilated::commandArgs(argc, argv);
    VProgramCounter dut;

    dut.clk = 0;
    dut.load = 0;
    dut.addrIn = 0;

    dut.resetN = 0;
    dut.enable = 1;
    dut.eval();

    dut.clk = 1; dut.eval();
    dut.clk = 0; dut.eval();

    dut.resetN = 1;
    dut.eval();

    uint32_t expected_pc = 0;

    // Test PC increment by 4
    for(int i = 0; i < 5; i++){
        dut.clk = 1; dut.eval();
        dut.clk = 0; dut.eval();
        expected_pc += 4;

        if(dut.addrOut != expected_pc){
            std::cerr << "FAIL: increment test\n"
                      << "Expected PC = " << expected_pc << "\n"
                      << " got PC     = " << dut.addrOut << std::endl;
            return EXIT_FAILURE;
        }
    }

    // Test loading address
    dut.addrIn = 100;
    dut.load = 1;
    dut.eval();

    dut.clk = 1; dut.eval();
    dut.clk = 0; dut.eval();
    
    expected_pc = 100;
     
    if(dut.addrOut != expected_pc){
        std::cerr << "FAIL: branch test\n"
                  << "Expected PC = " << expected_pc << "\n"
                  << " got PC     = " << dut.addrOut << std::endl;
        return EXIT_FAILURE;
    }

    // Test stall
    dut.enable = 0;
    dut.load = 0;
    dut.eval();

    dut.clk = 1; dut.eval();
    dut.clk = 0; dut.eval();
    dut.clk = 1; dut.eval();
    dut.clk = 0; dut.eval();
    dut.clk = 1; dut.eval();
    dut.clk = 0; dut.eval();
    dut.clk = 1; dut.eval();
    dut.clk = 0; dut.eval();
    
    if(dut.addrOut != expected_pc){
        std::cerr << "FAIL: stall test\n"
                  << "Expected PC = " << expected_pc << "\n"
                  << " got PC     = " << dut.addrOut << std::endl;
        return EXIT_FAILURE;
    }

    std::cout << "All tests passed" << std::endl;
    return EXIT_SUCCESS;
}
