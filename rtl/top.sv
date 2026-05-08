`timescale 1ns/1ps
module top
(
    input  logic CLK,
    input  logic RSTN,

    output rvDefs::mem_addr_t instructionAddress,
    input rvDefs::instruction_t instructionWord,

    input  logic stall
);

    rvDefs::mem_addr_t memoryAddress;
    rvDefs::word_t memoryReadData;
    rvDefs::word_t memoryWriteData;
    logic memRead;
    logic memWrite;
    logic [2 : 0] memSize;

    //InstructionMemory imem(
    //    .address(instructionAddress),
    //    .instruction(instructionWord)
    //);

    MemoryModule #(.ADDR_BITS(10)) dmem(
        .address(memoryAddress),
        .writeData(memoryWriteData),
        .memWrite(memWrite),
        .clk(CLK),
        .memSize(memSize),
        .readData(memoryReadData)
    );

    RiscvCore core(
        .clk(CLK),
        .resetN(RSTN),
        .instruction(instructionWord),
        .instructionAddress(instructionAddress),
        .memAddress(memoryAddress),
        .memReadData(memoryReadData),
        .memWriteData(memoryWriteData),
        .memRead(memRead),
        .memWrite(memWrite),
        .memSize(memSize),
        .stall(stall)
    );

endmodule
