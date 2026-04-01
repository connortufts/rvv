// check.h - reusable checker for verilator testbenches that I was using
// When writing tb:
// #include "../check.h"

// HOW TO USE:
// inputs to dut
// dut->eval();
// check("test name", dut->output, expected_value);

// check() work with any type (uint32_t, uint8_t, etc.)

// at end of main, pass_count and fail_count are available:
// printf("Passed: %d\n", pass_count);
// printf("Failed: %d\n", fail_count);

// EXAMPLE:
// dut->a = 100; dut->b = 50; dut->operation = ADD;
// dut->eval();
// check("ADD: 100 + 50 = 150", dut->result, (uint32_t)150);
#pragma once
#include <cstdio>

static int pass_count = 0;
static int fail_count = 0;

template<typename T>
void check(const char* name, T actual, T expected) {
    if (actual == expected) {
        printf("PASS: %s\n", name);
        pass_count++;
    } else {
        printf("FAIL: %s | expected: 0x%08X, got: 0x%08X\n",
               name, (uint32_t)expected, (uint32_t)actual);
        fail_count++;
    }
}