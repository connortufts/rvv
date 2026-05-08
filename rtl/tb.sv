`timescale 1ns/1ps

import rvDefs::*;

module tb;

    parameter integer IMEM_DEPTH = 4096;        // instruction words (16 KB)
    parameter integer MAX_CYCLES = 100_000;     // watchdog
    parameter integer CLK_HALF   = 5;           // ns  -> 100 MHz

    localparam logic [31:0] EBREAK = 32'h0010_0073;

    // =========================================================================
    //  Clock & reset
    // =========================================================================
    logic CLK  = 0;
    logic RSTN = 0;

    always #CLK_HALF CLK = ~CLK;

    initial begin
        RSTN = 0;
        repeat (4) @(posedge CLK);
        @(negedge CLK);
        RSTN = 1;
    end

    // =========================================================================
    //  DUT interface
    // =========================================================================
    instruction_t instructionWord;
    mem_addr_t instructionAddress;
    logic         stall;

    assign stall = 1'b0;    // both memories are 1-cycle; no stall needed

    // =========================================================================
    //  DUT
    // =========================================================================
    top u_dut (
        .CLK             ( CLK              ),
        .RSTN            ( RSTN             ),
        .instructionAddress(instructionAddress),
        .instructionWord(instructionWord),
        .stall           ( stall            )
    );

    // =========================================================================
    //  Instruction ROM
    //  Word-addressed: imem[PC[31:2]]
    //  Synchronous read (1-cycle latency) — matches real ROM behaviour.
    //  Out-of-range addresses return NOP (addi x0,x0,0).
    // =========================================================================

    instruction_t imem [0 : IMEM_DEPTH - 1];

    initial begin
        $readmemb("rom", imem);
    end

    always_comb begin
        if (instructionAddress[31:2] < IMEM_DEPTH)
            instructionWord = imem[instructionAddress[31:2]];
        else
            instructionWord = 32'h0000_0013;   // NOP for out-of-range
    end

    // =========================================================================
    //  Cycle counter & watchdog
    // =========================================================================
    integer cycle_count;

    always_ff @(posedge CLK) begin
        if (RSTN) begin
            cycle_count <= cycle_count + 1;
            if (cycle_count >= MAX_CYCLES) begin
                $display("[TB] WATCHDOG: %0d cycles elapsed. Stopping.", MAX_CYCLES);
                $finish;
            end
        end
    end

    // =========================================================================
    //  Halt detection (checks the instruction the core just received)
    // =========================================================================
    //always_ff @(posedge CLK) begin
        //if (RSTN) begin
            //if (instructionWord === EBREAK) begin
                //$display("[TB] EBREAK at PC=0x%08h  cycle=%0d — done.",
                          //instructionAddress, cycle_count);
                //#(CLK_HALF * 4);
                //$finish;
            //end
            //if (instructionWord === 32'h0000_0000) begin
                //$display("[TB] All-zero fetch at PC=0x%08h — possible runaway. Stopping.",
                          //instructionAddress, cycle_count);
                //$finish;
            //end
        //end
    //end

    // =========================================================================
    //  Execution trace
    //  Define NO_TRACE to silence per-cycle output.
    // =========================================================================
    always_ff @(posedge CLK) begin
            $display("x1 = %0d", u_dut.core.xRegisterFile.registers[1]);
            $display("x2 = %0d", u_dut.core.xRegisterFile.registers[2]);
            $display("x3 = %0d", u_dut.core.xRegisterFile.registers[3]);
            $display("x4 = %0d", u_dut.core.xRegisterFile.registers[4]);
            $display("x5 = %0d", u_dut.core.xRegisterFile.registers[5]);
            $display("x6 = %0d", u_dut.core.xRegisterFile.registers[6]);
            $display("x7 = %0d", u_dut.core.xRegisterFile.registers[7]);
            $display("x8 = %0d", u_dut.core.xRegisterFile.registers[8]);
            $display("x9 = %0d", u_dut.core.xRegisterFile.registers[9]);
            $display("x10 = %0d", u_dut.core.xRegisterFile.registers[10]);
            $display("x11 = %0d", u_dut.core.xRegisterFile.registers[11]);
            $display("x12 = %0d", u_dut.core.xRegisterFile.registers[12]);
            $display("x13 = %0d", u_dut.core.xRegisterFile.registers[13]);
            $display("x14 = %0d", u_dut.core.xRegisterFile.registers[14]);
            $display("x15 = %0d", u_dut.core.xRegisterFile.registers[15]);
            $display("x16 = %0d", u_dut.core.xRegisterFile.registers[16]);
            $display("x17 = %0d", u_dut.core.xRegisterFile.registers[17]);
            $display("x18 = %0d", u_dut.core.xRegisterFile.registers[18]);
            $display("x19 = %0d", u_dut.core.xRegisterFile.registers[19]);
            $display("x30 = %0d", u_dut.core.xRegisterFile.registers[30]);
            $display("x31 = %0d", u_dut.core.xRegisterFile.registers[31]);
            $display("d[0] = %0d", u_dut.dmem.memory[0]);
            $display("d[4] = %0d", u_dut.dmem.memory[1]);
            $display("d[8] = %0d", u_dut.dmem.memory[2]);
            $display("d[12] = %0d", u_dut.dmem.memory[3]);
            $display("d[16] = %0d", u_dut.dmem.memory[4]);
            $display("d[20] = %0d", u_dut.dmem.memory[5]);
            $display("d[24] = %0d", u_dut.dmem.memory[6]);
            $display("d[28] = %0d", u_dut.dmem.memory[7]);
            $display("pc = 0x%08h, ins = 0x%08h", u_dut.instructionAddress, u_dut.instructionWord);
    end

    // =========================================================================
    //  Waveform dump
    // =========================================================================
    //initial begin
    //    $dumpfile("tb_top.vcd");
    //    $dumpvars(0, tb_top);
    //end

endmodule
