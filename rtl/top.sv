module top
(
    input  logic sysclk,
    input  logic sysreset
);

    rvDefs::mem_addr_t instructionAddress;
    rvDefs::instruction_t instructionWord;

    InstructionMemory #(.ADDR_BITS(10)) imem(
        .address(instructionAddress),
        .instruction(instructionWord)
    );

    rvDefs::word_t memoryReadData;
    rvDefs::word_t memoryWriteData;
    rvDefs::mem_addr_t memoryAddress;
    logic memRead;
    logic memWrite;
    logic [3 : 0] writeMask;
    logic coreStall;

    RiscvCore core(
        .clk(sysclk),
        .resetN
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
