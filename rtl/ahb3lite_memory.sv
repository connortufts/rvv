// =============================================================================
//  ahb3lite_memory.sv
//
//  AHB3-Lite single-port SRAM slave.
//  Compatible with RoaLogic/ahb3lite_interconnect slv_* port conventions.
//
//  - Single-cycle reads  (HREADYOUT asserted the cycle after address phase)
//  - Single-cycle writes (data written on HWDATA phase)
//  - Byte, halfword, and word access sizes supported via HSIZE
//  - Always responds OKAY (HRESP=0)
//  - Depth is in 32-bit words; byte-addressed via HADDR
// =============================================================================

`timescale 1ns/1ps

module ahb3lite_memory #(
    parameter HADDR_SIZE = 32,
    parameter HDATA_SIZE = 32,
    parameter MEM_DEPTH  = 16384    // number of 32-bit words (default 64 KB)
)(
    input  logic                   HRESETn,
    input  logic                   HCLK,

    // AHB3-Lite slave interface
    input  logic                   HSEL,
    input  logic [HADDR_SIZE-1:0]  HADDR,
    input  logic [HDATA_SIZE-1:0]  HWDATA,
    input  logic                   HWRITE,
    input  logic [2:0]             HSIZE,
    input  logic [2:0]             HBURST,
    input  logic [3:0]             HPROT,
    input  logic [1:0]             HTRANS,
    input  logic                   HMASTLOCK,
    input  logic                   HREADY,     // upstream ready

    output logic [HDATA_SIZE-1:0]  HRDATA,
    output logic                   HREADYOUT,
    output logic                   HRESP
);

    // =========================================================================
    //  HTRANS encoding
    // =========================================================================
    localparam HTRANS_IDLE   = 2'b00;
    localparam HTRANS_BUSY   = 2'b01;
    localparam HTRANS_NONSEQ = 2'b10;
    localparam HTRANS_SEQ    = 2'b11;

    // =========================================================================
    //  HSIZE encoding
    // =========================================================================
    localparam HSIZE_BYTE     = 3'b000;
    localparam HSIZE_HALFWORD = 3'b001;
    localparam HSIZE_WORD     = 3'b010;

    // =========================================================================
    //  Memory array
    //  Byte-addressable via write strobes; stored as 32-bit words internally.
    // =========================================================================
    localparam ADDR_BITS = $clog2(MEM_DEPTH);

    logic [7:0] mem [0 : MEM_DEPTH*4 - 1];

    // =========================================================================
    //  Address-phase capture registers
    //  Latch on every valid address phase so the data phase knows what to do.
    // =========================================================================
    logic                   sel_lat;
    logic [HADDR_SIZE-1:0]  addr_lat;
    logic                   write_lat;
    logic [2:0]             size_lat;

    wire  active = HSEL & HREADY & (HTRANS == HTRANS_NONSEQ | HTRANS == HTRANS_SEQ);

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            sel_lat   <= 1'b0;
            addr_lat  <= '0;
            write_lat <= 1'b0;
            size_lat  <= 3'b010;
        end else begin
            sel_lat   <= active;
            addr_lat  <= HADDR;
            write_lat <= HWRITE;
            size_lat  <= HSIZE;
        end
    end

    // =========================================================================
    //  Write byte-enable generation from HSIZE and HADDR[1:0]
    // =========================================================================
    logic [3:0] byte_en;

    always_comb begin
        byte_en = 4'b0000;
        case (size_lat)
            HSIZE_BYTE: begin
                case (addr_lat[1:0])
                    2'b00: byte_en = 4'b0001;
                    2'b01: byte_en = 4'b0010;
                    2'b10: byte_en = 4'b0100;
                    2'b11: byte_en = 4'b1000;
                endcase
            end
            HSIZE_HALFWORD: begin
                case (addr_lat[1])
                    1'b0: byte_en = 4'b0011;
                    1'b1: byte_en = 4'b1100;
                endcase
            end
            HSIZE_WORD: byte_en = 4'b1111;
            default:    byte_en = 4'b1111;
        endcase
    end

    // =========================================================================
    //  Write port
    //  Byte-lane writes using byte_en; word address = addr_lat[ADDR_BITS+1:2]
    // =========================================================================
    wire [ADDR_BITS-1:0] word_addr_w = addr_lat[ADDR_BITS+1:2];
    wire [ADDR_BITS+1:0] byte_base_w = {word_addr_w, 2'b00};

    always_ff @(posedge HCLK) begin
        if (sel_lat && write_lat) begin
            if (byte_en[0]) mem[byte_base_w + 0] <= HWDATA[ 7: 0];
            if (byte_en[1]) mem[byte_base_w + 1] <= HWDATA[15: 8];
            if (byte_en[2]) mem[byte_base_w + 2] <= HWDATA[23:16];
            if (byte_en[3]) mem[byte_base_w + 3] <= HWDATA[31:24];
        end
    end

    // =========================================================================
    //  Read port
    //  Synchronous read; word-aligned, full 32-bit word always read out.
    //  Byte/halfword extraction is done by the master using HSIZE/HADDR.
    // =========================================================================
    wire [ADDR_BITS-1:0] word_addr_r = HADDR[ADDR_BITS+1:2];
    wire [ADDR_BITS+1:0] byte_base_r = {word_addr_r, 2'b00};

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HRDATA <= '0;
        end else if (active && !HWRITE) begin
            HRDATA <= { mem[byte_base_r + 3],
                        mem[byte_base_r + 2],
                        mem[byte_base_r + 1],
                        mem[byte_base_r + 0] };
        end
    end

    // =========================================================================
    //  Handshake: single-cycle latency -> always ready
    //  HREADYOUT=1 every cycle; reads/writes complete in one clock.
    // =========================================================================
    assign HREADYOUT = 1'b1;

    // =========================================================================
    //  Response: always OKAY
    // =========================================================================
    assign HRESP = 1'b0;

    // =========================================================================
    //  Simulation initialisation (zero out memory at reset)
    // =========================================================================
    // synthesis translate_off
    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH * 4; i++)
            mem[i] = 8'h00;
    end
    // synthesis translate_on

endmodule
// =============================================================================
//  EOF
// =============================================================================
