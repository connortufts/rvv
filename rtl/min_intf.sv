// min_intf.svh -
// PNW 10 2015

// A set of interfaces to use in RTL design.
// Naming convention is to use suffix _intf.
// Parameters do not have default values, which
// forces them to be declared at the point of use.


// TODO add example of using flattened struct to pass more complex payload

`include "rtl_macros.svh"

//---------------------------------------------------------
// register interface
//---------------------------------------------------------

// Simple register read/write
// read data returned on next clock edge

interface reg_intf #(parameter DW=0, AW=0);
logic read_en, write_en;
logic [AW-1:0] addr;
logic [DW-1:0] rdata, wdata;

modport source(output read_en, write_en, addr, wdata, input rdata);
modport sink(input read_en, write_en, addr, wdata, output rdata);

endinterface
