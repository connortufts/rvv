`default_nettype none
`include "rtl_macros.svh"

module AHB_CORE
(
    input logic BUS_CLK,
    input logic BUS_RSTN,
    ahb_m_intf.source M
);

reg_intf #(.DW(32),.AW(32)) pregs();

ahb_mgr #(.DW(32), .AW(32)) u_core ( 
    .clk (BUS_CLK),
    .rstn (BUS_RSTN),
    .M (M),
    .regs (pregs),
);

    rvDefs::mem_addr_t instructionAddress;
    rvDefs::instruction_t instructionWord;

    InstructionMemory #(.ADDR_BITS(10)) imem(
        .address(instructionAddress),
        .instruction(instructionWord)
    );

    logic [1 : 0] writeMask;

    RiscvCore core(
        .clk TODO
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
