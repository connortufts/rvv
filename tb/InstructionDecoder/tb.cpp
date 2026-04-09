#include <iostream>
#include <cstdint>
#include <cstdlib>
#include <vector>
#include "VInstructionDecoder.h"

struct DecoderTest {
    int instruction;
    int rs1;
    int rs2;
    int rd;
    int xaluArithmeticFlag;
    int xaluOp;

    // NEW (vector)
    int valuOp;
    int vecMode;
    int isVectorOp;

    int zeroXaluPrimary;
    int pcXaluPrimary;
    int immediateXaluSecondary;
    int memoryOpSize;
    int unsignedLoad;
    int storeLoad;
    int branchOp;
    int branchNegate;
    int jump;
    int writeSource;
};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VInstructionDecoder dut;

    std::vector<DecoderTest> tests = {

        // --- R-type ADD ---
        {
            .instruction = 0b0000000'00001'00010'000'00011'0110011,
            .rs1 = 0b00010,
            .rs2 = 0b00001,
            .rd = 0b00011,
            .xaluArithmeticFlag = 0,
            .xaluOp = 0b000,

            .valuOp = 63, // VALU_OP_NONE
            .vecMode = 0,
            .isVectorOp = 0,

            .zeroXaluPrimary = 0,
            .pcXaluPrimary = 0,
            .immediateXaluSecondary = 0,
            .memoryOpSize = 0b11,
            .unsignedLoad = 0,
            .storeLoad = 0,
            .branchOp = 0b01,
            .branchNegate = 0,
            .jump = 0,
            .writeSource = 0b11,
        },

        // --- R-type SUB ---
        {
            .instruction = 0b0100000'00001'00010'000'00011'0110011,
            .rs1 = 0b00010,
            .rs2 = 0b00001,
            .rd = 0b00011,
            .xaluArithmeticFlag = 1,
            .xaluOp = 0b000,

            .valuOp = 63,
            .vecMode = 0,
            .isVectorOp = 0,

            .zeroXaluPrimary = 0,
            .pcXaluPrimary = 0,
            .immediateXaluSecondary = 0,
            .memoryOpSize = 0b11,
            .unsignedLoad = 0,
            .storeLoad = 0,
            .branchOp = 0b01,
            .branchNegate = 0,
            .jump = 0,
            .writeSource = 0b11,
        },

        // --- I-type ADDI ---
        {
            .instruction = 0b000000000001'00010'000'00011'0010011,
            .rs1 = 0b00010,
            .rs2 = 0b00001,
            .rd = 0b00011,
            .xaluArithmeticFlag = 0,
            .xaluOp = 0b000,

            .valuOp = 63,
            .vecMode = 0,
            .isVectorOp = 0,

            .zeroXaluPrimary = 0,
            .pcXaluPrimary = 0,
            .immediateXaluSecondary = 1,
            .memoryOpSize = 0b11,
            .unsignedLoad = 0,
            .storeLoad = 0,
            .branchOp = 0b01,
            .branchNegate = 0,
            .jump = 0,
            .writeSource = 0b11,
        },

        // --- Load LW ---
        {
            .instruction = 0b000000000100'00010'010'00011'0000011,
            .rs1 = 0b00010,
            .rs2 = 0b00100,
            .rd = 0b00011,
            .xaluArithmeticFlag = 0,
            .xaluOp = 0b000,

            .valuOp = 63,
            .vecMode = 0,
            .isVectorOp = 0,

            .zeroXaluPrimary = 0,
            .pcXaluPrimary = 0,
            .immediateXaluSecondary = 1,
            .memoryOpSize = 0b10,
            .unsignedLoad = 0,
            .storeLoad = 0,
            .branchOp = 0b01,
            .branchNegate = 0,
            .jump = 0,
            .writeSource = 0b10,
        },

        // --- Store SW ---
        {
            .instruction = 0b0000000'00100'00010'010'00011'0100011,
            .rs1 = 0b00010,
            .rs2 = 0b00100,
            .rd = 0b00011,
            .xaluArithmeticFlag = 0,
            .xaluOp = 0b000,

            .valuOp = 63,
            .vecMode = 0,
            .isVectorOp = 0,

            .zeroXaluPrimary = 0,
            .pcXaluPrimary = 0,
            .immediateXaluSecondary = 1,
            .memoryOpSize = 0b10,
            .unsignedLoad = 0,
            .storeLoad = 1,
            .branchOp = 0b01,
            .branchNegate = 0,
            .jump = 0,
            .writeSource = 0b00,
        },

        // --- Branch BEQ ---
        {
            .instruction = 0b0000000'00001'00010'000'00011'1100011,
            .rs1 = 0b00010,
            .rs2 = 0b00001,
            .rd = 0b00011,
            .xaluArithmeticFlag = 0,
            .xaluOp = 0b000,

            .valuOp = 63,
            .vecMode = 0,
            .isVectorOp = 0,

            .zeroXaluPrimary = 0,
            .pcXaluPrimary = 1,
            .immediateXaluSecondary = 1,
            .memoryOpSize = 0b11,
            .unsignedLoad = 0,
            .storeLoad = 0,
            .branchOp = 0b00,
            .branchNegate = 0,
            .jump = 0,
            .writeSource = 0b00,
        },

        // --- JAL ---
        {
            .instruction = 0b00000000000000000001'00011'1101111,
            .rs1 = 0b00000,
            .rs2 = 0b00000,
            .rd = 0b00011,
            .xaluArithmeticFlag = 0,
            .xaluOp = 0b000,

            .valuOp = 63,
            .vecMode = 0,
            .isVectorOp = 0,

            .zeroXaluPrimary = 0,
            .pcXaluPrimary = 1,
            .immediateXaluSecondary = 1,
            .memoryOpSize = 0b11,
            .unsignedLoad = 0,
            .storeLoad = 0,
            .branchOp = 0b01,
            .branchNegate = 1,
            .jump = 1,
            .writeSource = 0b01,
        },

        // --- Vector: vadd.vv ---
        {
            .instruction = 0b000000'1'00010'00001'000'00011'1010111,
            .rs1 = 0b00001,
            .rs2 = 0b00010,
            .rd  = 0b00011,
            .xaluArithmeticFlag = 0,
            .xaluOp = 0b000,

            .valuOp = 0b000000, // funct6
            .vecMode = 0b000,   // VV
            .isVectorOp = 1,

            .zeroXaluPrimary = 0,
            .pcXaluPrimary = 0,
            .immediateXaluSecondary = 0,
            .memoryOpSize = 0b11,
            .unsignedLoad = 0,
            .storeLoad = 0,
            .branchOp = 0b01,
            .branchNegate = 0,
            .jump = 0,
            .writeSource = 0b100,
        }
    };

    int failed = 0;

    for (auto &t : tests) {
        dut.instruction = t.instruction;
        dut.eval();

        if (
            dut.rs1 != t.rs1 ||
            dut.rs2 != t.rs2 ||
            dut.rd != t.rd ||
            dut.xaluArithmeticFlag != t.xaluArithmeticFlag ||
            dut.xaluOp != t.xaluOp ||

            dut.valuOp != t.valuOp ||
            dut.vecMode != t.vecMode ||
            dut.isVectorOp != t.isVectorOp ||

            dut.zeroXaluPrimary != t.zeroXaluPrimary ||
            dut.pcXaluPrimary != t.pcXaluPrimary ||
            dut.immediateXaluSecondary != t.immediateXaluSecondary ||
            dut.memoryOpSize != t.memoryOpSize ||
            dut.unsignedLoad != t.unsignedLoad ||
            dut.storeLoad != t.storeLoad ||
            dut.branchOp != t.branchOp ||
            dut.branchNegate != t.branchNegate ||
            dut.jump != t.jump ||
            dut.writeSource != t.writeSource
        ) {
#define ERRPATTERN(field) std::cerr << #field " = " << (int)dut.field << ", expected " << t.field << "\n";
            ERRPATTERN(rs1)
            ERRPATTERN(rs2)
            ERRPATTERN(rd)
            ERRPATTERN(xaluArithmeticFlag)
            ERRPATTERN(xaluOp)

            ERRPATTERN(valuOp)
            ERRPATTERN(vecMode)
            ERRPATTERN(isVectorOp)

            ERRPATTERN(zeroXaluPrimary)
            ERRPATTERN(pcXaluPrimary)
            ERRPATTERN(immediateXaluSecondary)
            ERRPATTERN(memoryOpSize)
            ERRPATTERN(unsignedLoad)
            ERRPATTERN(storeLoad)
            ERRPATTERN(branchOp)
            ERRPATTERN(branchNegate)
            ERRPATTERN(jump)
            ERRPATTERN(writeSource)
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