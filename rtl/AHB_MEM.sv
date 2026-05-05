`default_nettype none
`include "rtl_macros.svh"

module AHB_MEM 
#(
    parameter ADDR_BITS = 16
)
(
    input logic BUS_CLK,
    input logic BUS_RSTN,
    ahb_s_intf.source S
);

reg_intf #(.DW(32),.AW(32)) pregs();

logic [2:0] hsize;

ahb_sub_ours #(.DW(32), .AW(32)) u_mem ( 
    .clk (BUS_CLK),
    .rstn (BUS_RSTN),
    .S (S),
    .regs (pregs),
    .hsize(hsize)
);

logic [31 : 0] dbgword;

MemoryModule #(.ADDR_BITS(ADDR_BITS)) mem (
    .address(pregs.addr[ADDR_BITS-1:0]),
    .writeData(pregs.wdata),
    .memWrite(pregs.write_en),
    .clk(BUS_CLK),
    .byteWriteEnable(hsize[1:0]),
    .readData(pregs.rdata),
    .debugword(dbgword)
);

endmodule

`default_nettype wire
