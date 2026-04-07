module LSU_TB;

    // Inputs to LSU
    logic [2:0]  memoryOpSize;
    logic [31:0] RegtoMemData;
    logic        unsignedLoad;
    logic        storeLoad;
    logic [31:0] Address;
    logic [7:0]  ReadData [4];

    // Outputs from LSU
    logic        MemWrite;
    logic        MemRead;
    logic [7:0]  WriteData [4];
    logic [3:0]  BWE;
    logic [31:0] MemtoRegData;
    logic [31:0] EffectiveAddress;

    // Instantiate the Unit Under Test (UUT)
    LSU uut (.*);

    initial begin
        // --- Initialize Inputs ---
        memoryOpSize = 3'b011; // NONE
        RegtoMemData = 32'h0;
        unsignedLoad = 0;
        storeLoad    = 0;
        Address      = 32'h0;
        for (int i = 0; i < 4; i++) ReadData[i] = 8'h0;

        $display("Starting LSU Testbench...");
        #10;

        // --- TEST 1: Store Word (sw) ---
        // Store 0xDEADBEEF at Address 0x100
        $display("Test 1: Store Word (sw)");
        memoryOpSize = 3'b010; 
        storeLoad    = 1;
        Address      = 32'h00000100;
        RegtoMemData = 32'hDEADBEEF;
        #10;
        assert(MemWrite == 1 && BWE == 4'b1111) else $error("SW BWE Failed");
        assert(WriteData[0] == 8'hEF && WriteData[3] == 8'hDE) else $error("SW Data Failed");

        // --- TEST 2: Store Byte (sb) at Offset 1 ---
        // Store 0xAA at Address 0x101
        $display("Test 2: Store Byte (sb) at offset 1");
        memoryOpSize = 3'b000;
        Address      = 32'h00000101;
        RegtoMemData = 32'h000000AA;
        #10;
        assert(BWE == 4'b0010) else $error("SB BWE Failed");
        assert(WriteData[1] == 8'hAA) else $error("SB Data Mapping Failed");

        // --- TEST 3: Load Byte Signed (lb) ---
        // Memory has 0xFF (negative) at offset 0
        $display("Test 3: Load Byte Signed (lb)");
        storeLoad    = 0;
        unsignedLoad = 0;
        memoryOpSize = 3'b000;
        Address      = 32'h00000100;
        ReadData[0]  = 8'hFF; 
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
        memoryOpSize = 3'b001;
        Address      = 32'h00000102; // Offset = 2
        ReadData[2]  = 8'h00; 
        ReadData[3]  = 8'h80; // MSB is 1
        #10;
        assert(MemtoRegData == 32'hFFFF8000) else $error("LH Sign Extension Failed");

        // --- TEST 6: No-Op (Ensure MemWrite/Read are low) ---
        $display("Test 6: No-Op Logic");
        memoryOpSize = 3'b011; // NONE
        #10;
        assert(MemWrite == 0 && MemRead == 0) else $error("Mem Control should be 0 for OpSize NONE");

        $display("All LSU tests passed successfully!");
        $finish;
    end

endmodule