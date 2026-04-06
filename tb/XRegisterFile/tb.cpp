#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <iostream>

#include "VXRegisterFile.h"

static void tick(VXRegisterFile& dut) {
    dut.clk = 1;
    dut.eval();

    dut.clk = 0;
    dut.eval();
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VXRegisterFile dut;

    // Initialize inputs
    dut.clk =         0;
    dut.writeEnable = 0;
    dut.read1Reg =    0;
    dut.read2Reg =    0;
    dut.writeReg =    0;
    dut.writeData =   0;
    dut.eval();

    // test 1: write to x5
    dut.writeEnable = 1;
    dut.writeReg = 5;
    dut.writeData = 1234;
    tick(dut);

    dut.writeEnable = 0;
    dut.read1Reg = 5;
    dut.eval();

    if (dut.read1Data != 1234) {
        std::cerr << "FAIL: write/read x5 failed\n"
                  << "Expected 1234, got " << dut.read1Data << "\n";
        return EXIT_FAILURE;
    }

    // test 2: write to x10 and read both ports
    dut.writeEnable = 1;
    dut.writeReg = 10;
    dut.writeData = 0xdeadbeef;
    tick(dut);

    dut.writeEnable = 0;
    dut.read1Reg = 5;
    dut.read2Reg = 10;
    dut.eval();

    if (dut.read1Data != 1234) {
        std::cerr << "FAIL: RR1 read wrong value from x5\n"
                  << "Expected 1234, got " << dut.read1Data << "\n";
        return EXIT_FAILURE;
    }

    if (dut.read2Data != 0xdeadbeef) {
        std::cerr << "FAIL: RR2 read wrong value from x10\n"
                  << "Expected 0xdeadbeef, got 0x" << std::hex << dut.read2Data << std::dec << "\n";
        return EXIT_FAILURE;
    }

    // test 3: x0 must stay zero
    dut.writeEnable = 1;
    dut.writeReg = 0;
    dut.writeData = 0xffffffff;
    tick(dut);

    dut.writeEnable = 0;
    dut.read1Reg = 0;
    dut.eval();

    if (dut.read1Data != 0) {
        std::cerr << "FAIL: x0 changed after write attempt. Got " << dut.read1Data << "\n";
        return EXIT_FAILURE;
    }

    std::cout << "All register file tests passed\n";
    return EXIT_SUCCESS;
}
