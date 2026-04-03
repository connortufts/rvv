#include <iostream>
#include <cstdint>
#include <cstdlib>
#include <vector>

#include "VImmediateGen.h"

// -----------------------------
// Helper encoders (IMPORTANT)
// -----------------------------

uint32_t encode_jal(int32_t imm, uint8_t rd) {
    uint32_t val = 0;
    val |= ((imm >> 20) & 0x1) << 31;      // imm[20]
    val |= ((imm >> 1)  & 0x3FF) << 21;    // imm[10:1]
    val |= ((imm >> 11) & 0x1) << 20;      // imm[11]
    val |= ((imm >> 12) & 0xFF) << 12;     // imm[19:12]
    val |= (rd << 7);
    val |= 0b1101111; // JAL opcode
    return val;
}

uint32_t encode_branch(int32_t imm, uint8_t funct3 = 0) {
    uint32_t val = 0;
    val |= ((imm >> 12) & 0x1) << 31;      // imm[12]
    val |= ((imm >> 5)  & 0x3F) << 25;     // imm[10:5]
    val |= ((imm >> 1)  & 0xF) << 8;       // imm[4:1]
    val |= ((imm >> 11) & 0x1) << 7;       // imm[11]
    val |= (funct3 << 12);
    val |= 0b1100011; // B-type opcode
    return val;
}

// -----------------------------

struct ImmTest {
    uint32_t instruction;
    int32_t expected_imm;
};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VImmediateGen dut;

    std::vector<ImmTest> tests = {

        // --- I-TYPE (ADDI x3, x2, 5) ---
        {0b000000000101'00010'000'00011'0010011, 5},

        // --- I-TYPE negative (ADDI x3, x2, -1) ---
        {0b111111111111'00010'000'00011'0010011, -1},

        // --- LOAD (LW x3, 8(x2)) ---
        {0b000000001000'00010'010'00011'0000011, 8},

        // --- STORE (SW x3, 8(x2)) ---
        {0b0000000'00011'00010'010'01000'0100011, 8},

        // --- STORE negative (SW x3, -4(x2)) ---
        {0b1111111'00011'00010'010'11100'0100011, -4},

        // --- B-TYPE (offset = 16) ---
        {encode_branch(16), 16},

        // --- B-TYPE negative (offset = -4) ---
        {encode_branch(-4), -4},

        // --- U-TYPE (LUI x3, 0x12345) ---
        {0b00010010001101000101'00011'0110111, 0x12345000},

        // --- AUIPC ---
        {0b00010010001101000101'00011'0010111, 0x12345000},

        // --- J-TYPE (offset = 32) ---
        {encode_jal(32, 3), 32},

        // --- J-TYPE negative (offset = -8) ---
        {encode_jal(-8, 3), -8}
    };

    int passed = 0;

    for (size_t i = 0; i < tests.size(); i++) {
        dut.instruction = tests[i].instruction;
        dut.eval();

        int32_t result = (int32_t)dut.out;

        if (result != tests[i].expected_imm) {
            std::cout << "Test " << i << " FAILED\n";
            std::cout << "  Instr: 0x" << std::hex << tests[i].instruction << "\n";
            std::cout << "  Expected: " << std::dec << tests[i].expected_imm << "\n";
            std::cout << "  Got:      " << result << "\n";
        } else {
            passed++;
        }
    }

    std::cout << "\nPassed " << passed << " / " << tests.size() << " tests\n";

    return 0;
}
