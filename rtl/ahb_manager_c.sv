// ahb_mgr.sv - AHB Manager (Master) to reg_intf
// Companion to ahb_sub.sv
// Implements AHB-lite manager side: initiates transfers, handles
// wait states (HREADY), and presents a simple reg_intf to the user logic.
//
// NOTES:
//  - Only supports single (non-burst) transfers.
//  - Only supports full-word (32-bit) transactions (HSIZE = 3'b010).
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
logic req_valid;
logic req_write;
logic [AW-1:0] req_addr;
logic [DW-1:0] req_wdata;

always_comb req_valid = regs.write_en | regs.read_en;
always_comb req_write = regs.write_en;

// Latch request at the start of the address phase so signals are stable
// through the data phase even if the caller de-asserts early.
logic        lat_write;
logic [AW-1:0] lat_addr;
logic [DW-1:0] lat_wdata;

`FF(req_write,           lat_write,          clk, (state == IDLE && req_valid), rstn, '0);
`FF(regs.addr[AW-1:0],  lat_addr[AW-1:0],   clk, (state == IDLE && req_valid), rstn, '0);
`FF(regs.wdata[DW-1:0], lat_wdata[DW-1:0],  clk, (state == IDLE && req_valid), rstn, '0);

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
// Address / control phase outputs
always_comb begin
    // Defaults
    M.HTRANS = 2'b00;   // IDLE
    M.HADDR  = '0;
    M.HWRITE = 1'b0;
    M.HSIZE  = 3'b010;  // 32-bit word

    case (state)
        IDLE: begin
            if (req_valid) begin
                // Pre-drive address on the same cycle we move to ADDR
                // so the subordinate sees it immediately.
                M.HTRANS = 2'b10;           // NONSEQ
                M.HADDR  = {{(32-AW){1'b0}}, regs.addr[AW-1:0]};
                M.HWRITE = req_write;
            end
        end
        ADDR: begin
            M.HTRANS = 2'b10;               // NONSEQ
            M.HADDR  = {{(32-AW){1'b0}}, lat_addr[AW-1:0]};
            M.HWRITE = lat_write;
        end
        DATA: begin
            if (M.HREADY && req_valid) begin
                // Pipeline: start next address phase while data completes
                M.HTRANS = 2'b10;
                M.HADDR  = {{(32-AW){1'b0}}, regs.addr[AW-1:0]};
                M.HWRITE = req_write;
            end
        end
        default: ;
    endcase
end

// Write data phase output – present HWDATA during the data phase
always_comb begin
    M.HWDATA = '0;
    if (state == DATA && lat_write)
        M.HWDATA = lat_wdata;
end

// -----------------------------------------------------------------------
// reg_intf response back to user logic
// -----------------------------------------------------------------------
// rdata is valid on the cycle HREADY is asserted during a read data phase.
logic rd_data_valid;
always_comb rd_data_valid = (state == DATA) && M.HREADY && !lat_write;

always_comb regs.rdata  = rd_data_valid ? M.HRDATA[DW-1:0] : '0;
always_comb regs.rvalid = rd_data_valid;

// Transfer complete (write or read) – one-cycle pulse
always_comb regs.done = (state == DATA) && M.HREADY;

// Busy: asserted whenever a transfer is in flight
always_comb regs.busy = (state != IDLE);

// Error: reflect AHB HRESP (active-high error)
always_comb regs.error = (state == DATA) && M.HRESP;

endmodule
