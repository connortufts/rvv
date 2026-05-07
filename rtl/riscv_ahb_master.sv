`timescale 1ns/1ps

import rvDefs::*;

module riscv_ahb_master #(
    parameter HADDR_SIZE = 32,
    parameter HDATA_SIZE = 32
)(
    input  logic                   HCLK,
    input  logic                   HRESETn,

    // AHB master
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

    // ROM
    output mem_addr_t              rom_addr,
    input  instruction_t           rom_data
);

    // ============================================================
    // HTRANS
    // ============================================================
    localparam logic [1:0] HTRANS_IDLE   = 2'b00;
    localparam logic [1:0] HTRANS_NONSEQ = 2'b10;

    // ============================================================
    // Core interface
    // ============================================================
    instruction_t  instruction;
    mem_addr_t     instructionAddress;
    mem_addr_t     memAddress;
    word_t         memReadData;
    word_t         memWriteData;
    logic          memRead;
    logic          memWrite;
    logic [2:0]    memSize;
    logic          stall;

    RiscvCore u_core (
        .clk(HCLK),
        .resetN(HRESETn),
        .instruction(instruction),
        .instructionAddress(instructionAddress),
        .memAddress(memAddress),
        .memReadData(memReadData),
        .memWriteData(memWriteData),
        .memRead(memRead),
        .memWrite(memWrite),
        .memSize(memSize),
        .stall(stall)
    );

    assign rom_addr   = instructionAddress;
    assign instruction = rom_data;

    // ============================================================
    // FSM
    // ============================================================
    typedef enum logic [1:0] {
        S_IDLE,
        S_ADDR,
        S_DATA
    } state_t;

    state_t state;

    // ============================================================
    // LATCHED REQUEST (FIXED PART)
    // ============================================================
    logic [HADDR_SIZE-1:0] addr_req;
    logic [2:0]            size_req;
    logic                  write_req;
    logic [HDATA_SIZE-1:0] wdata_req;

    logic                  req_valid;

    wire data_req = memRead | memWrite;

    // ============================================================
    // Sequential
    // ============================================================
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            state     <= S_IDLE;
            addr_req  <= '0;
            size_req  <= 3'b010;
            write_req <= 1'b0;
            wdata_req <= '0;
            req_valid <= 1'b0;
        end else begin
            case (state)

                S_IDLE: begin
                    if (data_req) begin
                        // Latch request ONCE
                        addr_req  <= {{(HADDR_SIZE-$bits(mem_addr_t)){1'b0}}, memAddress};
                        size_req  <= memSize;
                        write_req <= memWrite;
                        wdata_req <= {{(HDATA_SIZE-$bits(word_t)){1'b0}}, memWriteData};
                        req_valid <= 1'b1;
                        state     <= S_ADDR;
                    end
                end

                S_ADDR: begin
                    if (HREADY) begin
                        state <= S_DATA;
                    end
                end

                S_DATA: begin
                    if (HREADY) begin
                        req_valid <= 1'b0;

                        if (data_req) begin
                            // next request
                            addr_req  <= {{(HADDR_SIZE-$bits(mem_addr_t)){1'b0}}, memAddress};
                            size_req  <= memSize;
                            write_req <= memWrite;
                            wdata_req <= {{(HDATA_SIZE-$bits(word_t)){1'b0}}, memWriteData};
                            req_valid <= 1'b1;
                            state     <= S_ADDR;
                        end else begin
                            state <= S_IDLE;
                        end
                    end
                end

            endcase
        end
    end

    // ============================================================
    // AHB outputs (FIXED: only use latched signals)
    // ============================================================
    always_comb begin
        HADDR     = addr_req;
        HSIZE     = size_req;
        HWRITE    = write_req;
        HWDATA    = wdata_req;

        HBURST    = 3'b000;
        HMASTLOCK = 1'b0;
        HPROT     = 4'b0011;

        case (state)
            S_IDLE:  HTRANS = HTRANS_IDLE;
            S_ADDR:  HTRANS = HTRANS_NONSEQ;
            S_DATA: begin
                if (HREADY && req_valid)
                    HTRANS = HTRANS_NONSEQ; // pipeline next
                else
                    HTRANS = HTRANS_IDLE;
            end
            default: HTRANS = HTRANS_IDLE;
        endcase
    end

    // ============================================================
    // Read capture
    // ============================================================
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            memReadData <= '0;
        else if (state == S_DATA && HREADY && !write_req)
            memReadData <= HRDATA[$bits(word_t)-1:0];
    end

    // ============================================================
    // Stall core
    // ============================================================
    assign stall =
        (state == S_ADDR) ||
        (state == S_DATA && !HREADY);

endmodule