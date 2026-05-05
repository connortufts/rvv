module top
(
    input  logic sysclk,
    input  logic sysreset
);

    rvDefs::mem_addr_t instructionAddress;
    rvDefs::instruction_t instructionWord;
    
    rvDefs::word_t memoryReadData;
    rvDefs::word_t memoryWriteData;
    rvDefs::mem_addr_t memoryAddress;
    logic memRead;
    logic memWrite;
    logic [3 : 0] writeMask;
    logic coreStall;

    InstructionMemory #(.ADDR_BITS(8)) imem(
        .address(instructionAddress[7 : 0]),
        .instruction(instructionWord)
    );

    MemoryModule #(.ADDR_BIS(16)) dmem(
        .address(memoryAddress[15 : 0]),
        .writeData(memoryWriteData),
        .readData(memoryReadData),
        .memWrite(memWrite),
        .byteWriteEnable(writeMask),
        .clk(sysclk)
    );

    RiscvCore core(
        .clk(sysclk),
        .resetN(sysclk),
        .instruction(instructionWord),
        .instructionAddress(instructionAddress),
        .memoryAddress(memoryAddress),
        .readData(memoryReadData),
        .writeData(memoryWriteData),
        .memRead(memRead),
        .memWrite(memWrite),
        .writeMask(writeMask),
        .stall(coreStall)
    );

endmodule
