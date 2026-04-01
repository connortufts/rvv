#include <iostream>
#include <cstdint>
#include <cstdlib>
#include <vector>
#include "VInsDecoder.h"

struct DecoderTest {
    uint32_t instr;
    uint8_t expected_alu_op;
    bool expected_reg_write;
    bool expected_mem_read;
    bool expected_mem_write;
    bool expected_branch;
    bool expected_jump;
    bool expected_alu_src;
    bool expected_mem_to_reg;
};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VInsDecoder dut;

    std::vector<DecoderTest> tests = {
        // --- R-type ADD ---
        {0b0000000'00001'00010'000'00011'0110011, 0b00000, 1,0,0,0,0,0,0},
        // --- R-type SUB ---
        {0b0100000'00001'00010'000'00011'0110011, 0b00001, 1,0,0,0,0,0,0},
        // --- I-type ADDI ---
        {0b000000000001'00010'000'00011'0010011, 0b00000, 1,0,0,0,0,1,0},
        // --- Load LW ---
        {0b000000000100'00010'010'00011'0000011, 0b00000,1,1,0,0,0,1,1},
        // --- Store SW ---
        {0b0000000'00100'00010'010'00011'0100011,0b00000,0,0,1,0,0,1,0},
        // --- Branch BEQ ---
        {0b0000000'00001'00010'000'00011'1100011,0b00001,0,0,0,1,0,0,0},
        // --- JAL ---
        {0b00000000000000000001'00011'1101111,0b00000,1,0,0,0,1,0,0},
        // --- MUL (R-type) ---
        {0b0000001'00001'00010'000'00011'0110011,0b01010,1,0,0,0,0,0,0}
        // add more tests as needed
    };

    int failed = 0;

    for (auto &t : tests) {
        dut.instr = t.instr;
        dut.eval();

        if (dut.alu_op      != t.expected_alu_op ||
            dut.reg_write   != t.expected_reg_write ||
            dut.mem_read    != t.expected_mem_read ||
            dut.mem_write   != t.expected_mem_write ||
            dut.branch      != t.expected_branch ||
            dut.jump        != t.expected_jump ||
            dut.alu_src     != t.expected_alu_src ||
            dut.mem_to_reg  != t.expected_mem_to_reg
        ) {
            std::cerr << "Test failed for instr = 0x" << std::hex << t.instr << std::dec << "\n";
            std::cerr << "alu_op      = " << (int)dut.alu_op << ", expected " << (int)t.expected_alu_op << "\n";
            std::cerr << "reg_write   = " << dut.reg_write << ", expected " << t.expected_reg_write << "\n";
            std::cerr << "mem_read    = " << dut.mem_read << ", expected " << t.expected_mem_read << "\n";
            std::cerr << "mem_write   = " << dut.mem_write << ", expected " << t.expected_mem_write << "\n";
            std::cerr << "branch      = " << dut.branch << ", expected " << t.expected_branch << "\n";
            std::cerr << "jump        = " << dut.jump << ", expected " << t.expected_jump << "\n";
            std::cerr << "alu_src     = " << dut.alu_src << ", expected " << t.expected_alu_src << "\n";
            std::cerr << "mem_to_reg  = " << dut.mem_to_reg << ", expected " << t.expected_mem_to_reg << "\n";
            failed++;
        }
    }

    if (failed == 0) {
        std::cout << "All tests passed!" << std::endl;
        return EXIT_SUCCESS;
    } else {
        std::cerr << failed << " tests failed!" << std::endl;
        return EXIT_FAILURE;
    }
}
