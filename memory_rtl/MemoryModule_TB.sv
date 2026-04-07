module MemoryModule_TB;

    // Signal declarations
    logic        CLK;
    logic        MemWrite;
    logic        MemRead;
    logic [31:0] Address;
    logic [7:0]  WriteData [4]; // Matches the new unpacked array input
    logic [3:0]  BWE;           // Replaces StoreType
    logic [31:0] ReadData;
    logic        OOBRead;
    logic        OOBWrite;
    logic [127:0] debug_mem_contents_low;
    logic [127:0] debug_mem_contents_high;

    int errors = 0;

    // DUT instantiation
    MemoryModule dut(
        .Address(Address),
        .WriteData(WriteData),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .CLK(CLK),
        .BWE(BWE),
        .ReadData(ReadData),
        .OOBRead(OOBRead),
        .OOBWrite(OOBWrite),
        .debug_mem_contents_low(debug_mem_contents_low),
        .debug_mem_contents_high(debug_mem_contents_high)
    );

    // Clock: 10 ns period
    always begin
        CLK = 1'b0; #5;
        CLK = 1'b1; #5;
    end

    // --- Helper Tasks ---

    // Simplified Write Task using BWE
    task do_write(input [31:0] addr, input [31:0] data, input [3:0] bwe_val);
        @(negedge CLK);
        MemWrite = 1; MemRead = 0;
        Address  = addr;
        BWE      = bwe_val;
        // Pack the 32-bit data into the unpacked array
        WriteData[0] = data[7:0];
        WriteData[1] = data[15:8];
        WriteData[2] = data[23:16];
        WriteData[3] = data[31:24];
        @(posedge CLK); #1;
        MemWrite = 0; // De-assert after one cycle
    endtask

    // Simplified Read Task (No LoadType needed here)
    task do_read(input [31:0] addr);
        @(negedge CLK);
        MemWrite = 0; MemRead = 1;
        Address  = addr;
        @(posedge CLK); #1;
        // Since your memory is synchronous, data is valid here
    endtask

    initial begin
        // Reset signals
        MemWrite = 0; MemRead = 0; BWE = 4'b0000;
        Address = 0; 
        for(int i=0; i<4; i++) WriteData[i] = 8'h0;

        $display("\n--- Starting RV32I Memory Tests ---");

        // 1. Test Word Write (BWE = 1111)
        $display("Testing Word Write at 0x00...");
        do_write(32'h0, 32'hDEADBEEF, 4'b1111);
        do_read(32'h0);
        assert(ReadData == 32'hDEADBEEF) 
            else begin $error("FAIL: Word Write. Got %h", ReadData); errors++; end

        // 2. Test Byte Write (BWE = 0001) - Little Endian
        $display("Testing Byte Write at 0x04 (Byte 0)...");
        // Clear word 4 first
        do_write(32'h4, 32'h00000000, 4'b1111);
        // Write only the LSB
        do_write(32'h4, 32'h000000AA, 4'b0001); 
        do_read(32'h4);
        assert(ReadData == 32'h000000AA) 
            else begin $error("FAIL: Byte Write. Got %h", ReadData); errors++; end

        // 3. Test Half-word Write (BWE = 1100) - Upper Half
        $display("Testing Half-word Write at 0x04 (Upper Half)...");
        do_write(32'h4, 32'hBBBB0000, 4'b1100);
        do_read(32'h4);
        // Should be BBBBAA because AA was already there
        assert(ReadData == 32'hBBBBAAAA) 
            else begin $error("FAIL: Partial Write overlap. Got %h", ReadData); errors++; end

        // 4. Test Alignment Check (EffectiveAddress logic)
        $display("Testing Alignment: Reading 0x01 should return Word 0x00...");
        do_read(32'h1); // Unaligned address
        assert(ReadData == 32'hDEADBEEF) 
            else begin $error("FAIL: Alignment logic. Got %h", ReadData); errors++; end

        // 5. Out of Bounds (OOB) Testing
        $display("Testing OOB Write...");
        do_write(32'hFFFF, 32'h12345678, 4'b1111); // Way past 16KB
        assert(OOBWrite == 1'b1) 
            else begin $error("FAIL: OOBWrite not signaled"); errors++; end

        // Final Summary
        if (errors == 0) $display("\n*** TEST PASSED! Score: %0d errors ***", errors);
        else $display("\n*** TEST FAILED with %0d errors ***", errors);

        $finish;
    end
endmodule