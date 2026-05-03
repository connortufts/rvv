module RV32I (
    input  logic        FCLK,
    input  logic        SCLK,
    input  logic        HCLK,
    input  logic        DCLK,
    input  logic        PORESETn,
    input  logic        DBGRESETn,
    input  logic        HRESETn,
    input  logic        SWCLKTCK,
    input  logic        nTRST,

    // CPU implementation
    output rvDefs::mem_addr_t instructionAddr,
    input  rvDefs::instruction_t instruction,
    output rvDefs::word_t dmemview,
    input  rvDefs::mem_addr_t viewaddr

    // AHB-LITE MASTER PORT
    output logic [31:0] HADDR,        // AHB transaction address
    output logic [2:0]  HBURST,       // AHB burst: tied to single
    output logic        HMASTLOCK,    // AHB locked transfer (always zero)
    output logic [3:0]  HPROT,        // AHB protection: priv; data or inst
    output logic [2:0]  HSIZE,        // AHB size: byte, half-word or word
    output logic [1:0]  HTRANS,       // AHB transfer: non-sequential only
    output logic [31:0] HWDATA,       // AHB write-data
    output logic        HWRITE,       // AHB write control
    input  logic [31:0] HRDATA,       // AHB read-data
    input  logic        HREADY,       // AHB stall signal
    input  logic        HRESP,        // AHB error response
    output logic [3:0]  HMASTER
);

    // CPU Instance
    top u_RV32I (
        .sysclk(HCLK),
        .sysreset(HRESETn),
        .instruction(instruction),
        .dmemview(dmemview),
        .viewaddr(viewaddr)
    );

    // AHB Bus Master 

endmodule