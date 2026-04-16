`timescale 1ns/1ps
`default_nettype none

module tb;

    import rvDefs::*;

    // ----------------------------
    // DUT signals
    // ----------------------------
    logic sysclk;
    logic sysreset;

    mem_addr_t instructionAddr;
    instruction_t instruction;
    word_t dmemview;
    mem_addr_t viewaddr;

    top dut (
        .sysclk(sysclk),
        .sysreset(sysreset),
        .instructionAddr(instructionAddr),
        .instruction(instruction),
        .dmemview(dmemview),
        .viewaddr(viewaddr)
    );

    // ----------------------------
    // Instruction memory (same as C++)
    // ----------------------------
    instruction_t inst [0:21];

    initial begin
        // 0x00
        inst[0]  = 32'b000000000011_00000_000_00011_0010011;

        // 0x04
        inst[1]  = 32'b0000000_00011_00000_010_00000_0100011;

        // 0x08
        inst[2]  = 32'b000000000001_00000_000_00100_0010011;

        // 0x0c
        inst[3]  = 32'b0100000_00100_00011_000_00011_0110011;

        // 0x10
        inst[4]  = 32'b0000000_00011_00000_010_00000_0100011;

        // 0x14
        inst[5]  = 32'b1111111_00000_00011_001_11001_1100011;

        // 0x18
        inst[6]  = 32'b000000000000_00000_000_00101_0010011;

        // 0x1c
        inst[7]  = 32'b00000000000010010011_00101_0110111;

        // 0x20
        inst[8]  = 32'b0000000_00101_00000_010_00000_0100011;

        // 0x24
        inst[9]  = 32'b00000000000000000000_00101_0010111;

        // 0x28
        inst[10] = 32'b0000000_00101_00000_010_00000_0100011;

        // 0x2c
        inst[11] = 32'b000000001010_00000_000_00110_0010011;

        // 0x30
        inst[12] = 32'b0000000_00110_00000_010_00100_0100011;

        // 0x34
        inst[13] = 32'b000000000100_00000_010_00101_0000011;

        // 0x38
        inst[14] = 32'b0000000_00101_00000_010_00000_0100011;

        // 0x3c
        inst[15] = 32'b00000001010000000000_10000_1101111;

        // 0x40
        inst[16] = 32'b0000000_00000_00000_000_10100_1100011;

        // 0x44
        inst[17] = 32'b000000000000_00000_000_00000_0010011;

        // 0x48
        inst[18] = 32'b000000000000_00000_000_00000_0010011;

        // 0x4c
        inst[19] = 32'b000000000000_00000_000_00000_0010011;

        // 0x50
        inst[20] = 32'b000000000000_10000_000_00000_1100111;

        // 0x54
        inst[21] = 32'b000000000000_00000_000_00000_0010011;
    end

    // ----------------------------
    // Instruction fetch (like C++ pointer cast)
    // ----------------------------
    assign instruction = inst[instructionAddr >> 2];

    // ----------------------------
    // Clock
    // ----------------------------
    always #5 sysclk = ~sysclk;

    // ----------------------------
    // Test
    // ----------------------------
    initial begin
        sysclk   = 0;
        sysreset = 1;
        viewaddr = 0;

        // reset sequence (matches C++)
        #10;
        sysreset = 0;
        #10;
        sysreset = 1;
        #10;

        // run loop
        while (1) begin

            // rising edge
            sysclk = 1;
            #1;

            // combinational instruction fetch happens continuously
            #4;

            // evaluate DUT state (like top.eval())
            $display("^ PC: 0x%0h DMEM0: 0x%0h", instructionAddr, dmemview);

            // falling edge
            sysclk = 0;
            #5;

            $display("V PC: 0x%0h DMEM0: 0x%0h", instructionAddr, dmemview);

            if (instructionAddr == 32'h54) begin
                break;
            end
        end

        $finish;
    end

endmodule

`default_nettype wire