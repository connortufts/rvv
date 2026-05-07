// =============================================================================
//  riscv_ahb_master.sv
//
//  Wraps RiscvCore and translates its DATA memory interface into an
//  AHB3-Lite master port.
//
//  Instruction memory is a directly-connected ROM (off the AHB bus).
//  Only memRead / memWrite / memAddress / memSize / memWriteData / memReadData
//  go through the AHB master interface.
//
//  AHB3-Lite transfer flow (single-beat, no bursts):
//
//    Cycle 0 : HTRANS=NONSEQ, HADDR, HSIZE, HWRITE driven
//              Core is stalled
//    Cycle 1+: Wait while HREADY=0 (slave not ready)
//    Cycle N : HREADY=1 -> address phase accepted
//              For reads : HRDATA valid this cycle -> capture, un-stall core
//              For writes: HWDATA driven this cycle, un-stall core
//
// =============================================================================

`timescale 1ns/1ps

import rvDefs::*;

module riscv_ahb_master #(
    parameter HADDR_SIZE = 32,
    parameter HDATA_SIZE = 32
)(
    // -------------------------------------------------------------------------
    //  AHB3-Lite master port
    // -------------------------------------------------------------------------
    input  logic                   HCLK,
    input  logic                   HRESETn,

    output logic [HADDR_SIZE-1:0]  HADDR,
    output logic [2:0]             HBURST,
    output logic                   HMASTLOCK,
    output logic [3:0]             HPROT,
    output logic [2:0]             HSIZE,
    output logic [1:0]             HTRANS,
    output logic [HDATA_SIZE-1:0]  HWDATA,
    output logic                   HWRITE,

    input  logic [HDATA_SIZE-1:0]  HRDATA,
    input  logic                   HREADY,
    input  logic                   HRESP,

    // -------------------------------------------------------------------------
    //  Direct ROM port (instruction fetch, not on AHB bus)
    // -------------------------------------------------------------------------
    output mem_addr_t              rom_addr,    // to ROM address input
    input  instruction_t           rom_data     // from ROM data output
);

    // =========================================================================
    //  AHB HTRANS encoding
    // =========================================================================
    localparam logic [1:0] HTRANS_IDLE   = 2'b00;
    localparam logic [1:0] HTRANS_NONSEQ = 2'b10;

    // =========================================================================
    //  Internal core wires
    // =========================================================================
    instruction_t  instruction;
    mem_addr_t     instructionAddress;
    mem_addr_t     memAddress;
    word_t         memReadData;
    word_t         memWriteData;
    logic          memRead;
    logic          memWrite;
    logic [2:0]    memSize;
    logic          stall;

    // =========================================================================
    //  RiscvCore
    // =========================================================================
    RiscvCore u_core (
        .clk               ( HCLK             ),
        .resetN            ( HRESETn          ),
        .instruction       ( instruction      ),
        .instructionAddress( instructionAddress),
        .memAddress        ( memAddress       ),
        .memReadData       ( memReadData      ),
        .memWriteData      ( memWriteData     ),
        .memRead           ( memRead          ),
        .memWrite          ( memWrite         ),
        .memSize           ( memSize          ),
        .stall             ( stall            )
    );

    // =========================================================================
    //  ROM connection (direct, no bus)
    // =========================================================================
    assign rom_addr   = instructionAddress;
    assign instruction = rom_data;

    // =========================================================================
    //  AHB master FSM
    //
    //  IDLE : no data access pending - bus idles
    //  ADDR : address phase on bus, core stalled
    //  DATA : data phase, HWDATA driven (writes) or HRDATA captured (reads)
    //         core un-stalls when HREADY=1 in this state
    // =========================================================================
    typedef enum logic [1:0] {
        S_IDLE = 2'b00,
        S_ADDR = 2'b01,
        S_DATA = 2'b10
    } state_t;

    state_t state;

    // Latch address-phase info so it survives into the data phase
    logic [HADDR_SIZE-1:0] haddr_lat;
    logic [2:0]            hsize_lat;
    logic                  hwrite_lat;

    // data_req: core wants a data transfer this cycle
    wire data_req = memRead | memWrite;

    // -------------------------------------------------------------------------
    //  FSM sequential
    // -------------------------------------------------------------------------
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            state      <= S_IDLE;
            haddr_lat  <= '0;
            hsize_lat  <= 3'b010;
            hwrite_lat <= 1'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    if (data_req)
                        state <= S_ADDR;
                end

                S_ADDR: begin
                    if (HREADY) begin
                        // Address accepted - latch and move to data phase
                        haddr_lat  <= HADDR;
                        hsize_lat  <= HSIZE;
                        hwrite_lat <= HWRITE;
                        state      <= S_DATA;
                    end
                end

                S_DATA: begin
                    if (HREADY) begin
                        // Transfer complete
                        if (data_req)
                            state <= S_ADDR;   // back-to-back transfer
                        else
                            state <= S_IDLE;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    // -------------------------------------------------------------------------
    //  AHB output drive
    // -------------------------------------------------------------------------
    always_comb begin
        // Safe defaults
        HADDR     = '0;
        HSIZE     = 3'b010;     // word
        HWRITE    = 1'b0;
        HTRANS    = HTRANS_IDLE;
        HWDATA    = '0;
        HBURST    = 3'b000;     // SINGLE burst
        HMASTLOCK = 1'b0;
        HPROT     = 4'b0011;    // data access, privileged, non-cacheable, non-bufferable

        case (state)
            S_IDLE: begin
                if (data_req) begin
                    HADDR  = {{(HADDR_SIZE-$bits(mem_addr_t)){1'b0}}, memAddress};
                    HSIZE  = memSize;
                    HWRITE = memWrite;
                    HTRANS = HTRANS_NONSEQ;
                end
                // else bus stays IDLE
            end

            S_ADDR: begin
                // Hold address phase until slave accepts (HREADY=1)
                HADDR  = {{(HADDR_SIZE-$bits(mem_addr_t)){1'b0}}, memAddress};
                HSIZE  = memSize;
                HWRITE = memWrite;
                HTRANS = HTRANS_NONSEQ;
            end

            S_DATA: begin
                // Drive write data during data phase
                if (hwrite_lat)
                    HWDATA = {{(HDATA_SIZE-$bits(word_t)){1'b0}}, memWriteData};

                if (HREADY && data_req) begin
                    // Pipeline next address while current data phase ends
                    HADDR  = {{(HADDR_SIZE-$bits(mem_addr_t)){1'b0}}, memAddress};
                    HSIZE  = memSize;
                    HWRITE = memWrite;
                    HTRANS = HTRANS_NONSEQ;
                end else begin
                    HTRANS = HTRANS_IDLE;
                end
            end

            default: ;
        endcase
    end

    // -------------------------------------------------------------------------
    //  Capture read data when data phase completes
    // -------------------------------------------------------------------------
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            memReadData <= '0;
        else if (state == S_DATA && HREADY && !hwrite_lat)
            memReadData <= HRDATA[$bits(word_t)-1:0];
    end

    // -------------------------------------------------------------------------
    //  Stall core whenever a data transfer is in-flight
    //  (un-stall the cycle HREADY=1 in S_DATA so core sees data immediately)
    // -------------------------------------------------------------------------
    assign stall = (state == S_ADDR) |
                   (state == S_DATA && !HREADY);

endmodule
