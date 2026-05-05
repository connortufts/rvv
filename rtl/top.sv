module top
(
);

    logic HCLK;
    logic HRESETn;

    ahb_s_intf AHB_S[1](.HCLK, .HRESETn);

    AHB_MEM #(.ADDR_BITS(16)) mem (
        .BUS_CLK(HCLK),
        .BUS_RSTN(HRESETn),
        .S(AHB_S[0])
    );

    ahb_m_intf #(.DW(32), .AW(32)) AHB_M(
        .HCLK(HCLK),
        .HRESETn(HRESETn)
    );

    AHB_BUS #(.NSUBS(1), .DEFAULT_SUB(1), .DW(32), .AW(32),
        .S_ADDR_START ({
            32'h00000000
        }),
        .S_ADDR_END ({
            32'h0000FFFF
        })
    systemBus (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .M(AHB_M),
        .S(AHB_S)
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
        .clk TODO
        .resetN TODO
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
