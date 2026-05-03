// TOP.sv - top level SoC netlist

`include "rtl_macros.svh"
`default_nettype none

module AHB_TOP
(
// Control signals for IO pads
//TODO review these

// Clock and reset
input  logic               FCLK,             // Free running clock
input  logic               HCLK,             // AHB clock(from PMU)
input  logic               DCLK,             // Debug system clock (from PMU)
input  logic               SCLK,             // System clock
output  logic               HRESETn,          // AHB and System reset
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

// Scan Chain Master
input   logic           FESEL,
input   logic           SCLK1,
input   logic           SCLK2,
input   logic           SHIFTIN,
input   logic           SCEN,
output  logic           SHIFTOUT,

// Master UART
input   logic           UART_M_RXD,
output  logic           UART_M_TXD,
input   logic           UART_M_CTS,
output  logic           UART_M_RTS,
input   logic           UART_M_BAUD_SEL0,
input   logic           UART_M_BAUD_SEL1,
input   logic           UART_M_BAUD_SEL2,
input   logic           UART_M_BAUD_SEL3,

// Slave UARTs
output logic            UART2_TXD,
input  logic            UART2_RXD,

// Timers
input  logic            TIMER0_EXTIN,
input  logic            TIMER1_EXTIN,

// GPIO
input  logic            GPIO0_PORTIN0,
input  logic            GPIO0_PORTIN1,
input  logic            GPIO0_PORTIN2,
input  logic            GPIO0_PORTIN3,
input  logic            GPIO0_PORTIN4,
input  logic            GPIO0_PORTIN5,
input  logic            GPIO0_PORTIN6,
input  logic            GPIO0_PORTIN7,
input  logic            GPIO0_PORTIN8,
input  logic            GPIO0_PORTIN9,
input  logic            GPIO0_PORTIN10,
input  logic            GPIO0_PORTIN11,
input  logic            GPIO0_PORTIN12,
input  logic            GPIO0_PORTIN13,
input  logic            GPIO0_PORTIN14,
input  logic            GPIO0_PORTIN15,
output logic            GPIO0_PORTOUT0,
output logic            GPIO0_PORTOUT1,
output logic            GPIO0_PORTOUT2,
output logic            GPIO0_PORTOUT3,
output logic            GPIO0_PORTOUT4,
output logic            GPIO0_PORTOUT5,
output logic            GPIO0_PORTOUT6,
output logic            GPIO0_PORTOUT7,
output logic            GPIO0_PORTOUT8,
output logic            GPIO0_PORTOUT9,
output logic            GPIO0_PORTOUT10,
output logic            GPIO0_PORTOUT11,
output logic            GPIO0_PORTOUT12,
output logic            GPIO0_PORTOUT13,
output logic            GPIO0_PORTOUT14,
output logic            GPIO0_PORTOUT15,
output logic            GPIO0_PORTEN0,
output logic            GPIO0_PORTEN1,
output logic            GPIO0_PORTEN2,
output logic            GPIO0_PORTEN3,
output logic            GPIO0_PORTEN4,
output logic            GPIO0_PORTEN5,
output logic            GPIO0_PORTEN6,
output logic            GPIO0_PORTEN7,
output logic            GPIO0_PORTEN8,
output logic            GPIO0_PORTEN9,
output logic            GPIO0_PORTEN10,
output logic            GPIO0_PORTEN11,
output logic            GPIO0_PORTEN12,
output logic            GPIO0_PORTEN13,
output logic            GPIO0_PORTEN14,
output logic            GPIO0_PORTEN15,
input  logic            GPIO1_PORTIN0,
input  logic            GPIO1_PORTIN1,
input  logic            GPIO1_PORTIN2,
input  logic            GPIO1_PORTIN3,
input  logic            GPIO1_PORTIN4,
input  logic            GPIO1_PORTIN5,
input  logic            GPIO1_PORTIN6,
input  logic            GPIO1_PORTIN7,
input  logic            GPIO1_PORTIN8,
input  logic            GPIO1_PORTIN9,
input  logic            GPIO1_PORTIN10,
input  logic            GPIO1_PORTIN11,
input  logic            GPIO1_PORTIN12,
input  logic            GPIO1_PORTIN13,
input  logic            GPIO1_PORTIN14,
input  logic            GPIO1_PORTIN15,
output logic            GPIO1_PORTOUT0,
output logic            GPIO1_PORTOUT1,
output logic            GPIO1_PORTOUT2,
output logic            GPIO1_PORTOUT3,
output logic            GPIO1_PORTOUT4,
output logic            GPIO1_PORTOUT5,
output logic            GPIO1_PORTOUT6,
output logic            GPIO1_PORTOUT7,
output logic            GPIO1_PORTOUT8,
output logic            GPIO1_PORTOUT9,
output logic            GPIO1_PORTOUT10,
output logic            GPIO1_PORTOUT11,
output logic            GPIO1_PORTOUT12,
output logic            GPIO1_PORTOUT13,
output logic            GPIO1_PORTOUT14,
output logic            GPIO1_PORTOUT15,
output logic            GPIO1_PORTEN0,
output logic            GPIO1_PORTEN1,
output logic            GPIO1_PORTEN2,
output logic            GPIO1_PORTEN3,
output logic            GPIO1_PORTEN4,
output logic            GPIO1_PORTEN5,
output logic            GPIO1_PORTEN6,
output logic            GPIO1_PORTEN7,
output logic            GPIO1_PORTEN8,
output logic            GPIO1_PORTEN9,
output logic            GPIO1_PORTEN10,
output logic            GPIO1_PORTEN11,
output logic            GPIO1_PORTEN12,
output logic            GPIO1_PORTEN13,
output logic            GPIO1_PORTEN14,
output logic            GPIO1_PORTEN15
);


logic ACCEL_IRQ;

ahb_s_intf S_BRIDGE(.HCLK, .HRESETn);

//---------------------------------------------------------
// RiscvCore Sub-system
//---------------------------------------------------------

RiscvCore_SYS uRiscvCore_SYS
(
.FCLK,
.HCLK,
.DCLK,
.SCLK,
.HRESETn,
.PORESETn,
.DBGRESETn,

// Pins
.EXTCLK0,
.EXTCLK1,
.TXEV,
.RXEV,
.LOCKUPREQ,
.WDOGRESETREQ,
.SYSRESETREQ,
.CRG_DIAG0,
.CRG_DIAG1,

.cpu_pc                     (cpu_pc),
.cpu_instruction            (cpu_instruction),
.cpu_dmem_addr              (cpu_dmem_addr),
.cpu_dmem_wdata             (cpu_dmem_wdata),
.cpu_dmem_write             (cpu_dmem_write),
.cpu_dmem_read              (cpu_dmem_read),
.cpu_dmem_byte_write_enable (cpu_dmem_byte_write_enable),
.cpu_dmem_rdata             (cpu_dmem_rdata),

.SLEEPING,
.SLEEPDEEP,

// Scan Chain Master
.FESEL,
.SCLK1,
.SCLK2,
.SHIFTIN,
.SCEN,
.SHIFTOUT,

// Master UART
.UART_M_RXD,
.UART_M_TXD,
.UART_M_CTS,
.UART_M_RTS,
.UART_M_BAUD_SEL ({UART_M_BAUD_SEL3, UART_M_BAUD_SEL2, UART_M_BAUD_SEL1, UART_M_BAUD_SEL0}),

// Slave UARTs
.UART2_TXD,
.UART2_RXD,

// Timers
.TIMER0_EXTIN,
.TIMER1_EXTIN,

//GPIOs
.GPIO0_PORTIN  ({GPIO0_PORTIN15,  GPIO0_PORTIN14,  GPIO0_PORTIN13,  GPIO0_PORTIN12,
                 GPIO0_PORTIN11,  GPIO0_PORTIN10,  GPIO0_PORTIN9,   GPIO0_PORTIN8,
                 GPIO0_PORTIN7,   GPIO0_PORTIN6,   GPIO0_PORTIN5,   GPIO0_PORTIN4,
                 GPIO0_PORTIN3,   GPIO0_PORTIN2,   GPIO0_PORTIN1,   GPIO0_PORTIN0}),
.GPIO0_PORTOUT ({GPIO0_PORTOUT15, GPIO0_PORTOUT14, GPIO0_PORTOUT13, GPIO0_PORTOUT12,
                 GPIO0_PORTOUT11, GPIO0_PORTOUT10, GPIO0_PORTOUT9,  GPIO0_PORTOUT8,
                 GPIO0_PORTOUT7,  GPIO0_PORTOUT6,  GPIO0_PORTOUT5,  GPIO0_PORTOUT4,
                 GPIO0_PORTOUT3,  GPIO0_PORTOUT2,  GPIO0_PORTOUT1,  GPIO0_PORTOUT0}),
.GPIO0_PORTEN  ({GPIO0_PORTEN15,  GPIO0_PORTEN14,  GPIO0_PORTEN13,  GPIO0_PORTEN12,
                 GPIO0_PORTEN11,  GPIO0_PORTEN10,  GPIO0_PORTEN9,   GPIO0_PORTEN8,
                 GPIO0_PORTEN7,   GPIO0_PORTEN6,   GPIO0_PORTEN5,   GPIO0_PORTEN4,
                 GPIO0_PORTEN3,   GPIO0_PORTEN2,   GPIO0_PORTEN1,   GPIO0_PORTEN0}),
.GPIO1_PORTIN  ({GPIO1_PORTIN15,  GPIO1_PORTIN14,  GPIO1_PORTIN13,  GPIO1_PORTIN12,
                 GPIO1_PORTIN11,  GPIO1_PORTIN10,  GPIO1_PORTIN9,   GPIO1_PORTIN8,
                 GPIO1_PORTIN7,   GPIO1_PORTIN6,   GPIO1_PORTIN5,   GPIO1_PORTIN4,
                 GPIO1_PORTIN3,   GPIO1_PORTIN2,   GPIO1_PORTIN1,   GPIO1_PORTIN0}),
.GPIO1_PORTOUT ({GPIO1_PORTOUT15, GPIO1_PORTOUT14, GPIO1_PORTOUT13, GPIO1_PORTOUT12,
                 GPIO1_PORTOUT11, GPIO1_PORTOUT10, GPIO1_PORTOUT9,  GPIO1_PORTOUT8,
                 GPIO1_PORTOUT7,  GPIO1_PORTOUT6,  GPIO1_PORTOUT5,  GPIO1_PORTOUT4,
                 GPIO1_PORTOUT3,  GPIO1_PORTOUT2,  GPIO1_PORTOUT1,  GPIO1_PORTOUT0}),
.GPIO1_PORTEN  ({GPIO1_PORTEN15,  GPIO1_PORTEN14,  GPIO1_PORTEN13,  GPIO1_PORTEN12,
                 GPIO1_PORTEN11,  GPIO1_PORTEN10,  GPIO1_PORTEN9,   GPIO1_PORTEN8,
                 GPIO1_PORTEN7,   GPIO1_PORTEN6,   GPIO1_PORTEN5,   GPIO1_PORTEN4,
                 GPIO1_PORTEN3,   GPIO1_PORTEN2,   GPIO1_PORTEN1,   GPIO1_PORTEN0}),

.S(S_BRIDGE),

.ACCEL_IRQ
);

    logic [7:0] riscv_dmem_wdata [4];
    logic [7:0] riscv_dmem_rdata [4];

    ACCEL uACCEL (
        .ACCEL_CLK              (HCLK),
        .ACCEL_RSTN             (HRESETn),
        .IRQ                    (ACCEL_IRQ),
        .S                      (S_BRIDGE),
        .cpu_pc                 (cpu_pc),
        .cpu_instruction        (cpu_instruction),
        .cpu_dmem_addr          (cpu_dmem_addr),
        .cpu_dmem_wdata         (cpu_dmem_wdata),
        .cpu_dmem_write         (cpu_dmem_write),
        .cpu_dmem_read          (cpu_dmem_read),
        .cpu_dmem_byte_write_enable (cpu_dmem_byte_write_enable),
        .cpu_dmem_rdata         (cpu_dmem_rdata)
    );

endmodule

`default_nettype wire
