// tb_TOP.sv
`timescale 1ns/1ps
`default_nettype none

module tb_TOP;

    // -------------------------------------------------------
    // Clock and reset
    // -------------------------------------------------------
    logic FCLK, HCLK, SCLK, DCLK;
    logic PORESETn, DBGRESETn;
    logic HRESETn;

    // -------------------------------------------------------
    // Unused inputs
    // -------------------------------------------------------
    logic        EXTCLK0, EXTCLK1;
    logic        TXEV, RXEV;
    logic        LOCKUPREQ, WDOGRESETREQ, SYSRESETREQ;
    logic        CRG_DIAG0, CRG_DIAG1;
    logic        SLEEPING, SLEEPDEEP;
    logic        FESEL;
    logic        SCLK1, SCLK2, SHIFTIN, SCEN, SHIFTOUT;
    logic        UART_M_RXD, UART_M_TXD;
    logic        UART_M_CTS, UART_M_RTS;
    logic        UART_M_BAUD_SEL0, UART_M_BAUD_SEL1;
    logic        UART_M_BAUD_SEL2, UART_M_BAUD_SEL3;
    logic        UART2_TXD, UART2_RXD;
    logic        TIMER0_EXTIN, TIMER1_EXTIN;
    logic [15:0] GPIO0_PORTIN,  GPIO0_PORTOUT, GPIO0_PORTEN;
    logic [15:0] GPIO1_PORTIN,  GPIO1_PORTOUT, GPIO1_PORTEN;

    // -------------------------------------------------------
    // DUT
    // -------------------------------------------------------
    TOP u_top (
        .FCLK,  .HCLK,  .DCLK,  .SCLK,
        .HRESETn,
        .PORESETn,   .DBGRESETn,
        .EXTCLK0,    .EXTCLK1,
        .TXEV,       .RXEV,
        .LOCKUPREQ,  .WDOGRESETREQ,  .SYSRESETREQ,
        .CRG_DIAG0,  .CRG_DIAG1,
        .SLEEPING,   .SLEEPDEEP,
        .FESEL,
        .SCLK1, .SCLK2, .SHIFTIN, .SCEN, .SHIFTOUT,
        .UART_M_RXD,  .UART_M_TXD,
        .UART_M_CTS,  .UART_M_RTS,
        .UART_M_BAUD_SEL0, .UART_M_BAUD_SEL1,
        .UART_M_BAUD_SEL2, .UART_M_BAUD_SEL3,
        .UART2_TXD,  .UART2_RXD,
        .TIMER0_EXTIN, .TIMER1_EXTIN,

        .GPIO0_PORTIN0(GPIO0_PORTIN[0]),
        .GPIO0_PORTIN1(GPIO0_PORTIN[1]),
        .GPIO0_PORTIN2(GPIO0_PORTIN[2]),
        .GPIO0_PORTIN3(GPIO0_PORTIN[3]),
        .GPIO0_PORTIN4(GPIO0_PORTIN[4]),
        .GPIO0_PORTIN5(GPIO0_PORTIN[5]),
        .GPIO0_PORTIN6(GPIO0_PORTIN[6]),
        .GPIO0_PORTIN7(GPIO0_PORTIN[7]),
        .GPIO0_PORTIN8(GPIO0_PORTIN[8]),
        .GPIO0_PORTIN9(GPIO0_PORTIN[9]),
        .GPIO0_PORTIN10(GPIO0_PORTIN[10]),
        .GPIO0_PORTIN11(GPIO0_PORTIN[11]),
        .GPIO0_PORTIN12(GPIO0_PORTIN[12]),
        .GPIO0_PORTIN13(GPIO0_PORTIN[13]),
        .GPIO0_PORTIN14(GPIO0_PORTIN[14]),
        .GPIO0_PORTIN15(GPIO0_PORTIN[15]),

        .GPIO0_PORTOUT0(GPIO0_PORTOUT[0]),
        .GPIO0_PORTOUT1(GPIO0_PORTOUT[1]),
        .GPIO0_PORTOUT2(GPIO0_PORTOUT[2]),
        .GPIO0_PORTOUT3(GPIO0_PORTOUT[3]),
        .GPIO0_PORTOUT4(GPIO0_PORTOUT[4]),
        .GPIO0_PORTOUT5(GPIO0_PORTOUT[5]),
        .GPIO0_PORTOUT6(GPIO0_PORTOUT[6]),
        .GPIO0_PORTOUT7(GPIO0_PORTOUT[7]),
        .GPIO0_PORTOUT8(GPIO0_PORTOUT[8]),
        .GPIO0_PORTOUT9(GPIO0_PORTOUT[9]),
        .GPIO0_PORTOUT10(GPIO0_PORTOUT[10]),
        .GPIO0_PORTOUT11(GPIO0_PORTOUT[11]),
        .GPIO0_PORTOUT12(GPIO0_PORTOUT[12]),
        .GPIO0_PORTOUT13(GPIO0_PORTOUT[13]),
        .GPIO0_PORTOUT14(GPIO0_PORTOUT[14]),
        .GPIO0_PORTOUT15(GPIO0_PORTOUT[15]),

        .GPIO0_PORTEN0(GPIO0_PORTEN[0]),
        .GPIO0_PORTEN1(GPIO0_PORTEN[1]),
        .GPIO0_PORTEN2(GPIO0_PORTEN[2]),
        .GPIO0_PORTEN3(GPIO0_PORTEN[3]),
        .GPIO0_PORTEN4(GPIO0_PORTEN[4]),
        .GPIO0_PORTEN5(GPIO0_PORTEN[5]),
        .GPIO0_PORTEN6(GPIO0_PORTEN[6]),
        .GPIO0_PORTEN7(GPIO0_PORTEN[7]),
        .GPIO0_PORTEN8(GPIO0_PORTEN[8]),
        .GPIO0_PORTEN9(GPIO0_PORTEN[9]),
        .GPIO0_PORTEN10(GPIO0_PORTEN[10]),
        .GPIO0_PORTEN11(GPIO0_PORTEN[11]),
        .GPIO0_PORTEN12(GPIO0_PORTEN[12]),
        .GPIO0_PORTEN13(GPIO0_PORTEN[13]),
        .GPIO0_PORTEN14(GPIO0_PORTEN[14]),
        .GPIO0_PORTEN15(GPIO0_PORTEN[15]),

        .GPIO1_PORTIN0(GPIO1_PORTIN[0]),
        .GPIO1_PORTIN1(GPIO1_PORTIN[1]),
        .GPIO1_PORTIN2(GPIO1_PORTIN[2]),
        .GPIO1_PORTIN3(GPIO1_PORTIN[3]),
        .GPIO1_PORTIN4(GPIO1_PORTIN[4]),
        .GPIO1_PORTIN5(GPIO1_PORTIN[5]),
        .GPIO1_PORTIN6(GPIO1_PORTIN[6]),
        .GPIO1_PORTIN7(GPIO1_PORTIN[7]),
        .GPIO1_PORTIN8(GPIO1_PORTIN[8]),
        .GPIO1_PORTIN9(GPIO1_PORTIN[9]),
        .GPIO1_PORTIN10(GPIO1_PORTIN[10]),
        .GPIO1_PORTIN11(GPIO1_PORTIN[11]),
        .GPIO1_PORTIN12(GPIO1_PORTIN[12]),
        .GPIO1_PORTIN13(GPIO1_PORTIN[13]),
        .GPIO1_PORTIN14(GPIO1_PORTIN[14]),
        .GPIO1_PORTIN15(GPIO1_PORTIN[15]),

        .GPIO1_PORTOUT0(GPIO1_PORTOUT[0]),
        .GPIO1_PORTOUT1(GPIO1_PORTOUT[1]),
        .GPIO1_PORTOUT2(GPIO1_PORTOUT[2]),
        .GPIO1_PORTOUT3(GPIO1_PORTOUT[3]),
        .GPIO1_PORTOUT4(GPIO1_PORTOUT[4]),
        .GPIO1_PORTOUT5(GPIO1_PORTOUT[5]),
        .GPIO1_PORTOUT6(GPIO1_PORTOUT[6]),
        .GPIO1_PORTOUT7(GPIO1_PORTOUT[7]),
        .GPIO1_PORTOUT8(GPIO1_PORTOUT[8]),
        .GPIO1_PORTOUT9(GPIO1_PORTOUT[9]),
        .GPIO1_PORTOUT10(GPIO1_PORTOUT[10]),
        .GPIO1_PORTOUT11(GPIO1_PORTOUT[11]),
        .GPIO1_PORTOUT12(GPIO1_PORTOUT[12]),
        .GPIO1_PORTOUT13(GPIO1_PORTOUT[13]),
        .GPIO1_PORTOUT14(GPIO1_PORTOUT[14]),
        .GPIO1_PORTOUT15(GPIO1_PORTOUT[15]),

        .GPIO1_PORTEN0(GPIO1_PORTEN[0]),
        .GPIO1_PORTEN1(GPIO1_PORTEN[1]),
        .GPIO1_PORTEN2(GPIO1_PORTEN[2]),
        .GPIO1_PORTEN3(GPIO1_PORTEN[3]),
        .GPIO1_PORTEN4(GPIO1_PORTEN[4]),
        .GPIO1_PORTEN5(GPIO1_PORTEN[5]),
        .GPIO1_PORTEN6(GPIO1_PORTEN[6]),
        .GPIO1_PORTEN7(GPIO1_PORTEN[7]),
        .GPIO1_PORTEN8(GPIO1_PORTEN[8]),
        .GPIO1_PORTEN9(GPIO1_PORTEN[9]),
        .GPIO1_PORTEN10(GPIO1_PORTEN[10]),
        .GPIO1_PORTEN11(GPIO1_PORTEN[11]),
        .GPIO1_PORTEN12(GPIO1_PORTEN[12]),
        .GPIO1_PORTEN13(GPIO1_PORTEN[13]),
        .GPIO1_PORTEN14(GPIO1_PORTEN[14]),
        .GPIO1_PORTEN15(GPIO1_PORTEN[15])
    );

    // -------------------------------------------------------
    // Clock generation
    // -------------------------------------------------------
    localparam CLK_HALF = 5; // 10ns period = 100MHz

    initial FCLK = 0;
    always #CLK_HALF FCLK = ~FCLK;
    assign HCLK  = FCLK;
    assign SCLK  = FCLK;
    assign DCLK  = FCLK;
    assign SCLK1 = FCLK;
    assign SCLK2 = FCLK;

    // -------------------------------------------------------
    // Tie off unused inputs
    // -------------------------------------------------------
    assign DBGRESETn        = 1'b1;
    assign EXTCLK0          = 1'b0;
    assign EXTCLK1          = 1'b0;
    assign RXEV             = 1'b0;
    assign FESEL            = 1'b0;
    assign SHIFTIN          = 1'b0;
    assign SCEN             = 1'b0;
    assign UART_M_RXD       = 1'b1;
    assign UART_M_CTS       = 1'b0;
    assign UART_M_BAUD_SEL0 = 1'b0;
    assign UART_M_BAUD_SEL1 = 1'b0;
    assign UART_M_BAUD_SEL2 = 1'b0;
    assign UART_M_BAUD_SEL3 = 1'b0;
    assign UART2_RXD        = 1'b1;
    assign TIMER0_EXTIN     = 1'b0;
    assign TIMER1_EXTIN     = 1'b0;
    assign GPIO0_PORTIN     = 16'h0;
    assign GPIO1_PORTIN     = 16'h0;

    // -------------------------------------------------------
    // Test program
    // Same instructions as the C++ testbench
    // -------------------------------------------------------
    localparam N_INST = 22;
    logic [31:0] inst [0:N_INST-1];

    initial begin
        inst[0]  = 32'b000000000011_00000_000_00011_0010011; // addi x3, x0, 3
        inst[1]  = 32'b0000000_00011_00000_010_00000_0100011;// sw x3, 0(x0)
        inst[2]  = 32'b000000000001_00000_000_00100_0010011; // addi x4, x0, 1
        inst[3]  = 32'b0100000_00100_00011_000_00011_0110011;// sub x3, x3, x4
        inst[4]  = 32'b0000000_00011_00000_010_00000_0100011;// sw x3, 0(x0)
        inst[5]  = 32'b1111111_00000_00011_001_11001_1100011;// bne x3, x0, -8
        inst[6]  = 32'b000000000000_00000_000_00101_0010011; // addi x5, x0, 0
        inst[7]  = 32'b00000000000010010011_00101_0110111;   // lui x5, 0x93
        inst[8]  = 32'b0000000_00101_00000_010_00000_0100011;// sw x5, 0(x0)
        inst[9]  = 32'b00000000000000000000_00101_0010111;   // auipc x5, 0
        inst[10] = 32'b0000000_00101_00000_010_00000_0100011;// sw x5, 0(x0)
        inst[11] = 32'b000000001010_00000_000_00110_0010011; // addi x6, x0, 10
        inst[12] = 32'b0000000_00110_00000_010_00100_0100011;// sw x6, 4(x0)
        inst[13] = 32'b000000000100_00000_010_00101_0000011; // lw x5, 4(x0)
        inst[14] = 32'b0000000_00101_00000_010_00000_0100011;// sw x5, 0(x0)
        inst[15] = 32'b00000001010000000000_10000_1101111;   // jal x16, +20
        inst[16] = 32'b0000000_00000_00000_000_10100_1100011;// beq x0,x0,+0
        inst[17] = 32'b000000000000_00000_000_00000_0010011; // nop
        inst[18] = 32'b000000000000_00000_000_00000_0010011; // nop
        inst[19] = 32'b000000000000_00000_000_00000_0010011; // nop
        inst[20] = 32'b000000000000_10000_000_00000_1100111; // jalr x0,x16,0
        inst[21] = 32'b000000000000_00000_000_00000_0010011; // nop (branch tgt)
    end

    // -------------------------------------------------------
    // Hierarchical references
    // Adjust paths if your internal signal names differ
    // -------------------------------------------------------
    `define CPU_PC      u_top.uACCEL.cpu_pc
    `define CPU_INSTR   u_top.uACCEL.cpu_instruction
    `define CTRL        u_top.uACCEL.CTRL
    `define STALL       u_top.uRiscvCore_SYS.stall
    `define IMEM        u_top.uACCEL.u_imem.memory
    `define DMEM        u_top.uACCEL.u_dmem.memory
    `define XREGS       u_top.uRiscvCore_SYS.u_riscv.xRegisterFile.registers

    // -------------------------------------------------------
    // Helper functions
    // -------------------------------------------------------
    function automatic logic [31:0] read_dmem_word(input int byte_addr);
        return {`DMEM[byte_addr+3], `DMEM[byte_addr+2],
                `DMEM[byte_addr+1], `DMEM[byte_addr+0]};
    endfunction

    function automatic logic [31:0] safe_fetch(input logic [31:0] pc);
        int idx;
        idx = pc / 4;
        if (idx >= N_INST) return 32'h00000013; // NOP if out of range
        return inst[idx];
    endfunction

    // -------------------------------------------------------
    // Scoreboard
    // -------------------------------------------------------
    int pass_count = 0;
    int fail_count = 0;

    task automatic check;
        input string      name;
        input logic [31:0] got;
        input logic [31:0] expected;
        if (got === expected) begin
            $display("    PASS  %-35s got=0x%08X", name, got);
            pass_count++;
        end else begin
            $display("    FAIL  %-35s got=0x%08X  expected=0x%08X",
                     name, got, expected);
            fail_count++;
        end
    endtask

    // -------------------------------------------------------
    // Print one row of execution trace
    // -------------------------------------------------------
    task automatic print_state(input string clk_edge, input int cycle);
        $display(
            "%5d | %s | PC=0x%08X | INSTR=0x%08X | DMEM[0]=0x%08X | DMEM[4]=0x%08X | stall=%b",
            cycle, clk_edge,
            `CPU_PC,
            safe_fetch(`CPU_PC),
            read_dmem_word(0),
            read_dmem_word(4),
            `STALL
        );
    endtask

    // -------------------------------------------------------
    // Main test sequence
    // -------------------------------------------------------
    int          cycle;
    int          stable_count;
    logic [31:0] last_pc;

    initial begin
        $dumpfile("tb_TOP.vcd");
        $dumpvars(0, tb_TOP);

        $display("========================================");
        $display("  RiscvCore SoC Testbench");
        $display("========================================");

        // --------------------------------------------------
        // STEP 1: Reset
        // --------------------------------------------------
        $display("\n[STEP 1] Applying reset...");
        PORESETn = 1'b0;
        repeat(10) @(posedge HCLK);
        @(negedge HCLK);
        PORESETn = 1'b1;
        repeat(5) @(posedge HCLK);
        $display("         PORESETn released, HRESETn=%b", HRESETn);

        // Wait for HRESETn from CRG
        begin : wait_reset
            int t;
            t = 0;
            while (!HRESETn && t < 100) begin
                @(posedge HCLK);
                t++;
            end
            if (!HRESETn) begin
                $display("FATAL: HRESETn never went high");
                $finish;
            end
            $display("         HRESETn high after %0d cycles", t);
        end

        // --------------------------------------------------
        // STEP 2: Load IMEM via backdoor
        // --------------------------------------------------
        $display("\n[STEP 2] Loading IMEM...");
        for (int i = 0; i < N_INST; i++) begin
            `IMEM[i*4+0] = inst[i][7:0];
            `IMEM[i*4+1] = inst[i][15:8];
            `IMEM[i*4+2] = inst[i][23:16];
            `IMEM[i*4+3] = inst[i][31:24];
            $display("         IMEM[0x%04X] = 0x%08X", i*4, inst[i]);
        end

        // --------------------------------------------------
        // STEP 3: Set CTRL = RUN
        // --------------------------------------------------
        $display("\n[STEP 3] Setting CTRL = RUN...");
        force `CTRL = 4'h4;
        @(posedge HCLK);
        release `CTRL;
        $display("         CTRL = 0x%X", `CTRL);

        // --------------------------------------------------
        // STEP 4: Run and print execution trace
        // --------------------------------------------------
        $display("\n[STEP 4] Execution trace:");
        $display("%5s | %s | %-14s | %-14s | %-14s | %-14s | %s",
                 "Cycle","Edge","PC","Instruction","DMEM[0]","DMEM[4]","stall");
        $display({75{"-"}});

        cycle        = 0;
        stable_count = 0;
        last_pc      = 32'hFFFF_FFFF;

        while (cycle < 500) begin

            // Rising edge
            @(posedge HCLK);
            print_state("^", cycle);

            // Falling edge
            @(negedge HCLK);
            print_state("v", cycle);

            // Halt detection
            if (`CPU_PC === last_pc)
                stable_count++;
            else begin
                stable_count = 0;
                last_pc = `CPU_PC;
            end

            if (stable_count >= 3) begin
                $display("\n[HALTED] PC stable at 0x%08X after %0d cycles",
                         `CPU_PC, cycle);
                break;
            end

            cycle++;
        end

        if (cycle >= 500)
            $display("\n[TIMEOUT] Max cycles reached");

        // --------------------------------------------------
        // STEP 5: Print final state
        // --------------------------------------------------
        $display("\n[STEP 5] Final register file:");
        for (int i = 0; i < 8; i++)
            $display("  x%02d = 0x%08X", i, `XREGS[i]);

        $display("\n[STEP 5] Final DMEM:");
        for (int i = 0; i < 4; i++)
            $display("  DMEM[%2d] = 0x%08X", i*4, read_dmem_word(i*4));

        // --------------------------------------------------
        // STEP 6: Check expected results
        // --------------------------------------------------
        $display("\n[STEP 6] Checking results...");
        check("x3 = 0 (countdown done)",   `XREGS[3], 32'h0000_0000);
        check("x4 = 1 (decrement value)",  `XREGS[4], 32'h0000_0001);
        check("x6 = 10 (addi x6,x0,10)",  `XREGS[6], 32'h0000_000A);
        check("DMEM[4] = 10 (sw x6,4)",   read_dmem_word(4), 32'h0000_000A);

        // --------------------------------------------------
        // Summary
        // --------------------------------------------------
        $display("\n========================================");
        $display("  %0d passed, %0d failed", pass_count, fail_count);
        $display("========================================");
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else                  $display("  SOME TESTS FAILED");

        $finish;
    end

    // -------------------------------------------------------
    // Watchdog
    // -------------------------------------------------------
    initial begin
        #100000;
        $display("FATAL: Watchdog expired");
        $finish;
    end

endmodule

`default_nettype wire

