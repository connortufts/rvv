module LSU_TB;

    // Inputs to LSU
    logic [1:0]  memoryOpSize;
    logic [31:0] RegtoMemData;
    logic        unsignedLoad;
    logic        storeLoad;
    logic [31:0] address;
    logic [7:0]  readData [4];

    // Outputs from LSU
    logic        memWrite;
    logic        memRead;
    logic [7:0]  writeData [4];
    logic [3:0]  byteWriteEnable;
    logic [31:0] MemtoRegData;
    logic [31:0] effectiveAddress;

    // Instantiate the Unit Under Test (UUT)
    LSU uut (.*);

    initial begin
        // --- Initialize Inputs ---
        memoryOpSize = 2'b11; // NONE
        RegtoMemData = 32'h0;
        unsignedLoad = 0;
        storeLoad    = 0;
        address      = 32'h0;
        for (int i = 0; i < 4; i++) readData[i] = 8'h0;

        $display("Starting LSU Testbench...");
        #10;

        // --- TEST 1: Store Word (sw) ---
        // Store 0xDEADBEEF at address 0x100
        $display("Test 1: Store Word (sw)");
        memoryOpSize = 2'b10; 
        storeLoad    = 1;
        address      = 32'h00000100;
        RegtoMemData = 32'hDEADBEEF;
        #10;
        assert(memWrite == 1 && byteWriteEnable == 4'b1111) else $error("SW byteWriteEnable Failed");
        assert(writeData[0] == 8'hEF && writeData[3] == 8'hDE) else $error("SW Data Failed");

        // --- TEST 2: Store Byte (sb) at Offset 1 ---
        // Store 0xAA at address 0x101
        $display("Test 2: Store Byte (sb) at offset 1");
        memoryOpSize = 2'b00;
        address      = 32'h00000101;
        RegtoMemData = 32'h000000AA;
        #10;
        assert(byteWriteEnable == 4'b0010) else $error("SB byteWriteEnable Failed");
        assert(writeData[1] == 8'hAA) else $error("SB Data Mapping Failed");

        // --- TEST 3: Load Byte Signed (lb) ---
        // Memory has 0xFF (negative) at offset 0
        $display("Test 3: Load Byte Signed (lb)");
        storeLoad    = 0;
        unsignedLoad = 0;
        memoryOpSize = 2'b00;
        address      = 32'h00000100;
        readData[0]  = 8'hFF; 
        #10;
        assert(MemtoRegData == 32'hFFFFFFFF) else $error("LB Sign Extension Failed: Got %h", MemtoRegData);

        // --- TEST 4: Load Byte Unsigned (lbu) ---
        $display("Test 4: Load Byte Unsigned (lbu)");
        unsignedLoad = 1;
        #10;
        assert(MemtoRegData == 32'h000000FF) else $error("LBU Zero Extension Failed");

        // --- TEST 5: Load Half-word Signed (lh) at Offset 2 ---
        // Memory has 0x8000 at bytes [3,2]
        $display("Test 5: Load Half-word Signed (lh)");
        unsignedLoad = 0;
        memoryOpSize = 2'b01;
        address      = 32'h00000102; // Offset = 2
        readData[2]  = 8'h00; 
        readData[3]  = 8'h80; // MSB is 1
        #10;
        assert(MemtoRegData == 32'hFFFF8000) else $error("LH Sign Extension Failed");

        // --- TEST 6: No-Op (Ensure memWrite/Read are low) ---
        $display("Test 6: No-Op Logic");
        memoryOpSize = 2'b11; // NONE
        #10;
        assert(memWrite == 0 && memRead == 0) else $error("Mem Control should be 0 for OpSize NONE");

        $display("All LSU tests passed successfully!");
        $finish;
    end

endmodule