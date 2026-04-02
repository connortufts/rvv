#include <iostream>
#include <cstdint>
#include <cstdlib>

#include "VFullAdder8.h"

int main(int argc, char** argv){
    Verilated::commandArgs(argc, argv);
    VFullAdder8 dut;

    for(int c = 0; c < 2; ++c){
        for(int a = 0; a < 0x100; ++a){
            for(int b = 0; b < 0x100; ++b){
                dut.a = a;
                dut.b = b;
                dut.cIn = c;
                dut.eval();

                uint8_t expectedSum = a + b + c;
                uint8_t expectedCarry = (a + b + c) >> 8;

                if(
                    (dut.s != expectedSum) ||
                    (dut.cOut != expectedCarry)
                ){
                    std::cerr << "failure case\n"
                        << "inputs:\n"
                        << "a   = " << (int)dut.a << "\n"
                        << "b   = " << (int)dut.b << "\n"
                        << "cIn = " << (int)dut.cIn << "\n"
                        << "outputs:\n"
                        << "s    = " << (int)dut.s << "\n"
                        << "cOut = " << (int)dut.cOut << "\n"
                        << "expected:\n"
                        << "s    = " << (int)expectedSum << "\n"
                        << "cOut = " << (int)expectedCarry << std::endl;
                    return EXIT_FAILURE;
                }
            }
        }
    }

    std::cout << "all tests passed" << std::endl;

    return EXIT_SUCCESS;
}
