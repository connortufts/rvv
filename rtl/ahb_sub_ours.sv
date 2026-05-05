// ahb_sub.sv - AHB sub to reg_intf
// PNW 11 2015

`include "rtl_macros.svh"

module ahb_sub_ours
#(
parameter AW = 16,
parameter DW = 32
)
(
input logic             clk, rstn,
ahb_s_intf.source   S,
reg_intf.source         regs,
output logic [2:0] hsize
);

//---------------------------------------------------------
// AHB sub interface
//---------------------------------------------------------


// As per spec: HREADYOUT is driven high during reset.
// Doesn't handle htrans properly, except ignoring IDLE.
// Only supports single transfers (no burst support).
// Only supports full word (32bit) transactions.

// AHB inputs used to detect start of address phase
logic hsel;
logic hready;
logic [1:0] htrans;
always_comb hsel = S.HSEL;
always_comb hready = S.HREADY;
always_comb htrans = S.HTRANS[1:0];

// Detect start of address and data phases
logic a_phase;
logic d_phase;
logic htrans_nonidle;   // indicates not IDLE or BUSY
always_comb htrans_nonidle = (htrans == 2'b10) | (htrans == 2'b11);
always_comb a_phase = hsel & hready & htrans_nonidle;
`FF(a_phase,d_phase,clk,'1,rstn,'0);    // data phase starts after address phase
logic a_phase_1;                        // registered address phase available 1-cycle later
logic d_phase_1;                        // registered data phase available 1-cycle later
`FF(d_phase,d_phase_1,clk,'1,rstn,'0);
`FF(a_phase,a_phase_1,clk,'1,rstn,'0);

// AHB inputs registered during address phase
logic hwrite_reg;
logic [AW-1:0] haddr_reg;
logic [2:0] hsize_reg;
`FF(S.HWRITE,hwrite_reg,clk,a_phase,rstn,'0);
`FF(S.HADDR[AW-1:0],haddr_reg[AW-1:0],clk,a_phase,rstn,'0);
`FF(S.HSIZE,hsize_reg,clk,a_phase,rstn,'0);

// AHB data phase register
logic [31:0] hwdata_reg;
`FF(S.HWDATA,hwdata_reg,clk,d_phase,rstn,'0);

// Register AHB data phase outputs
logic hreadyout_o;
logic [31:0] hrdata_o;
logic [31:0] rdata_h, rdata_f;
logic hresp_o;
`FF(hreadyout_o,S.HREADYOUT,clk,'1,rstn,'1);  // reset value is high
`FF(hresp_o,S.HRESP,clk,'1,rstn,'0);
`FF(hrdata_o,S.HRDATA,clk,'1,rstn,'0);  // only changes on read
// ERROR response should take 2 cycles
always_comb hresp_o = 1'b0;
always_comb hrdata_o[31:0] = rdata_h[31:0];

// Mux correct hready response
// due to output register on hreadyout, need to lower hreadyout_o 1-cycle
// early.
// For HCLK transfer, ready after 1 wait state
logic sub_busy;
always_comb sub_busy = a_phase;
always_comb hreadyout_o = ~sub_busy;
// ERROR response : HREADY=1'b0 in 1st cycle, HREADY=1'b1 in 2nd cycle

//---------------------------------------------------------
// Transaction with the regs interface
//---------------------------------------------------------

logic h_wr_valid;
logic h_rd_valid;
always_comb h_wr_valid = d_phase_1;  // write after data phase has been registered
always_comb h_rd_valid = a_phase_1;  // read after address phase has been registered

always_comb begin
regs.write_en = h_wr_valid & hwrite_reg;
regs.read_en = h_rd_valid & (~hwrite_reg);
regs.addr = (h_wr_valid | h_rd_valid) ? haddr_reg[AW-1:0]  : '0;
regs.wdata = (h_wr_valid & hwrite_reg) ? hwdata_reg      : '0;
rdata_h = regs.rdata;
end


endmodule
