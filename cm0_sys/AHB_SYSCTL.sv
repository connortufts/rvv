//
//

module AHB_SYSCTL (
input  logic HCLK, 
output logic HRESETn,
ahb_s_intf.source S,

input logic PORESETn,

input  logic         SYSRESETREQ,
input  logic         WDOGRESETREQ,
input  logic         LOCKUPREQ,
output logic         PMUENABLE,
//output wire          SC_AHB_RSTN,       // AHB Reset Signal
output logic  [1:0]  SC_SRAM_RTSEL,       // SRAM Extra Margin Adjustment
output logic  [1:0]  SC_SRAM_WTSEL      // SRAM Extra Margin Adjustment for Writes
//output logic         SC_PAD_ST,         // PAD schmidt setting
//output logic  [3:0]  SC_PAD_DS,         // PAD drive strength
//output logic         SC_PAD_SL          // PAD slew rate control
);


logic SC_AHB_RSTN;
logic force_rst;
always_comb force_rst = PORESETn & (~SC_AHB_RSTN);

// use a sync flop to asynchronously assert and synchronously de-assert reset
//syncff rst_sync (.clock(HCLK),.reset_n(force_rst),.data_i(1'b1),.data_o(HRESETn));
always_comb HRESETn = force_rst;

sm2_sysctrl #(.BE (1'b0))
u_sm2_sysctrl
(
// AHB Inputs
 .HCLK             (HCLK),
 .HRESETn          (HRESETn),
 .FCLK             (HCLK),      // Free-running clock.  HCLK is not gated in this design.
 .PORESETn         (PORESETn),
 .HSEL             (S.HSEL),
 .HREADY           (S.HREADY),
 .HTRANS           (S.HTRANS[1:0]),
 .HSIZE            (S.HSIZE[2:0]),
 .HWRITE           (S.HWRITE),
 .HADDR            (S.HADDR[11:0]),
 .HWDATA           (S.HWDATA[31:0]),
// AHB Outputs
 .HREADYOUT        (S.HREADYOUT),
 .HRESP            (S.HRESP),
 .HRDATA           (S.HRDATA[31:0]),
// Reset information
 .SYSRESETREQ      (SYSRESETREQ),       // System Reset Request
 .WDOGRESETREQ     (WDOGRESETREQ),      // Watchdog Reset Request
 .LOCKUPREQ        (LOCKUPREQ),         // Lockup Reset Request
 // Engineering-change-order revision bits
 .ECOREVNUM        (4'h0),
// System control signals
 .REMAP            (),                  // Don't intend to do any remapping stuff.
 .PMUENABLE        (PMUENABLE),
 .SC_AHB_RSTN      (SC_AHB_RSTN),       // AHB Reset Signal
 .SC_SRAM_RTSEL      (SC_SRAM_RTSEL),       // SRAM Extra Margin Adjustment
 .SC_SRAM_WTSEL     (SC_SRAM_WTSEL)      // SRAM Extra Margin Adjustment for Writes
 //.SC_PAD_ST        (SC_PAD_ST),         // PAD schmidt setting
 //.SC_PAD_DS        (SC_PAD_DS),         // PAD drive strength
 //.SC_PAD_SL        (SC_PAD_SL)          // PAD slew rate control
);



endmodule

