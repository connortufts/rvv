// AHB_RISCV.sv
// Wraps RiscvCore with an AHB-Lite manager interface so it can plug into
// CM0_SYS in place of AHB_CM0.
//
// RiscvCore uses a split instruction / data memory interface:
//   - Instruction fetch: synchronous, driven by instructionAddress, returns instruction
//   - Data access:       memRead / memWrite / memoryAddress / writeData / readData / writeMask
//   - stall:            held high while an AHB transfer is in-flight
//
// AHB-Lite protocol mapping:
//   Phase 1 (address): HTRANS=NONSEQ, HADDR, HWRITE, HSIZE asserted
//   Phase 2 (data):    HWDATA driven; HREADY sampled; HRDATA captured on HREADY=1
//
// Because the CM0 bus matrix has a single manager port shared between
// instruction fetch and data access, we arbitrate: data wins over fetch
// (matching typical Harvard→von-Neumann collapse).  During a data
// transfer the PC stalls so the fetch address is replayed afterwards.
//
// connor

`default_nettype none

module AHB_RISCV
(
    // Clocks / resets (matching AHB_CM0 port names)
    input  logic        FCLK,       // free-running clock (unused here, kept for compatibility)
    input  logic        SCLK,       // system clock       (unused here)
    input  logic        HCLK,       // AHB bus clock
    input  logic        DCLK,       // debug clock        (unused here)
    input  logic        PORESETn,   // power-on reset (active low)
    input  logic        DBGRESETn,  // debug reset        (unused here)
    input  logic        HRESETn,    // AHB reset (active low)  ← used for core reset

    // AHB-Lite manager port
    ahb_m_intf.source   M,

    // ----------------------------------------------------------------
    // Ports below mirror AHB_CM0 so CM0_SYS can instantiate either.
    // Signals that are CM0-specific are stubbed to safe defaults.
    // ----------------------------------------------------------------

    // Code sequentiality (stub)
    output logic        CODENSEQ,
    output logic [ 2:0] CODEHINTDE,
    output logic        SPECHTRANS,

    // Debug (stub – tie-off)
    input  logic        SWCLKTCK,
    input  logic        nTRST,
    input  logic        SWDITMS,
    input  logic        TDI,
    output logic        SWDO,
    output logic        SWDOEN,
    output logic        TDO,
    output logic        nTDOEN,
    input  logic        DBGRESTART,
    output logic        DBGRESTARTED,
    input  logic        EDBGRQ,
    output logic        HALTED,

    // Interrupts (stub – RISC-V core does not use CM0 interrupt model)
    input  logic        NMI,
    input  logic [31:0] IRQ,
    output logic        TXEV,
    input  logic        RXEV,
    output logic        LOCKUP,
    output logic        SYSRESETREQ,
    input  logic [25:0] STCALIB,
    input  logic        STCLKEN,
    input  logic [ 7:0] IRQLATENCY,
    input  logic [27:0] ECOREVNUM,

    // Power management (stub)
    output logic        GATEHCLK,
    output logic        SLEEPING,
    output logic        SLEEPDEEP,
    output logic        WAKEUP,
    output logic [33:0] WICSENSE,
    input  logic        SLEEPHOLDREQn,
    output logic        SLEEPHOLDACKn,
    input  logic        WICENREQ,
    output logic        WICENACK,
    output logic        CDBGPWRUPREQ,
    input  logic        CDBGPWRUPACK,
    output logic        HMASTER,

    // Scan (stub)
    input  logic        SE,
    input  logic        RSTBYPASS
);

// ============================================================
// Stub outputs (CM0-specific, not driven by RiscvCore)
// ============================================================
assign CODENSEQ    = 1'b1;
assign CODEHINTDE  = 3'b000;
assign SPECHTRANS  = 1'b0;
assign SWDO        = 1'b0;
assign SWDOEN      = 1'b0;
assign TDO         = 1'b0;
assign nTDOEN      = 1'b1;
assign DBGRESTARTED= 1'b0;
assign HALTED      = 1'b0;
assign TXEV        = 1'b0;
assign LOCKUP      = 1'b0;
assign SYSRESETREQ = 1'b0;
assign GATEHCLK    = 1'b0;
assign SLEEPING    = 1'b0;
assign SLEEPDEEP   = 1'b0;
assign WAKEUP      = 1'b0;
assign WICSENSE    = 34'b0;
assign SLEEPHOLDACKn = 1'b1;
assign WICENACK    = 1'b0;
assign CDBGPWRUPREQ= 1'b0;
assign HMASTER     = 1'b0;

// ============================================================
// Internal wires from/to RiscvCore
// ============================================================
logic [31:0] instructionAddress;
logic [31:0] memoryAddress;
logic [31:0] writeData;
logic [31:0] readData_core;   // data returned to core
logic        memRead;
logic        memWrite;
logic [ 3:0] writeMask;
logic        stall;

// Instruction register: latch fetched instruction word
logic [31:0] instruction_reg;
logic [31:0] instruction;

// ============================================================
// AHB-Lite State Machine
// ============================================================
// We multiplex instruction fetch and data access onto one AHB port.
// Priority: data > fetch.
//
// States:
//   IDLE      – no transfer pending
//   FETCH_ADDR– instruction fetch address phase
//   FETCH_DATA– instruction fetch data phase (waiting HREADY)
//   DATA_ADDR – data read/write address phase
//   DATA_DATA – data transfer data phase (waiting HREADY)

typedef enum logic [2:0] {
    IDLE       = 3'd0,
    FETCH_ADDR = 3'd1,
    FETCH_DATA = 3'd2,
    DATA_ADDR  = 3'd3,
    DATA_DATA  = 3'd4
} ahb_state_t;

ahb_state_t state, next_state;

// Track whether a data op is pending
logic data_pending;
logic fetch_pending;

// Saved data-phase information
logic [31:0] saved_data_addr;
logic        saved_data_write;
logic [ 3:0] saved_data_mask;
logic [31:0] saved_write_data;

// ============================================================
// State register
// ============================================================
always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        state <= IDLE;
    else
        state <= next_state;
end

// ============================================================
// Next-state + AHB output logic
// ============================================================
always_comb begin
    // Default AHB outputs
    M.HADDR  = 32'h0;
    M.HTRANS = 2'b00;   // IDLE
    M.HWRITE = 1'b0;
    M.HSIZE  = 3'b010;  // word
    M.HWDATA = 32'h0;
    stall    = 1'b0;
    next_state = state;

    case (state)
        //------------------------------------------------------
        IDLE: begin
            if (memRead | memWrite) begin
                // Data access takes priority
                M.HADDR  = memoryAddress;
                M.HTRANS = 2'b10;   // NONSEQ
                M.HWRITE = memWrite;
                M.HSIZE  = 3'b010;  // always word for now; LSU handles sub-word via mask
                stall    = 1'b1;    // stall core until transfer completes
                next_state = DATA_DATA;
            end else begin
                // Instruction fetch
                M.HADDR  = instructionAddress;
                M.HTRANS = 2'b10;   // NONSEQ
                M.HWRITE = 1'b0;
                M.HSIZE  = 3'b010;
                stall    = 1'b1;    // stall until fetch returns
                next_state = FETCH_DATA;
            end
        end

        //------------------------------------------------------
        FETCH_DATA: begin
            // Hold fetch address (AHB address phase already sent)
            M.HADDR  = instructionAddress;
            M.HTRANS = 2'b00;   // IDLE during data phase (single transfer)
            M.HWRITE = 1'b0;
            M.HSIZE  = 3'b010;

            if (!M.HREADY) begin
                stall = 1'b1;   // bus not ready, keep stalling
            end else begin
                // HRDATA is valid – instruction captured by flip-flop below
                // Check if a data access arrived while we were fetching
                stall = (memRead | memWrite); // stall if we immediately need data access
                if (memRead | memWrite)
                    next_state = DATA_ADDR;
                else
                    next_state = IDLE;
            end
        end

        //------------------------------------------------------
        DATA_ADDR: begin
            // Address phase for data transfer
            M.HADDR  = memoryAddress;
            M.HTRANS = 2'b10;   // NONSEQ
            M.HWRITE = memWrite;
            M.HSIZE  = 3'b010;
            stall    = 1'b1;
            next_state = DATA_DATA;
        end

        //------------------------------------------------------
        DATA_DATA: begin
            // Data phase – drive HWDATA for writes
            M.HADDR  = 32'h0;
            M.HTRANS = 2'b00;
            M.HWRITE = 1'b0;
            M.HSIZE  = 3'b010;
            M.HWDATA = saved_write_data;

            if (!M.HREADY) begin
                stall = 1'b1;
            end else begin
                // Transfer complete; release stall, go fetch next instruction
                stall = 1'b0;
                next_state = IDLE;
            end
        end

        default: next_state = IDLE;
    endcase
end

// ============================================================
// Save data-access parameters at the start of address phase
// ============================================================
always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        saved_data_addr   <= 32'h0;
        saved_data_write  <= 1'b0;
        saved_data_mask   <= 4'hF;
        saved_write_data  <= 32'h0;
    end else if ((state == IDLE || state == FETCH_DATA) && (memRead | memWrite)) begin
        saved_data_addr  <= memoryAddress;
        saved_data_write <= memWrite;
        saved_data_mask  <= writeMask;
        saved_write_data <= writeData;
    end
end

// ============================================================
// Capture read data from bus
// ============================================================
always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        readData_core   <= 32'h0;
        instruction_reg <= 32'h0;
    end else if (M.HREADY) begin
        case (state)
            FETCH_DATA: instruction_reg <= M.HRDATA;
            DATA_DATA:  readData_core   <= M.HRDATA;
            default: ;
        endcase
    end
end

// Instruction presented to core: use the newly captured value when the
// fetch data phase completes, otherwise hold the registered value.
assign instruction = (state == FETCH_DATA && M.HREADY) ? M.HRDATA : instruction_reg;
assign readData    = readData_core;

// ============================================================
// RiscvCore instantiation
// ============================================================
RiscvCore u_riscv (
    .clk               (HCLK),
    .resetN            (HRESETn),
    .instruction       (instruction),
    .instructionAddress(instructionAddress),
    .memoryAddress     (memoryAddress),
    .readData          (readData),
    .writeData         (writeData),
    .memRead           (memRead),
    .memWrite          (memWrite),
    .writeMask         (writeMask),
    .stall             (stall)
);

endmodule

`default_nettype wire
