#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <iostream>

#include "VRegisterFile.h"

static void tick(VRegisterFile& dut) {
    dut.CLK = 1;
    dut.eval();

    dut.CLK = 0;
    dut.eval();
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VRegisterFile dut;

    // Initialize inputs
    dut.CLK = 0;
    dut.WE    = 0;
    dut.RR1   = 0;
    dut.RR2   = 0;
    dut.WR    = 0;
    dut.WD    = 0;
    dut.eval();

    // test 1: write to x5
    dut.WE = 1;
    dut.WR = 5;
    dut.WD = 1234;
    tick(dut);

    dut.WE = 0;
    dut.RR1 = 5;
    dut.eval();

    if (dut.RD1 != 1234) {
        std::cerr << "FAIL: write/read x5 failed\n"
                  << "Expected 1234, got " << dut.RD1 << "\n";
        return EXIT_FAILURE;
    }

    // test 2: write to x10 and read both ports
    dut.WE = 1;
    dut.WR = 10;
    dut.WD = 0xdeadbeef;
    tick(dut);

    dut.WE = 0;
    dut.RR1 = 5;
    dut.RR2 = 10;
    dut.eval();

    if (dut.RD1 != 1234) {
        std::cerr << "FAIL: RR1 read wrong value from x5\n"
                  << "Expected 1234, got " << dut.RD1 << "\n";
        return EXIT_FAILURE;
    }

    if (dut.RD2 != 0xdeadbeef) {
        std::cerr << "FAIL: RR2 read wrong value from x10\n"
                  << "Expected 0xdeadbeef, got 0x" << std::hex << dut.RD2 << std::dec << "\n";
        return EXIT_FAILURE;
    }

    // test 3: x0 must stay zero
    dut.WE = 1;
    dut.WR = 0;
    dut.WD = 0xffffffff;
    tick(dut);

    dut.WE = 0;
    dut.RR1 = 0;
    dut.eval();

    if (dut.RD1 != 0) {
        std::cerr << "FAIL: x0 changed after write attempt. Got " << dut.RD1 << "\n";
        return EXIT_FAILURE;
    }

    std::cout << "All register file tests passed\n";
    return EXIT_SUCCESS;
}
