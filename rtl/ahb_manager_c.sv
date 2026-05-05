// ahb_mgr.sv - AHB Manager (Master) to reg_intf
// Companion to ahb_sub.sv
// Implements AHB-lite manager side: initiates transfers, handles
// wait states (HREADY), and presents a simple reg_intf to the user logic.
//
// NOTES:
//  - Only supports single (non-burst) transfers.
//  - Supports byte (HSIZE=3'b000), halfword (HSIZE=3'b001), and
//    word (HSIZE=3'b010) transfers with full AHB byte-lane steering.
//  - Write data is replicated and placed on the correct byte lanes per
//    the AHB-lite spec (HADDR[1:0] selects the active lane).
//  - Read data is extracted from the correct byte lane and zero-extended.
//  - Does not drive HPROT, HMASTLOCK, or HBURST (AHB-lite).
//  - HTRANS is NONSEQ (2'b10) for valid transfers, IDLE (2'b00) otherwise.
//  - A new transfer cannot be issued until the current one completes
//    (HREADY = 1 during the data phase).

`include "rtl_macros.svh"

module ahb_mgr
#(
    parameter AW = 16,
    parameter DW = 32
)
(
    input  logic        clk,
    input  logic        rstn,
    ahb_m_intf.source   M,      // AHB manager port (drives bus)
    logic [2:0] size,
    reg_intf.sink       regs    // Register interface from user logic
);

// -----------------------------------------------------------------------
// Internal state
// -----------------------------------------------------------------------
typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ADDR    = 2'b01,   // address phase on bus
    DATA    = 2'b10    // data  phase on bus (waiting for HREADY)
} state_t;

state_t state, next_state;

// -----------------------------------------------------------------------
// Capture incoming request from reg_intf
// -----------------------------------------------------------------------
// Transfer size encoding (matches AHB HSIZE):
//   SIZE_BYTE     = 3'b000  -> 8-bit
//   SIZE_HALFWORD = 3'b001  -> 16-bit
//   SIZE_WORD     = 3'b010  -> 32-bit
localparam logic [2:0] SIZE_BYTE     = 3'b000;
localparam logic [2:0] SIZE_HALFWORD = 3'b001;
localparam logic [2:0] SIZE_WORD     = 3'b010;

logic req_valid;
logic req_write;

always_comb req_valid = regs.write_en | regs.read_en;
always_comb req_write = regs.write_en;

// Latch request at the start of the address phase so signals are stable
// through the data phase even if the caller de-asserts early.
logic          lat_write;
logic [AW-1:0] lat_addr;
logic [DW-1:0] lat_wdata;
logic [2:0]    lat_size;   // latched HSIZE for current transfer

`FF(req_write,           lat_write,          clk, (state == IDLE && req_valid), rstn, '0);
`FF(regs.addr[AW-1:0],  lat_addr[AW-1:0],   clk, (state == IDLE && req_valid), rstn, '0);
`FF(regs.wdata[DW-1:0], lat_wdata[DW-1:0],  clk, (state == IDLE && req_valid), rstn, '0);
`FF(regs.size,           lat_size,           clk, (state == IDLE && req_valid), rstn, SIZE_WORD);

// -----------------------------------------------------------------------
// FSM – next state
// -----------------------------------------------------------------------
always_comb begin
    next_state = state;
    case (state)
        IDLE: begin
            if (req_valid)
                next_state = ADDR;
        end
        ADDR: begin
            // Address phase always takes exactly one cycle;
            // move to data phase unconditionally.
            next_state = DATA;
        end
        DATA: begin
            // Stay in DATA until the subordinate asserts HREADY.
            if (M.HREADY)
                next_state = req_valid ? ADDR : IDLE;
        end
        default: next_state = IDLE;
    endcase
end

// FSM – state register
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        state <= IDLE;
    else
        state <= next_state;
end

// -----------------------------------------------------------------------
// AHB output drive
// -----------------------------------------------------------------------

// ---- Helper: replicate narrow write data across all active byte lanes ----
// AHB-lite spec: the manager must place write data on every active byte lane.
// For a byte write to lane N, HWDATA[8N+7:8N] must hold the data.
// Replicating the LSB across all lanes is the standard approach.
function automatic logic [DW-1:0] steer_wdata(
    input logic [DW-1:0] data,
    input logic [1:0]    byte_addr,   // HADDR[1:0]
    input logic [2:0]    size
);
    logic [DW-1:0] steered;
    steered = '0;
    case (size)
        SIZE_BYTE: begin
            // Replicate byte to all lanes; subordinate uses HADDR[1:0] to pick
            steered = {4{data[7:0]}};
        end
        SIZE_HALFWORD: begin
            // Replicate halfword to both lanes; HADDR[1] selects upper/lower
            steered = {2{data[15:0]}};
        end
        default: begin  // SIZE_WORD (and any unsupported size)
            steered = data;
        end
    endcase
    return steered;
endfunction

// ---- Helper: extract read data from the correct byte lane ----
function automatic logic [DW-1:0] extract_rdata(
    input logic [DW-1:0] bus_data,
    input logic [1:0]    byte_addr,
    input logic [2:0]    size
);
    logic [DW-1:0] extracted;
    extracted = '0;
    case (size)
        SIZE_BYTE: begin
            case (byte_addr)
                2'b00: extracted = {{24{1'b0}}, bus_data[7:0]};
                2'b01: extracted = {{24{1'b0}}, bus_data[15:8]};
                2'b10: extracted = {{24{1'b0}}, bus_data[23:16]};
                2'b11: extracted = {{24{1'b0}}, bus_data[31:24]};
            endcase
        end
        SIZE_HALFWORD: begin
            case (byte_addr[1])
                1'b0:  extracted = {{16{1'b0}}, bus_data[15:0]};
                1'b1:  extracted = {{16{1'b0}}, bus_data[31:16]};
            endcase
        end
        default: begin  // SIZE_WORD
            extracted = bus_data;
        end
    endcase
    return extracted;
endfunction

// Address / control phase outputs
always_comb begin
    // Defaults
    M.HTRANS = 2'b00;   // IDLE
    M.HADDR  = '0;
    M.HWRITE = 1'b0;
    M.HSIZE  = SIZE_WORD;

    case (state)
        IDLE: begin
            if (req_valid) begin
                // Pre-drive address on the same cycle we move to ADDR
                // so the subordinate sees it immediately.
                M.HTRANS = 2'b10;           // NONSEQ
                M.HADDR  = {{(32-AW){1'b0}}, regs.addr[AW-1:0]};
                M.HWRITE = req_write;
                M.HSIZE  = size;
            end
        end
        ADDR: begin
            M.HTRANS = 2'b10;               // NONSEQ
            M.HADDR  = {{(32-AW){1'b0}}, lat_addr[AW-1:0]};
            M.HWRITE = lat_write;
            M.HSIZE  = lat_size;
        end
        DATA: begin
            if (M.HREADY && req_valid) begin
                // Pipeline: start next address phase while data completes
                M.HTRANS = 2'b10;
                M.HADDR  = {{(32-AW){1'b0}}, regs.addr[AW-1:0]};
                M.HWRITE = req_write;
                M.HSIZE  = size;
            end
        end
        default: ;
    endcase
end

// Write data phase output – byte-lane steered per AHB-lite spec
always_comb begin
    M.HWDATA = '0;
    if (state == DATA && lat_write)
        M.HWDATA = steer_wdata(lat_wdata, lat_addr[1:0], lat_size);
end

// -----------------------------------------------------------------------
// reg_intf response back to user logic
// -----------------------------------------------------------------------
// rdata is valid on the cycle HREADY is asserted during a read data phase.
logic rd_data_valid;
always_comb rd_data_valid = (state == DATA) && M.HREADY && !lat_write;

always_comb regs.rdata  = rd_data_valid ? extract_rdata(M.HRDATA[DW-1:0], lat_addr[1:0], lat_size) : '0;
always_comb regs.rvalid = rd_data_valid;

// Transfer complete (write or read) – one-cycle pulse
always_comb regs.done = (state == DATA) && M.HREADY;

// Busy: asserted whenever a transfer is in flight
always_comb regs.busy = (state != IDLE);

// Error: reflect AHB HRESP (active-high error)
always_comb regs.error = (state == DATA) && M.HRESP;

endmodule
