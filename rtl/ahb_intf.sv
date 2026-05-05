// ahb_intf.sv - Manager and Subordinate interfaces to bundle AHB signals together
// PNW 10 2015

// NOTES:
// - Currently implements AHB-lite - no support for HPROT, HMASTLOCK or HBURST.
// - "sink" is the peripheral end, "source" is the bus matrix end


`include "rtl_macros.svh"

//---------------------------------------------------------
// AHB Subordinate
//---------------------------------------------------------


interface ahb_s_intf 
#(
  parameter DW=32, 
  parameter AW=32, 
  parameter STUB=0
)
(
  input logic HCLK,     // for assertions in interface
  input logic HRESETn
);


// Global signals

// Subordinate Select 
logic HSEL;   
// Address, Control & Write Data
logic HREADY;
logic [AW-1:0] HADDR;
logic [1:0] HTRANS;
//logic HPROT;
logic HWRITE;
logic [2:0] HSIZE;
logic [DW-1:0] HWDATA;
// Transfer Response & Read Data
logic HREADYOUT;
logic [DW-1:0] HRDATA;
logic HRESP;

// If this is a stub, tie off sub outputs
generate 
if (STUB == 1) 
  always_comb begin: stub_tie_off
    HREADYOUT = 1'b1;
    HRESP = 1'b0;
    HRDATA = 32'hDEAD_BEEF;
  end 
endgenerate



// source and sink are a little arbitrary.  Source is sub side, sink is bus matrix side
modport source (input  HSEL, HADDR, HTRANS, HWRITE, HSIZE, HWDATA, HREADY, output HREADYOUT, HRDATA, HRESP);
modport sink   (output HSEL, HADDR, HTRANS, HWRITE, HSIZE, HWDATA, HREADY, input  HREADYOUT, HRDATA, HRESP);



endinterface


//---------------------------------------------------------
// AHB manager
//---------------------------------------------------------


interface ahb_m_intf
#(
  parameter DW=32, 
  parameter AW=32, 
  parameter STUB=0
)
(
  input logic HCLK,     // for assertions in interface
  input logic HRESETn
);


// Global signals

// Address, Control & Write Data
logic HREADY;
logic [AW-1:0] HADDR;
logic [1:0] HTRANS;
//logic [2:0] HBURST;
//logic [3:0] HPROT;
//logic HMASTLOCK;
logic HWRITE;
logic [2:0] HSIZE;
logic [DW-1:0] HWDATA;
// Transfer Response & Read Data
logic [DW-1:0] HRDATA;
logic HRESP;


// If this is a stub, tie off sub outputs
generate 
if (STUB == 1) 
  always_comb begin
    HTRANS = 2'b00;
    HWRITE = 1'b0;
    HWDATA = {DW{1'b0}};
    HSIZE = 3'b000;
    HADDR = {AW{1'b0}};
  end 
endgenerate


// source and sink are a little arbitrary.  Source is sub side, sink is bus matrix side
modport source (input HREADY, HRESP, HRDATA, output HTRANS, HWRITE, HWDATA, HSIZE, HADDR);
modport sink   (output HREADY, HRESP, HRDATA, input HTRANS, HWRITE, HWDATA, HSIZE, HADDR);


endinterface


