#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <iostream>

#include "VMUX32.h"
#include "verilated.h"

int main(int argc, char** argv){
    Verilated::commandArgs(argc, argv);
    VMUX32 dut;

    for(uint32_t in0 = 0; in0 < 0x100; ++in0){
        for(uint32_t in1 = 0; in1 < 0x100; ++in1){
            for(uint32_t s0 = 0; s0 < 2; ++s0){
                dut.in0 = in0;
                dut.in1 = in1;
                dut.s0 = s0;
                
                dut.eval();

                uint32_t expected = ((s0 == 0) ? in0 : in1);

                if (dut.out != expected){
                    std::cerr << "failure case\n"
                              << "inputs:\n"
                              << "in0       = " << dut.in0 << "\n"
                              << "in1       = " << dut.in1 << "\n"
                              << "s0       = " << dut.s0 << "\n"
                              << "out       = " << dut.out << "\n"
                              << "expected  = " << expected << std::endl;
                    return EXIT_FAILURE;
                }
            }
        }
    }
    
    std::cout << "All tests passed" << std::endl;
    return EXIT_SUCCESS;
}
