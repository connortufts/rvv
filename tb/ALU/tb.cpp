// ALU
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <ctime>
#include "VALU.h"
#include "verilated.h"
#include "check.h"

// ALU operation encodings
enum AluOp {
    ADD    = 0b00000,
    SUB    = 0b00001,
    SLL    = 0b00010,
    SLT    = 0b00011,
    SLTU   = 0b00100,
    XOR    = 0b00101,
    SRL    = 0b00110,
    SRA    = 0b00111,
    OR     = 0b01000,
    AND    = 0b01001,
    MUL    = 0b01010,
    MULH   = 0b01011,
    MULHSU = 0b01100,
    MULHU  = 0b01101,
    DIV    = 0b01110,
    DIVU   = 0b01111,
    REM    = 0b10000,
    REMU   = 0b10001
};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    srand(time(NULL));
    VALU dut;
    
    printf("ALU Verilator Tests\n");
    
    // RV32I Base Integer Tests
    printf("RV32I Base Operations\n");
    
    // ADD
    dut.a = 100; dut.b = 50; dut.operation = ADD;
    dut.eval();
    check("ADD: 100 + 50 = 150", dut.result, (uint32_t)150);
    
    dut.a = 10; dut.b = (uint32_t)(-20); dut.operation = ADD;
    dut.eval();
    check("ADD: 10 + (-20) = -10", dut.result, (uint32_t)(-10));
    
    // SUB
    dut.a = 100; dut.b = 30; dut.operation = SUB;
    dut.eval();
    check("SUB: 100 - 30 = 70", dut.result, (uint32_t)70);
    
    dut.a = 10; dut.b = 20; dut.operation = SUB;
    dut.eval();
    check("SUB: 10 - 20 = -10", dut.result, (uint32_t)(-10));
    
    // SLL
    dut.a = 0x00000001; dut.b = 4; dut.operation = SLL;
    dut.eval();
    check("SLL: 1 << 4 = 16", dut.result, (uint32_t)0x00000010);
    
    dut.a = 0x0000000F; dut.b = 8; dut.operation = SLL;
    dut.eval();
    check("SLL: 0xF << 8 = 0xF00", dut.result, (uint32_t)0x00000F00);
    
    // SLT
    dut.a = (uint32_t)(-5); dut.b = 5; dut.operation = SLT;
    dut.eval();
    check("SLT: -5 < 5 (signed) = 1", dut.result, (uint32_t)1);
    
    dut.a = 10; dut.b = 5; dut.operation = SLT;
    dut.eval();
    check("SLT: 10 < 5 (signed) = 0", dut.result, (uint32_t)0);
    
    // SLTU
    dut.a = 0xFFFFFFFF; dut.b = 1; dut.operation = SLTU;
    dut.eval();
    check("SLTU: 0xFFFFFFFF < 1 (unsigned) = 0", dut.result, (uint32_t)0);
    
    dut.a = 1; dut.b = 0xFFFFFFFF; dut.operation = SLTU;
    dut.eval();
    check("SLTU: 1 < 0xFFFFFFFF (unsigned) = 1", dut.result, (uint32_t)1);
    
    // XOR
    dut.a = 0xAAAAAAAA; dut.b = 0x55555555; dut.operation = XOR;
    dut.eval();
    check("XOR: 0xAAAAAAAA ^ 0x55555555 = 0xFFFFFFFF", dut.result, (uint32_t)0xFFFFFFFF);
    
    // SRL
    dut.a = 0x80000000; dut.b = 4; dut.operation = SRL;
    dut.eval();
    check("SRL: 0x80000000 >> 4 = 0x08000000", dut.result, (uint32_t)0x08000000);
    
    // SRA
    dut.a = 0x80000000; dut.b = 4; dut.operation = SRA;
    dut.eval();
    check("SRA: 0x80000000 >>> 4 = 0xF8000000", dut.result, (uint32_t)0xF8000000);
    
    dut.a = 0x40000000; dut.b = 4; dut.operation = SRA;
    dut.eval();
    check("SRA: 0x40000000 >>> 4 = 0x04000000", dut.result, (uint32_t)0x04000000);
    
    // OR
    dut.a = 0xFF00FF00; dut.b = 0x00FF00FF; dut.operation = OR;
    dut.eval();
    check("OR: 0xFF00FF00 | 0x00FF00FF = 0xFFFFFFFF", dut.result, (uint32_t)0xFFFFFFFF);
    
    // AND
    dut.a = 0xFF00FF00; dut.b = 0xF0F0F0F0; dut.operation = AND;
    dut.eval();
    check("AND: 0xFF00FF00 & 0xF0F0F0F0 = 0xF000F000", dut.result, (uint32_t)0xF000F000);
    
    // RV32M Multiply Tests
    printf("\nRV32M Multiply Operations\n");
    
    // MUL
    dut.a = 100; dut.b = 50; dut.operation = MUL;
    dut.eval();
    check("MUL: 100 * 50 = 5000", dut.result, (uint32_t)5000);
    
    dut.a = (uint32_t)(-10); dut.b = 5; dut.operation = MUL;
    dut.eval();
    check("MUL: -10 * 5 = -50", dut.result, (uint32_t)(-50));
    
    // MULH
    dut.a = 0x80000000; dut.b = 2; dut.operation = MULH;
    dut.eval();
    check("MULH: 0x80000000 * 2 upper", dut.result, (uint32_t)0xFFFFFFFF);
    
    // MULHU
    dut.a = 0xFFFFFFFF; dut.b = 0xFFFFFFFF; dut.operation = MULHU;
    dut.eval();
    check("MULHU: 0xFFFFFFFF * 0xFFFFFFFF upper", dut.result, (uint32_t)0xFFFFFFFE);
    
    // RV32M Division Operations
    printf("\n RV32M Division Operations \n");
    
    // DIV
    dut.a = 100; dut.b = 10; dut.operation = DIV;
    dut.eval();
    check("DIV: 100 / 10 = 10", dut.result, (uint32_t)10);
    
    dut.a = (uint32_t)(-100); dut.b = 10; dut.operation = DIV;
    dut.eval();
    check("DIV: -100 / 10 = -10", dut.result, (uint32_t)(-10));
    
    // DIVU
    dut.a = 100; dut.b = 10; dut.operation = DIVU;
    dut.eval();
    check("DIVU: 100 / 10 = 10", dut.result, (uint32_t)10);
    
    // REM
    dut.a = 17; dut.b = 5; dut.operation = REM;
    dut.eval();
    check("REM: 17 % 5 = 2", dut.result, (uint32_t)2);
    
    dut.a = (uint32_t)(-17); dut.b = 5; dut.operation = REM;
    dut.eval();
    check("REM: -17 % 5 = -2", dut.result, (uint32_t)(-2));
    
    // REMU
    dut.a = 17; dut.b = 5; dut.operation = REMU;
    dut.eval();
    check("REMU: 17 % 5 = 2", dut.result, (uint32_t)2);
    
    // Edge cases
    printf("\nEdge Cases (from Spec) \n");
    
    dut.a = 100; dut.b = 0; dut.operation = DIV;
    dut.eval();
    check("DIV by 0: returns all 1s", dut.result, (uint32_t)0xFFFFFFFF);
    
    dut.a = 100; dut.b = 0; dut.operation = DIVU;
    dut.eval();
    check("DIVU by 0: returns all 1s", dut.result, (uint32_t)0xFFFFFFFF);
    
    dut.a = 100; dut.b = 0; dut.operation = REM;
    dut.eval();
    check("REM by 0: returns dividend", dut.result, (uint32_t)100);
    
    dut.a = 100; dut.b = 0; dut.operation = REMU;
    dut.eval();
    check("REMU by 0: returns dividend", dut.result, (uint32_t)100);
    
    dut.a = 0x80000000; dut.b = 0xFFFFFFFF; dut.operation = DIV;
    dut.eval();
    check("DIV overflow: -2^31 / -1 = -2^31", dut.result, (uint32_t)0x80000000);
    
    dut.a = 0x80000000; dut.b = 0xFFFFFFFF; dut.operation = REM;
    dut.eval();
    check("REM overflow: -2^31 % -1 = 0", dut.result, (uint32_t)0);
    
    // Zero flag
    printf("\n Zero Flag \n");
    
    dut.a = 50; dut.b = 50; dut.operation = SUB;
    dut.eval();
    check("Zero flag: 50 - 50 = 0", dut.zero, (uint8_t)1);
    
    dut.a = 50; dut.b = 49; dut.operation = SUB;
    dut.eval();
    check("Zero flag: 50 - 49 = 1 (not zero)", dut.zero, (uint8_t)0);
    
    // Random tests
    printf("Running random tests...\n");

    for (int i = 0; i < 10000; i++) {
        uint32_t a = rand();
        uint32_t b = rand();
        int op = rand() % 10;

        dut.a = a;
        dut.b = b;

        uint32_t expected = 0;

        switch(op) {
            case 0: dut.operation = ADD;  expected = a + b; break;
            case 1: dut.operation = SUB;  expected = a - b; break;
            case 2: dut.operation = AND;  expected = a & b; break;
            case 3: dut.operation = OR;   expected = a | b; break;
            case 4: dut.operation = XOR;  expected = a ^ b; break;
            case 5: dut.operation = SLTU; expected = (a < b) ? 1 : 0; break;
            case 6: dut.operation = SLL;  expected = a << (b & 0x1F); break;
            case 7: dut.operation = SRL;  expected = a >> (b & 0x1F); break;
            case 8: dut.operation = SRA;  expected = ((int32_t)a) >> (b & 0x1F); break;
            case 9:
                if (b == 0) continue;
                dut.operation = DIV;
                expected = (int32_t)a / (int32_t)b;
                break;
        }

        dut.eval();

        if (dut.result != expected) {
            printf("\nRANDOM FAIL\n");
            printf("a=0x%08X b=0x%08X op=%d\n", a, b, op);
            printf("expected=0x%08X got=0x%08X\n", expected, dut.result);
            return 1;
        }
    }

    printf("Random tests passed\n");

    // Summary
    printf("\nSummary\n");
    printf("Passed: %d\n", pass_count);
    printf("Failed: %d\n", fail_count);
    printf("\n\n");
    
    return fail_count > 0 ? 1 : 0;
}
