`default_nettype none

module RiscvCore_SYS
(
// Clock and reset
input  logic               FCLK,
input  logic               HCLK,
input  logic               DCLK,
input  logic               SCLK,
output logic               HRESETn,
input  logic               PORESETn,
input  logic               DBGRESETn,

// Pins
input   logic           EXTCLK0,
input   logic           EXTCLK1,
output  logic           TXEV,
input   logic           RXEV,
output  logic           LOCKUPREQ,
output  logic           WDOGRESETREQ,
output  logic           SYSRESETREQ,
output  logic           CRG_DIAG0,
output  logic           CRG_DIAG1,

output logic [31:0]     cpu_pc,
input  logic [31:0]     cpu_instruction,
output logic [31:0]     cpu_dmem_addr,
output logic [31:0]     cpu_dmem_wdata,
input  logic [31:0]     cpu_dmem_rdata,
output logic            cpu_dmem_write,
output logic            cpu_dmem_read,
output logic [3:0]      cpu_dmem_byte_write_enable,	

output logic         SLEEPING,
output logic         SLEEPDEEP,

// NOTE: Debug ports removed — RiscvCore has no JTAG/SWD interface.
// If you need debug, add a separate debug module on an APB port.

// Scan Chain Manager
input   logic           FESEL,
input   logic           SCLK1,
input   logic           SCLK2,
input   logic           SHIFTIN,
input   logic           SCEN,
output  logic           SHIFTOUT,

// Manager UART
input   logic           UART_M_RXD,
output  logic           UART_M_TXD,
input   logic           UART_M_CTS,
output  logic           UART_M_RTS,
input  logic  [3:0]     UART_M_BAUD_SEL,

// Sub UARTs
output logic            UART2_TXD,
input  logic            UART2_RXD,

// Timers
input  logic            TIMER0_EXTIN,
input  logic            TIMER1_EXTIN,

// GPIO
input  logic  [15:0]    GPIO0_PORTIN,
output logic  [15:0]    GPIO0_PORTOUT,
output logic  [15:0]    GPIO0_PORTEN,
input  logic  [15:0]    GPIO1_PORTIN,
output logic  [15:0]    GPIO1_PORTOUT,
output logic  [15:0]    GPIO1_PORTEN,

// External AHB subordinate port (slot 7)
ahb_s_intf.sink S,

input logic ACCEL_IRQ
);

//---------------------------------------------------------
// AHB Manager Mux
// NOTE: Removed AHB_COMMCTRL master slot — COMMCTRL now
// sits on APB via AHB_S[2], so only one AHB master needed.
// Stub slots M1-M3 kept for future expansion.
//---------------------------------------------------------
ahb_m_intf AHB_RISCV(.HCLK, .HRESETn);           // RiscvCore master
ahb_m_intf AHB_COMMCTRL(.HCLK, .HRESETn);        // keep if COMMCTRL needs DMA
ahb_m_intf #(.STUB(1)) AHB_MSTUB0(.HCLK, .HRESETn);
ahb_m_intf #(.STUB(1)) AHB_MSTUB1(.HCLK, .HRESETn);
ahb_m_intf AHB_MOUT(.HCLK, .HRESETn);

logic [1:0] HMSEL;
logic [1:0] HMASTER;
localparam logic [31:0] ACCEL_BASE     = 32'hA000_0000;
localparam logic [31:0] CTRL_OFF       = 32'h10;
localparam logic [31:0] STATUS_OFF     = 32'h14;
localparam logic [31:0] IMEM_ADDR_OFF  = 32'h1C;
localparam logic [31:0] IMEM_DATA_OFF  = 32'h20;
localparam logic [31:0] DMEM_ADDR_OFF  = 32'h24;
localparam logic [31:0] DMEM_WDATA_OFF = 32'h28;
localparam logic [31:0] DMEM_RDATA_OFF = 32'h2C;
localparam logic [31:0] CTRL_RUN       = 32'h4;


AHB_MGR_MUX
#(
    .M0_ENABLE(1'b1),   // RiscvCore
    .M1_ENABLE(1'b1),   // COMMCTRL (keep enabled)
    .M2_ENABLE(1'b0),
    .M3_ENABLE(1'b0)
)
uAHB_MGR_MUX
(
    .HCLK,
    .HRESETn,
    .HMSEL,
    .HMASTER,
    .M0(AHB_RISCV.sink),
    .M1(AHB_COMMCTRL.sink),
    .M2(AHB_MSTUB0.sink),
    .M3(AHB_MSTUB1.sink),
    .MOUT(AHB_MOUT.source)
);

//---------------------------------------------------------
// AHB Bus — unchanged, same memory map
//---------------------------------------------------------
import cm0_memmap_pkg::*;

localparam NSUBS = 8;
ahb_s_intf AHB_S[NSUBS](.HCLK, .HRESETn);

AHB_BUS #(
    .NSUBS        (NSUBS),
    .DEFAULT_SUB  (1),
    .DW           (32),
    .AW           (32),
    .S_ADDR_START ({
        S7_ADDR_START,
        S6_ADDR_START,
        S5_ADDR_START,
        S4_ADDR_START,
        S3_ADDR_START,
        S2_ADDR_START,
        S1_ADDR_START,
        S0_ADDR_START
    }),
    .S_ADDR_END   ({
        S7_ADDR_END,
        S6_ADDR_END,
        S5_ADDR_END,
        S4_ADDR_END,
        S3_ADDR_END,
        S2_ADDR_END,
        S1_ADDR_END,
        S0_ADDR_END
    })
)
uAHB_BUS (
    .HCLK,
    .HRESETn,
    .M(AHB_MOUT.sink),
    .S(AHB_S)
);

// Bridge AHB_S[7] to external subordinate port — unchanged
assign S.HSEL    = AHB_S[7].HSEL;
assign S.HADDR   = AHB_S[7].HADDR;
assign S.HTRANS  = AHB_S[7].HTRANS;
assign S.HWRITE  = AHB_S[7].HWRITE;
assign S.HSIZE   = AHB_S[7].HSIZE;
assign S.HWDATA  = AHB_S[7].HWDATA;
assign S.HREADY  = AHB_S[7].HREADY;

assign AHB_S[7].HREADYOUT = S.HREADYOUT;
assign AHB_S[7].HRDATA    = S.HRDATA;
assign AHB_S[7].HRESP     = S.HRESP;

//---------------------------------------------------------
// APB Peripherals — unchanged
//---------------------------------------------------------
logic UART0_RXD, UART0_TXD;
logic UART1_RXD, UART1_TXD;
logic [31:0] APBSUBSYS_INTERRUPT;
logic WATCHDOG_INTERRUPT;

APB_SYS uAPB_SYS (
    .HCLK,
    .HRESETn,
    .S(AHB_S[2].source),
    .UART0_RXD,  .UART0_TXD,  .UART0_TXEN(),
    .UART1_RXD,  .UART1_TXD,  .UART1_TXEN(),
    .UART2_RXD,  .UART2_TXD,  .UART2_TXEN(),
    .TIMER0_EXTIN,
    .TIMER1_EXTIN,
    .APBSUBSYS_INTERRUPT,
    .WATCHDOG_INTERRUPT,
    .WDOGRESETREQ
);

always_comb UART0_RXD = UART1_TXD;
always_comb UART1_RXD = UART0_TXD;

//---------------------------------------------------------
// RiscvCore signals
//---------------------------------------------------------
logic [31:0] instructionAddress;
logic [31:0] instruction;
logic [29:0] memoryAddress;
logic [31:0] readData;
logic [31:0] writeData;
logic        memRead;
logic        memWrite;
logic [3:0]  writeMask;
logic        stall;

assign cpu_pc          = instructionAddress;
assign instruction     = cpu_instruction;    // feed back into RiscvCore

assign readData = cpu_dmem_rdata;
assign cpu_dmem_wdata = writeData;
assign cpu_dmem_addr   = {2'b00, memoryAddress};
assign cpu_dmem_write  = memWrite;
assign cpu_dmem_read   = memRead;
assign cpu_dmem_byte_write_enable = writeMask;
logic fetch_stall;
always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) fetch_stall <= 1'b1;
    else          fetch_stall <= ~fetch_stall; // stall every other cycle
end

logic data_stall;
logic mem_op_pending;

always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        mem_op_pending <= 1'b0;
    else
        mem_op_pending <= (memRead | memWrite) & ~mem_op_pending;
end

assign data_stall = (memRead | memWrite) & ~mem_op_pending;

//---------------------------------------------------------
// RiscvCore
//---------------------------------------------------------
assign SLEEPING   = 1'b0;
assign SLEEPDEEP  = 1'b0;

RiscvCore u_riscv (
    .clk                (HCLK),
    .resetN             (PORESETn),
    .instruction        (instruction),
    .instructionAddress (instructionAddress),
    .memoryAddress      (memoryAddress),
    .readData           (readData),
    .writeData          (writeData),
    .memRead            (memRead),
    .memWrite           (memWrite),
    .writeMask          (writeMask),
    .stall              (stall)
);


typedef enum logic [1:0] {BOOT_IDLE, BOOT_WRITE_CTRL, BOOT_DONE} boot_t;
boot_t boot_state;

always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) boot_state <= BOOT_IDLE;
    else case (boot_state)
        BOOT_IDLE:       boot_state <= BOOT_WRITE_CTRL;
        BOOT_WRITE_CTRL: boot_state <= AHB_RISCV.HREADY ? BOOT_DONE : BOOT_WRITE_CTRL;
        BOOT_DONE:       boot_state <= BOOT_DONE;
    endcase
end

// Hold core in reset until CTRL=RUN is written
//assign stall = (boot_state != BOOT_DONE) | fetch_stall | data_stall;
assign stall = 0;

logic IRQ_COMMCTRL;

COMMCTRL uCOMMCTRL (
    .clk(HCLK),
    .rstn(PORESETn),
    .M(AHB_COMMCTRL.source),
    .FESEL,
    .SCLK1, .SCLK2, .SHIFTIN, .SCEN, .SHIFTOUT,
    .UART_M_BAUD_SEL,
    .UART_M_RXD, .UART_M_CTS, .UART_M_RTS, .UART_M_TXD,
    .IRQ_COMMCTRL,
    .HMSEL
);

logic [15:0] GPIO0_INT;
logic        GPIO0_COMBINT;

AHB_GPIO uGPIO0(
    .HCLK, .HRESETn,
    .S(AHB_S[3].source),
    .PORTIN(GPIO0_PORTIN), .PORTOUT(GPIO0_PORTOUT), .PORTEN(GPIO0_PORTEN),
    .PORTFUNC(),
    .GPIOINT(GPIO0_INT), .COMBINT(GPIO0_COMBINT)
);

logic [15:0] GPIO1_INT;
logic        GPIO1_COMBINT;

AHB_GPIO uGPIO1(
    .HCLK, .HRESETn,
    .S(AHB_S[4].source),
    .PORTIN(GPIO1_PORTIN), .PORTOUT(GPIO1_PORTOUT), .PORTEN(GPIO1_PORTEN),
    .PORTFUNC(),
    .GPIOINT(GPIO1_INT), .COMBINT(GPIO1_COMBINT)
);

AHB_SYSCTL uSYSCTL(
    .HCLK, .HRESETn,
    .S(AHB_S[5].source),
    .PORESETn,
    .SYSRESETREQ, .WDOGRESETREQ, .LOCKUPREQ,
    .PMUENABLE(),
    .SC_SRAM_RTSEL(), .SC_SRAM_WTSEL()
);

CRG uCRG(
    .HCLK, .HRESETn, .PORESETn,
    .S(AHB_S[6].source),
    .EXTCLK0, .EXTCLK1,
    .CRG_DIAG0, .CRG_DIAG1
);

AHB_MEM #(.AW(16), .filename("../image.hex")) uMEM0 (
    .HCLK, .HRESETn,
    .S(AHB_S[0].source)
);

AHB_MEM #(.AW(16), .filename("")) uMEM1 (
    .HCLK, .HRESETn,
    .S(AHB_S[1].source)
);



//---------------------------------------------------------
// IRQs
//---------------------------------------------------------

  assign TXEV        = 1'b0;
  assign LOCKUPREQ   = 1'b0;
  assign SYSRESETREQ = 1'b0;

endmodule

`default_nettype wire
