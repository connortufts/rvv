`include "rtl_macros.svh"

module AHB_RV32I (
     input  logic        FCLK,
     input  logic        SCLK,
     input  logic        HCLK,
     input  logic        DCLK,
     input  logic        PORESETn,
     input  logic        DBGRESETn,
     input  logic        HRESETn,
     input  logic        SWCLKTCK,
     input  logic        nTRST,

     // AHB-LITE MANAGER PORT
     ahb_m_intf.source M,
     output logic        HMASTER,
     // CODE SEQUENTIALITY AND SPECULATION
     output logic        CODENSEQ,
     output logic [ 2:0] CODEHINTDE,
     output logic        SPECHTRANS,

     // DEBUG
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

     // MISC
     input  logic        NMI,
     input  logic [31:0] IRQ,
     output logic        TXEV,
     input  logic        RXEV,
     output logic        LOCKUP,
     output logic        SYSRESETREQ,
     input  logic [25:0] STCALIB,
     input  logic        STCLKEN,
     input  logic [ 7:0] IRQLATENCY,
     input  logic [27:0] ECOREVNUM,    // [27:20] to DAP, [19:0] to core

     // POWER MANAGEMENT
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

     // SCAN IO
     input  logic        SE,
     input  logic        RSTBYPASS,

    input rvDef::instruction_t instruction,
     
);

logic txev_pulse, rxev_pulse;

top u_RV32I (
  .sysclk(FCLK),
  .sysreset(HRESETn),
  .instructionAddr(),
  .instruction(),
  .dmemview(),
  .viewaddr()
);

CORTEXM0INTEGRATION u_cm0 (
  .FCLK          (FCLK),
  .SCLK          (SCLK),
  .HCLK          (HCLK),
  .DCLK          (DCLK),
  .PORESETn      (PORESETn),
  .DBGRESETn     (DBGRESETn),
  .HRESETn       (HRESETn),
  .SWCLKTCK      (SWCLKTCK),
  .nTRST         (nTRST),

  // AHB-LITE MASTER PORT
  .HADDR                          (M.HADDR[31:0]),    // AHB transaction address
  .HBURST                         (),  // Not using   // AHB burst: tied to single
  .HMASTLOCK                      (),  // Not using   // AHB locked transfer (always zero)
  .HPROT                          (),  // Not using   // AHB protection: priv; data or inst
  .HSIZE                          (M.HSIZE[2:0]),     // AHB size: byte, half-word or word
  .HTRANS                         (M.HTRANS[1:0]),    // AHB transfer: non-sequential only
  .HWDATA                         (M.HWDATA[31:0]),   // AHB write-data
  .HWRITE                         (M.HWRITE),         // AHB write control
  .HRDATA                         (M.HRDATA[31:0]),   // AHB read-data
  .HREADY                         (M.HREADY),         // AHB stall signal
  .HRESP                          (M.HRESP),          // AHB error response
  .HMASTER       		  (HMASTER),

  // CODE SEQUENTIALITY AND SPECULATION
  .CODENSEQ      (CODENSEQ),  //fixed
  .CODEHINTDE    (CODEHINTDE),
  .SPECHTRANS    (SPECHTRANS),

  // DEBUG
  .SWDITMS       (SWDITMS),   //fixed
  .TDI           (TDI),        //fixed
  .SWDO          (SWDO),      //fixed
  .SWDOEN        (SWDOEN),     //fixed
  .TDO           (TDO),       //fixed
  .nTDOEN        (nTDOEN),   //fixed
  .DBGRESTART    (DBGRESTART),
  .DBGRESTARTED  (DBGRESTARTED), //fixed
  .EDBGRQ        (EDBGRQ),
  .HALTED        (HALTED),   //fixed

  // MISC
  .NMI            (NMI),        //fixed Non-maskable interrupt input
  .IRQ            (IRQ),        //fixed Interrupt request inputs
  .TXEV           (txev_pulse),              // fixed Event output (SEV executed)
  .RXEV           (rxev_pulse),              //fixed  Event input
  .LOCKUP         (LOCKUP),            //fixed Core is locked-up
  .SYSRESETREQ    (SYSRESETREQ),       //fixed System reset request
  .STCALIB        (STCALIB),           //fixed SysTick calibration register value
  .STCLKEN        (STCLKEN),           //fixed SysTick SCLK clock enable
  .IRQLATENCY     (IRQLATENCY),
  .ECOREVNUM      (ECOREVNUM),

  // POWER MANAGEMENT
  .GATEHCLK      (GATEHCLK),
  .SLEEPING      (SLEEPING),           //fixed Core and NVIC sleeping
  .SLEEPDEEP     (SLEEPDEEP),          //fixed
  .WAKEUP        (WAKEUP),
  .WICSENSE      (WICSENSE),
  .SLEEPHOLDREQn (SLEEPHOLDREQn),
  .SLEEPHOLDACKn (SLEEPHOLDACKn),
  .WICENREQ      (WICENREQ),
  .WICENACK      (WICENACK),
  .CDBGPWRUPREQ  (CDBGPWRUPREQ),
  .CDBGPWRUPACK  (CDBGPWRUPACK),

  // SCAN IO
  .SE            (SE),
  .RSTBYPASS     (RSTBYPASS)
);

// ------------------------------------------------------------
// TXEV, RXEV
// ------------------------------------------------------------
// Generate TXEV level signal from pulse
logic txev_nxt;
always_comb txev_nxt = TXEV ^ txev_pulse;
`FF(txev_nxt,TXEV,HCLK,1'b1,HRESETn,1'b0);

// Generate RXEV pulse signal from level
logic rxev_delay1, rxev_delay2;
`FF(RXEV,rxev_delay1,HCLK,1'b1,HRESETn,1'b0);
`FF(rxev_delay1,rxev_delay2,HCLK,1'b1,HRESETn,1'b0);
always_comb rxev_pulse = rxev_delay1 & (~rxev_delay2);



endmodule
