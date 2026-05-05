// CM0_SYS.sv - Cortex M0 subsystem containing AHB and APB buses.
// Paul Whatmough 02 2017
// MD 04 2019
// MD 03 2020

// This is a pure netlist (no flops or logic allowed).
`default_nettype none

module CM0_SYS
(

// Control signals for IO pads
//TODO review these

// Clock and reset
input  logic               FCLK,             // Free running clock
input  logic               HCLK,             // AHB clock(from PMU)
input  logic               DCLK,             // Debug system clock (from PMU)
input  logic               SCLK,             // System clock
output  logic              HRESETn,          // AHB and System reset
input  logic               PORESETn,         // Power on reset
input  logic               DBGRESETn,        // Debug reset




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


output logic         SLEEPING,
output logic         SLEEPDEEP,


// Debug
input  logic               nTRST,            // JTAG - Test reset (active low)
input  logic               SWDITMS,          // JTAG/SWD - TMS / SWD data input
input  logic               SWCLKTCK,         // JTAG/SWD - TCK / SWCLK
input  logic               TDI,              // JTAG - Test data in
output logic               TDO,              // JTAG - Test data out
output logic               nTDOEN,           // JTAG - Test data out enable (active low)
output logic               SWDO,             // SWD - SWD data output
output logic               SWDOEN,           // SWD - SWD data output enable

// Scan Chain Manager
input   logic           FESEL,
input   logic           SCLK1,
input   logic           SCLK2,
input   logic           SHIFTIN,
input   logic           SCEN,
output  logic           SHIFTOUT,

// Mabager UART
input   logic           UART_M_RXD,
output  logic           UART_M_TXD,
input   logic           UART_M_CTS,
output  logic           UART_M_RTS,
input   logic  [3:0]    UART_M_BAUD_SEL,

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
//---------------------------------------------------------

// connections between SoC components and bus matrix
ahb_m_intf AHB_COMMCTRL(.HCLK, .HRESETn);
ahb_m_intf AHB_CM0(.HCLK, .HRESETn);
ahb_m_intf #(.STUB(1)) AHB_MSTUB0(.HCLK, .HRESETn);
ahb_m_intf #(.STUB(1)) AHB_MSTUB1(.HCLK, .HRESETn);
ahb_m_intf AHB_MOUT(.HCLK, .HRESETn);

logic [1:0] HMSEL;
logic [1:0] HMASTER;

AHB_MGR_MUX
#(
.M0_ENABLE(1'b1),
.M1_ENABLE(1'b1),
.M2_ENABLE(1'b0),
.M3_ENABLE(1'b0)
)
uAHB_MGR_MUX
(
.HCLK,
.HRESETn,
.HMSEL,
.HMASTER,
.M0(AHB_COMMCTRL.sink),
.M1(AHB_CM0.sink),
.M2(AHB_MSTUB0.sink),
.M3(AHB_MSTUB1.sink),
.MOUT(AHB_MOUT.source)
);

//---------------------------------------------------------
// CM0 AHB Bus
//---------------------------------------------------------
import cm0_memmap_pkg::*;

// array of sub interfaces

localparam NSUBS = 8;
ahb_s_intf AHB_S[NSUBS](.HCLK, .HRESETn);


AHB_BUS #(
.NSUBS        (NSUBS),
.DEFAULT_SUB  (1),
.DW             (32),
.AW             (32),
.S_ADDR_START  ({
S7_ADDR_START,
S6_ADDR_START,
S5_ADDR_START,
S4_ADDR_START,
S3_ADDR_START,
S2_ADDR_START,
S1_ADDR_START,
S0_ADDR_START
}),
.S_ADDR_END    ({
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

// Bridge AHB_S[7] to external subordinate port S
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
// CMSDK APB Peripherals Subsystem
//---------------------------------------------------------

logic UART0_RXD;
logic UART0_TXD;
logic UART1_RXD;
logic UART1_TXD;
logic [31:0] APBSUBSYS_INTERRUPT;
logic WATCHDOG_INTERRUPT;

APB_SYS uAPB_SYS (
.HCLK,
.HRESETn,
.S(AHB_S[2].source),

.UART0_RXD,
.UART0_TXD,
.UART0_TXEN(),

.UART1_RXD,
.UART1_TXD,
.UART1_TXEN(),

.UART2_RXD,
.UART2_TXD,
.UART2_TXEN(),

.TIMER0_EXTIN,
.TIMER1_EXTIN,

.APBSUBSYS_INTERRUPT,
.WATCHDOG_INTERRUPT,
.WDOGRESETREQ
);

// Loopback between UART0 and UART1 for internal testing
always_comb UART0_RXD = UART1_TXD;
always_comb UART1_RXD = UART0_TXD;

//---------------------------------------------------------
// Cortex-M0
//---------------------------------------------------------

logic         NMI;
logic [31:0]  IRQ;
logic [25:0]  STCALIB;
logic         STCLKEN;
logic         HALTED;
logic         DBGRESTARTED;
logic [33:0]  WICSENSE;
logic         CODENSEQ;



// Replaced AHB_CM0 (Cortex-M0) with AHB_RISCV (RiscvCore wrapper)
AHB_RISCV
u_AHB_CM0
(
  // CLOCK AND RESETS
  .FCLK          (FCLK),
  .SCLK          (SCLK),
  .HCLK          (HCLK),
  .DCLK          (DCLK),
  .PORESETn      (PORESETn),
  .DBGRESETn     (DBGRESETn),
  .HRESETn       (HRESETn),
  .SWCLKTCK      (SWCLKTCK),
  .nTRST         (nTRST),

  // AHB-LITE MANAGER PORT
  .M             (AHB_CM0.source),
  .HMASTER       (),

  // CODE SEQUENTIALITY AND SPECULATION (stubs)
  .CODENSEQ      (CODENSEQ),
  .CODEHINTDE    (),
  .SPECHTRANS    (),

  // DEBUG (stubs – RiscvCore has no debug interface)
  .SWDITMS       (SWDITMS),
  .TDI           (TDI),
  .SWDO          (SWDO),
  .SWDOEN        (SWDOEN),
  .TDO           (TDO),
  .nTDOEN        (nTDOEN),
  .DBGRESTART    (1'b0),
  .DBGRESTARTED  (DBGRESTARTED),
  .EDBGRQ        (1'b0),
  .HALTED        (HALTED),

  // MISC (interrupts stubbed – RiscvCore has no CM0 NVIC)
  .NMI           (NMI),
  .IRQ           (IRQ),
  .TXEV          (TXEV),
  .RXEV          (RXEV),
  .LOCKUP        (LOCKUPREQ),
  .SYSRESETREQ   (SYSRESETREQ),
  .STCALIB       (STCALIB),
  .STCLKEN       (STCLKEN),
  .IRQLATENCY    (8'h00),
  .ECOREVNUM     (28'h0),

  // POWER MANAGEMENT (stubs)
  .GATEHCLK      (),
  .SLEEPING      (SLEEPING),
  .SLEEPDEEP     (SLEEPDEEP),
  .WAKEUP        (),
  .WICSENSE      (WICSENSE),
  .SLEEPHOLDREQn(1'b1),
  .SLEEPHOLDACKn(),
  .WICENREQ      (1'b0),
  .WICENACK      (),
  .CDBGPWRUPREQ  (),
  .CDBGPWRUPACK  (1'b0),

  // SCAN IO (stubs)
  .SE            (1'b0),
  .RSTBYPASS     (1'b0)
);


//---------------------------------------------------------
// Comm Controller
//---------------------------------------------------------
logic IRQ_COMMCTRL;

COMMCTRL uCOMMCTRL (
.clk(HCLK),
.rstn(PORESETn),
.M(AHB_COMMCTRL.source),

.FESEL,
// Scan Chain signals
.SCLK1,
.SCLK2,
.SHIFTIN,
.SCEN,
.SHIFTOUT,
// UART signals
.UART_M_BAUD_SEL,
.UART_M_RXD,
.UART_M_CTS,
.UART_M_RTS,
.UART_M_TXD,
.IRQ_COMMCTRL,
.HMSEL
);

//---------------------------------------------------------
// SysTick
//---------------------------------------------------------
// STCLKEN is SysTick Clock and used as a reference clock for CM0
// STCALIB is hardcoded (reference clock provided, ref info not available)
// STCALIB[25]=1'b0, STCALIB[24]=1'b0, STCALIB[23:0]=24{1'b0}
// DIV_RATIO is Clock Divider

cmsdk_mcu_stclkctrl
#(.DIV_RATIO (18'd01000))
u_cmsdk_mcu_stclkctrl (
.FCLK      (HCLK),
.SYSRESETn (HRESETn),
.STCLKEN   (STCLKEN),       // SysTick Clock
.STCALIB   (STCALIB[25:0])  // SysTick Calibration Value Register
);


//---------------------------------------------------------
// GPIO0
//---------------------------------------------------------
logic [15:0] GPIO0_INT;
logic        GPIO0_COMBINT;

AHB_GPIO uGPIO0(
.HCLK,
.HRESETn,
.S(AHB_S[3].source),
.PORTIN   (GPIO0_PORTIN),
.PORTOUT  (GPIO0_PORTOUT),
.PORTEN   (GPIO0_PORTEN),
.PORTFUNC (),  // Functions are fixed.
.GPIOINT  (GPIO0_INT),
.COMBINT  (GPIO0_COMBINT)
);

//---------------------------------------------------------
// GPIO1
//---------------------------------------------------------

// Not using GPIO1

logic [15:0] GPIO1_INT;
logic GPIO1_COMBINT;

AHB_GPIO uGPIO1(
.HCLK,
.HRESETn,
.S(AHB_S[4].source),
.PORTIN   (GPIO1_PORTIN),
.PORTOUT  (GPIO1_PORTOUT),
.PORTEN   (GPIO1_PORTEN),
.PORTFUNC (), // Functions are fixed.
.GPIOINT  (GPIO1_INT),
.COMBINT  (GPIO1_COMBINT)
);

//---------------------------------------------------------
// System controller
//---------------------------------------------------------

// All the SRAM and PAD CFG stuff is now in CRG.

AHB_SYSCTL uSYSCTL
(
.HCLK,
.HRESETn,
.S(AHB_S[5].source),
.PORESETn(PORESETn),
.SYSRESETREQ,       // System Reset Request
.WDOGRESETREQ,      // Watchdog Reset Request
.LOCKUPREQ,         // Lockup Reset Request
.PMUENABLE(),       // Always 0, PMU not available
//.SC_AHB_RSTN,       // AHB Reset Signal
//TODO FIX SRAM PINS
.SC_SRAM_RTSEL(),       // SRAM Extra Margin Adjustment
.SC_SRAM_WTSEL()      // SRAM Extra Margin Adjustment for Writes
);

//---------------------------------------------------------
// Clock and Reset Generator (CRG)
//---------------------------------------------------------

logic       DC_MEM_PD;
logic [1:0] DC_MEM_RTSEL;
logic [1:0] DC_MEM_WTSEL;


CRG uCRG (
.HCLK, 
.HRESETn,
.PORESETn,
.S(AHB_S[6].source),

.EXTCLK0,
.EXTCLK1,

.CRG_DIAG0,
.CRG_DIAG1
);


//---------------------------------------------------------
// IMEM 64KB
//---------------------------------------------------------

AHB_MEM #(
.AW(16),        // 64KB
.filename("../image.hex")
)
uMEM0 (
.HCLK,
.HRESETn,
.S(AHB_S[0].source)
);


//---------------------------------------------------------
// DMEM 64KB
//---------------------------------------------------------

AHB_MEM #(
.AW(16),        // 64KB
.filename("")
)
uMEM1 (
.HCLK,
.HRESETn,
.S(AHB_S[1].source)
);

//---------------------------------------------------------
// IRQs
//---------------------------------------------------------

// Ape CMSDK interrupt assignments as far as possible

always_comb begin
NMI        = 1'b0; // Not used (used for Watchdog in CMSDK)
IRQ[0]     = APBSUBSYS_INTERRUPT[0]; // UART0 RX
IRQ[1]     = APBSUBSYS_INTERRUPT[1]; // UART0 TX
IRQ[2]     = APBSUBSYS_INTERRUPT[2]; // UART1 RX
IRQ[3]     = APBSUBSYS_INTERRUPT[3]; // UART1 TX
IRQ[4]     = APBSUBSYS_INTERRUPT[4]; // UART2 RX
IRQ[5]     = APBSUBSYS_INTERRUPT[5]; // UART2 TX
IRQ[6]     = APBSUBSYS_INTERRUPT[6] | GPIO0_COMBINT; // GPIO0 Combined
IRQ[7]     = APBSUBSYS_INTERRUPT[7] | GPIO1_COMBINT; // GPIO1 Combined
IRQ[8]     = APBSUBSYS_INTERRUPT[8];  // TIMER0
IRQ[9]     = APBSUBSYS_INTERRUPT[9];  // TIMER1
IRQ[10]    = APBSUBSYS_INTERRUPT[10]; // DUAL TIMER2
IRQ[11]    = IRQ_COMMCTRL;            // COMMCTRL interrupt
IRQ[12]    = APBSUBSYS_INTERRUPT[12]; // UART0 Overflow + COMMCTRL interrupt
IRQ[13]    = APBSUBSYS_INTERRUPT[13]; // UART1 Overflow
IRQ[14]    = APBSUBSYS_INTERRUPT[14]; // UART2 Overflow
IRQ[15]    = ACCEL_IRQ;
IRQ[31:16] = APBSUBSYS_INTERRUPT[31:16] | GPIO0_INT[15:0];
end

endmodule


`default_nettype wire
