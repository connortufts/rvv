`default_nettype none
`include "rtl_macros.svh"

module AHB_CORE
(
    input logic BUS_CLK,
    input logic BUS_RSTN,
    ahb_m_intf.source M,
    logic coreclk
);

reg_intf #(.DW(32),.AW(32)) pregs();
logic [1 : 0] writeMask;

ahb_mgr #(.DW(32), .AW(32)) u_core ( 
    .clk (BUS_CLK),
    .rstn (BUS_RSTN),
    .M (M),
    .size({1'b0, writeMask}),
    .regs (pregs),
);

    rvDefs::mem_addr_t instructionAddress;
    rvDefs::instruction_t instructionWord;

    InstructionMemory #(.ADDR_BITS(10)) imem(
        .address(instructionAddress),
        .instruction(instructionWord)
    );

    RiscvCore core(
        .clk(coreclk),
        .resetN(BUS_RSTN),
        .instruction(instructionWord),
        .instructionAddress(instructionAddress),
        .memoryAddress(pregs.addr),
        .readData(pregs.rdata),
        .writeData(pregs.wdata),
        .memRead(pregs.read_en),
        .memWrite(pregs.write_en),
        .writeMask(writeMask),
        .stall(~M.HREADY)
    );

endmodule

`default_nettype wire
