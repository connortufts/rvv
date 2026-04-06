// ALU
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <ctime>
#include "VXALU.h"

static void check(const char* name, uint32_t actual, uint32_t expected){
    if(actual != expected){
        printf("FAIL: %s | expected: 0x%08X, got: 0x%08X\n", name, expected, actual);
        exit(EXIT_FAILURE);
    }
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    srand(time(NULL));
    VXALU dut;

    // ADD
    dut.inputPrimary = 100;
    dut.inputSecondary = 51;
    dut.operation = 0b000;
    dut.arithmeticFlag = 0;
    dut.eval();
    check("ADD: 100 + 51 = 151", dut.result, 151);

    // SUB
    dut.operation = 0b000;
    dut.arithmeticFlag = 1;
    dut.eval();
    dut.arithmeticFlag = 0;
    check("SUB: 100 - 51 = 49", dut.result, 49);

    // SLL
    dut.inputPrimary = 16;
    dut.inputSecondary = 2;
    dut.operation = 0b001;
    dut.eval();
    check("SLL: 16 << 2 = 64", dut.result, 64);

    // SLT
    dut.inputPrimary = -1;
    dut.inputSecondary = 1;
    dut.operation = 0b010;
    dut.eval();
    check("SLT: -1 < 1 = 1", dut.result, 1);

    // SLTU
    dut.operation = 0b011;
    dut.eval();
    check("SLTU: -1 < 1 = 0", dut.result, 0);

    // XOR
    dut.inputPrimary = 0b1001;
    dut.inputSecondary = 0b1111;
    dut.operation = 0b100;
    dut.eval();
    check("XOR: 0b1001 ^ 0b1111 = 0b0110", dut.result, 0b0110);

    // SRL
    dut.inputPrimary = 0b11111111111111111111111111111111;
    dut.inputSecondary = 2;
    dut.operation = 0b101;
    dut.eval();
    check("SRL: 0b11111111111111111111111111111111 >> 2 = 0b00111111111111111111111111111111", dut.result, 0b00111111111111111111111111111111);

    // SRA
    dut.arithmeticFlag = 1;
    dut.eval();
    dut.arithmeticFlag = 0;
    check("SRA: 0b11111111111111111111111111111111 >>> 2 = 0b11111111111111111111111111111111", dut.result, 0b11111111111111111111111111111111);

    // OR
    dut.inputPrimary = 0b1001;
    dut.inputSecondary = 0b0110;
    dut.operation = 0b110;
    dut.eval();
    check("OR: 0b1001 | 0b0110 = 0b1111", dut.result, 0b1111);

    // AND
    dut.operation = 0b111;
    dut.eval();
    check("AND: 0b1001 & 0b0110 = 0b0000", dut.result, 0b0000);

    return EXIT_SUCCESS;
}
