module MemoryModule_TB;

    // Signal declarations
    logic        clk;
    logic        memWrite;
    logic        memRead;
    logic [31:0] address;
    logic [7:0]  writeData [4]; // Matches the new unpacked array input
    logic [3:0]  byteWriteEnable;           // Replaces StoreType
    logic [7:0] readData [4];
    logic        OOBRead;
    logic        OOBWrite;
    logic [127:0] debug_mem_contents_low;
    logic [127:0] debug_mem_contents_high;
    logic [31:0] readDataResult;

    int errors = 0;

    // DUT instantiation
    MemoryModule dut(
        .address(address),
        .writeData(writeData),
        .memWrite(memWrite),
        .memRead(memRead),
        .clk(clk),
        .byteWriteEnable(byteWriteEnable),
        .readData(readData),
        .OOBRead(OOBRead),
        .OOBWrite(OOBWrite),
        .debug_mem_contents_low(debug_mem_contents_low),
        .debug_mem_contents_high(debug_mem_contents_high)
    );

    assign readDataResult[31:24] = readData[3];
    assign readDataResult[23:16] = readData[2];
    assign readDataResult[15:8]  = readData[1];
    assign readDataResult[7:0]   = readData[0];

    // Clock: 10 ns period
    always begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end

    // --- Helper Tasks ---

    // Simplified Write Task using byteWriteEnable
    task do_write(input [31:0] addr, input [31:0] data, input [3:0] byteWriteEnable_val);
        @(negedge clk);
        memWrite = 1; memRead = 0;
        address  = addr;
        byteWriteEnable      = byteWriteEnable_val;
        // Pack the 32-bit data into the unpacked array
        writeData[0] = data[7:0];
        writeData[1] = data[15:8];
        writeData[2] = data[23:16];
        writeData[3] = data[31:24];
        @(posedge clk); #1;
        memWrite = 0; // De-assert after one cycle
    endtask

    // Simplified Read Task (No LoadType needed here)
    task do_read(input [31:0] addr);
        @(negedge clk);
        memWrite = 0; memRead = 1;
        address  = addr;
        @(posedge clk); #1;
        // Since your memory is synchronous, data is valid here
    endtask

    initial begin
        // Reset signals
        memWrite = 0; memRead = 0; byteWriteEnable = 4'b0000;
        address = 0; 
        for(int i=0; i<4; i++) writeData[i] = 8'h0;

        $display("\n--- Starting RV32I Memory Tests ---");

        // 1. Test Word Write (byteWriteEnable = 1111)
        $display("Testing Word Write at 0x00...");
        do_write(32'h0, 32'hDEADBEEF, 4'b1111);
        do_read(32'h0);
        assert(readDataResult == 32'hDEADBEEF) 
            else begin $error("FAIL: Word Write. Got %h", readDataResult); errors++; end

        // 2. Test Byte Write (byteWriteEnable = 0001) - Little Endian
        $display("Testing Byte Write at 0x04 (Byte 0)...");
        // Clear word 4 first
        do_write(32'h4, 32'h00000000, 4'b1111);
        // Write only the LSB
        do_write(32'h4, 32'h000000AA, 4'b0001); 
        do_read(32'h4);
        assert(readDataResult == 32'h000000AA) 
            else begin $error("FAIL: Byte Write. Got %h", readDataResult); errors++; end

        // 3. Test Half-word Write (byteWriteEnable = 1100) - Upper Half
        $display("Testing Half-word Write at 0x04 (Upper Half)...");
        do_write(32'h4, 32'hBBBB0000, 4'b1100);
        do_read(32'h4);
        // Should be BBBBAA because AA was already there
        assert(readDataResult == 32'hBBBBAAAA) 
            else begin $error("FAIL: Partial Write overlap. Got %h", readDataResult); errors++; end

        // 4. Test Alignment Check (Effectiveaddress logic)
        $display("Testing Alignment: Reading 0x01 should return Word 0x00...");
        do_read(32'h1); // Unaligned address
        assert(readDataResult == 32'hDEADBEEF) 
            else begin $error("FAIL: Alignment logic. Got %h", readDataResult); errors++; end

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