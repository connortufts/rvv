// =============================================================================
//  top.sv
//
//  +----------------+       +-------------------+       +-----------+
//  |  riscv_ahb     |       |  ahb3lite_         |       | ahb3lite_ |
//  |  _master       |=AHB==>|  interconnect      |=AHB==>| memory    |
//  |  (RiscvCore    |       |  (1M / 1S)         |       | (data RAM)|
//  |   inside)      |       +-------------------+       +-----------+
//  |                |
//  |  rom_addr -----+-----> instruction_rom (direct, no bus)
//  |  rom_data <----+
//  +----------------+
//
//  Interconnect : RoaLogic/ahb3lite_interconnect
//  Package dep  : RoaLogic/ahb3lite_pkg
//
//  Address map:
//    ROM  : direct connection, no address decoding needed on bus
//    RAM  : base=32'h0000_0000, mask=32'hFFFF_0000  (64 KB)
// =============================================================================

`timescale 1ns/1ps

import rvDefs::*;

module top #(
    parameter HADDR_SIZE  = 32,
    parameter HDATA_SIZE  = 32,
    parameter [31:0] RAM_BASE   = 32'h0000_0000,
    parameter [31:0] RAM_MASK   = 32'hFFFF_0000,   // 64 KB window
    parameter        RAM_DEPTH  = 16384,            // 16 K x 32-bit words
    parameter        ROM_DEPTH  = 4096              // 4 K x 32-bit words
)(
    input  logic HCLK,
    input  logic HRESETn
);

    localparam MASTERS = 1;
    localparam SLAVES  = 1;

    // =========================================================================
    //  ROM <-> core wires (direct, off-bus)
    // =========================================================================
    mem_addr_t     rom_addr;
    instruction_t  rom_data;

    // =========================================================================
    //  AHB master-port wires  (riscv_ahb_master <-> interconnect)
    // =========================================================================
    logic [0:0]            mst_priority;
    logic                  mst_HSEL;
    logic [HADDR_SIZE-1:0] mst_HADDR;
    logic [HDATA_SIZE-1:0] mst_HWDATA;
    logic [HDATA_SIZE-1:0] mst_HRDATA;
    logic                  mst_HWRITE;
    logic [2:0]            mst_HSIZE;
    logic [2:0]            mst_HBURST;
    logic [3:0]            mst_HPROT;
    logic [1:0]            mst_HTRANS;
    logic                  mst_HMASTLOCK;
    logic                  mst_HREADYOUT;
    logic                  mst_HREADY;
    logic                  mst_HRESP;

    // =========================================================================
    //  AHB slave-port wires  (interconnect <-> data RAM)
    // =========================================================================
    logic [HADDR_SIZE-1:0] slv_addr_mask;
    logic [HADDR_SIZE-1:0] slv_addr_base;

    logic                  slv_HSEL;
    logic [HADDR_SIZE-1:0] slv_HADDR;
    logic [HDATA_SIZE-1:0] slv_HWDATA;
    logic [HDATA_SIZE-1:0] slv_HRDATA;
    logic                  slv_HWRITE;
    logic [2:0]            slv_HSIZE;
    logic [2:0]            slv_HBURST;
    logic [3:0]            slv_HPROT;
    logic [1:0]            slv_HTRANS;
    logic                  slv_HMASTLOCK;
    logic                  slv_HREADYOUT;
    logic                  slv_HREADY;
    logic                  slv_HRESP;

    // =========================================================================
    //  Static tie-offs
    // =========================================================================
    assign mst_priority  = 1'b0;
    assign mst_HSEL      = 1'b1;
    assign mst_HREADY    = mst_HREADYOUT;   // single-master loopback
    assign slv_addr_base = RAM_BASE;
    assign slv_addr_mask = RAM_MASK;

    // =========================================================================
    //  RISC-V AHB master wrapper (contains RiscvCore)
    // =========================================================================
    riscv_ahb_master #(
        .HADDR_SIZE ( HADDR_SIZE ),
        .HDATA_SIZE ( HDATA_SIZE )
    ) u_riscv (
        .HCLK      ( HCLK          ),
        .HRESETn   ( HRESETn       ),
        // AHB master port
        .HADDR     ( mst_HADDR     ),
        .HBURST    ( mst_HBURST    ),
        .HMASTLOCK ( mst_HMASTLOCK ),
        .HPROT     ( mst_HPROT     ),
        .HSIZE     ( mst_HSIZE     ),
        .HTRANS    ( mst_HTRANS    ),
        .HWDATA    ( mst_HWDATA    ),
        .HWRITE    ( mst_HWRITE    ),
        .HRDATA    ( mst_HRDATA    ),
        .HREADY    ( mst_HREADYOUT ),
        .HRESP     ( mst_HRESP     ),
        // Direct ROM port
        .rom_addr  ( rom_addr      ),
        .rom_data  ( rom_data      )
    );

    // =========================================================================
    //  Instruction ROM  (direct connection, no AHB)
    // =========================================================================
    /*instruction_rom #(
        .ROM_DEPTH ( ROM_DEPTH )
    ) u_rom (
        .clk  ( HCLK     ),
        .addr ( rom_addr  ),
        .data ( rom_data  )
    );*/
    logic instruction_t imem [0 : ROM_DEPTH - 1];
    assign rom_data = imem[rom_addr];

    /*
    initial begin
        $readmemb();
    end
    */

    // =========================================================================
    //  AHB3-Lite interconnect  (1 master, 1 slave)
    // =========================================================================
    ahb3lite_interconnect #(
        .HADDR_SIZE          ( HADDR_SIZE              ),
        .HDATA_SIZE          ( HDATA_SIZE              ),
        .MASTERS             ( MASTERS                 ),
        .SLAVES              ( SLAVES                  ),
        .SLAVE_MASK          ( '{1{ {1{1'b1}} }}       ),
        .ERROR_ON_SLAVE_MASK ( '{1{ {1{1'b0}} }}       ),
        .ERROR_ON_NO_SLAVE   ( '{1{ 1'b0 }}            )
    ) u_interconnect (
        .HRESETn        ( HRESETn          ),
        .HCLK           ( HCLK             ),
        .mst_priority   ( '{mst_priority}  ),
        .mst_HSEL       ( '{mst_HSEL}      ),
        .mst_HADDR      ( '{mst_HADDR}     ),
        .mst_HWDATA     ( '{mst_HWDATA}    ),
        .mst_HRDATA     ( '{mst_HRDATA}    ),
        .mst_HWRITE     ( '{mst_HWRITE}    ),
        .mst_HSIZE      ( '{mst_HSIZE}     ),
        .mst_HBURST     ( '{mst_HBURST}    ),
        .mst_HPROT      ( '{mst_HPROT}     ),
        .mst_HTRANS     ( '{mst_HTRANS}    ),
        .mst_HMASTLOCK  ( '{mst_HMASTLOCK} ),
        .mst_HREADYOUT  ( '{mst_HREADYOUT} ),
        .mst_HREADY     ( '{mst_HREADY}    ),
        .mst_HRESP      ( '{mst_HRESP}     ),
        .slv_addr_mask  ( '{slv_addr_mask} ),
        .slv_addr_base  ( '{slv_addr_base} ),
        .slv_HSEL       ( '{slv_HSEL}      ),
        .slv_HADDR      ( '{slv_HADDR}     ),
        .slv_HWDATA     ( '{slv_HWDATA}    ),
        .slv_HRDATA     ( '{slv_HRDATA}    ),
        .slv_HWRITE     ( '{slv_HWRITE}    ),
        .slv_HSIZE      ( '{slv_HSIZE}     ),
        .slv_HBURST     ( '{slv_HBURST}    ),
        .slv_HPROT      ( '{slv_HPROT}     ),
        .slv_HTRANS     ( '{slv_HTRANS}    ),
        .slv_HMASTLOCK  ( '{slv_HMASTLOCK} ),
        .slv_HREADYOUT  ( '{slv_HREADYOUT} ),
        .slv_HREADY     ( '{slv_HREADY}    ),
        .slv_HRESP      ( '{slv_HRESP}     )
    );

    // =========================================================================
    //  Data RAM  (AHB3-Lite slave)
    // =========================================================================
    ahb3lite_memory #(
        .HADDR_SIZE ( HADDR_SIZE ),
        .HDATA_SIZE ( HDATA_SIZE ),
        .MEM_DEPTH  ( RAM_DEPTH  )
    ) u_ram (
        .HRESETn   ( HRESETn       ),
        .HCLK      ( HCLK          ),
        .HSEL      ( slv_HSEL      ),
        .HADDR     ( slv_HADDR     ),
        .HWDATA    ( slv_HWDATA    ),
        .HWRITE    ( slv_HWRITE    ),
        .HSIZE     ( slv_HSIZE     ),
        .HBURST    ( slv_HBURST    ),
        .HPROT     ( slv_HPROT     ),
        .HTRANS    ( slv_HTRANS    ),
        .HMASTLOCK ( slv_HMASTLOCK ),
        .HREADY    ( slv_HREADY    ),
        .HRDATA    ( slv_HRDATA    ),
        .HREADYOUT ( slv_HREADYOUT ),
        .HRESP     ( slv_HRESP     )
    );

endmodule
