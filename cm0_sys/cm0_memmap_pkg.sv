// cm0_memmap_pkg.sv - Memory map for CM0 AHB bus
// PNW 12 2015
// PNW 03 2017

// See CMSDK designstart documentation for APB memmory map

package cm0_memmap_pkg;

// _START is first valid address (inclusive), 
// _END address is inclusive!
// UNUSED regions should have start and end set to zero

localparam logic [31:0] S0_ADDR_START    = 32'h0000_0000;  // SRAM program mem
localparam logic [31:0] S0_ADDR_END      = 32'h0000_FFFF;     // 64KB 
localparam logic [31:0] S1_ADDR_START    = 32'h2000_0000;  // SRAM data mem
localparam logic [31:0] S1_ADDR_END      = 32'h2000_FFFF;     // 64 KB 
localparam logic [31:0] S2_ADDR_START    = 32'h4000_0000;  // APB subsystem peripherals
localparam logic [31:0] S2_ADDR_END      = 32'h4000_FFFF;     // 64KB
localparam logic [31:0] S3_ADDR_START    = 32'h4001_0000;  // GPIO0
localparam logic [31:0] S3_ADDR_END      = 32'h4001_0FFF;     // 32KB
localparam logic [31:0] S4_ADDR_START    = 32'h4001_1000;  // GPIO1
localparam logic [31:0] S4_ADDR_END      = 32'h4001_1FFF;     // 32KB 
localparam logic [31:0] S5_ADDR_START    = 32'h4001_F000;  // SYSCTL
localparam logic [31:0] S5_ADDR_END      = 32'h4001_FFFF;     // 32KB 
localparam logic [31:0] S6_ADDR_START    = 32'h5000_0000;  // CRG
localparam logic [31:0] S6_ADDR_END      = 32'h5000_FFFF;     // 64KB
localparam logic [31:0] S7_ADDR_START    = 32'h6000_0000;  // ACCEL
localparam logic [31:0] S7_ADDR_END      = 32'h6000_FFFF;     // 64KB


// AHB timeout for assertions
localparam integer CKT_AHB_SUB_TIMEOUT = 999;

endpackage
