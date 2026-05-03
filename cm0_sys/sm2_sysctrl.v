//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2010-2015  ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//  Version and Release Control Information:
//
//  File Revision       : $Revision: 275084 $
//  File Date           : $Date: 2014-03-27 15:09:11 +0000 (Thu, 27 Mar 2014) $
//
//  Release Information : Cortex-M0 DesignStart-r1p0-00rel0
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
// Abstract : System controller for simple Cortex-M Microcontroller system
//-----------------------------------------------------------------------------
//-------------------------------------
// Programmer's model
// -------------------------------
// 0x000 RW    MEM_CTRL
//      bit [  0]  REMAP             - default value 1'b1 -- UNUSED
// 0x004 RW    PMU_CTRL
//      bit [  0]  PMUENABLE         - default value 1'b0 -- UNUSED
// 0x008 RW    RST_CTRL
//      bit [  2]  SC_LOCKUPRESETEN  - default value 1'b0 
//      bit [  1]  SC_WDOGRESETEN    - default value 1'b0 
//      bit [  0]  SC_SYSRESETEN     - default value 1'b0 
// 0x00C RW    FORCE_INT_RSTN
//      bit [  0]  SC_FORCE_INT_RSTN - default value 1'b0
// 0x010 RW    Reset Information
//      bit [  3]  FORCE_INT_RSTN
//      bit [  2]  LOCKUPRESET
//      bit [  1]  WDOGRESETREQ
//      bit [  0]  SYSRESETREQ
// 0x014 RW    SRAM_CTRL
//      bit [3:2]  SC_SRAM_RTSEL     - default value 2'b01  
//      bit [1:0]  SC_SRAM_WTSEL     - default value 2'b01
// 0x018 RW    PAD_CTRL
//      bit [3]    SC_PAD_ST         - default value 1'b0
//      bit [2:1]  SC_PAD_DS         - default value 2'b10
//      bit [  0]  SC_PAD_SL         - default value 1'b0
// 0x014 R/Wc  Reset Information
//
//-------------------------------------
//`include "cmsdk_mcu_defs.v"
module sm2_sysctrl #(
  parameter  BE = 0            // By default use little endian

  )
  (
   // AHB Inputs
  input  wire         HCLK,      // system bus clock
  input  wire         HRESETn,   // system bus reset
  input  wire         FCLK,      // Free running clock
  input  wire         PORESETn,  // power on reset
  input  wire         HSEL,      // AHB peripheral select
  input  wire         HREADY,    // AHB ready input
  input  wire   [1:0] HTRANS,    // AHB transfer type
  input  wire   [2:0] HSIZE,     // AHB hsize
  input  wire         HWRITE,    // AHB hwrite
  input  wire  [11:0] HADDR,     // AHB address bus
  input  wire  [31:0] HWDATA,    // AHB write data bus

   // AHB Outputs
  output wire         HREADYOUT, // AHB ready output to S->M mux
  output wire         HRESP,     // AHB response
  output wire  [31:0] HRDATA,    // AHB read data bus

   // Reset information
  input  wire         SYSRESETREQ, // System reset request
  input  wire         WDOGRESETREQ,// Watchdog reset request
  input  wire         LOCKUPREQ,   // CPU locked up

   //ECO revision number
  input  wire  [3:0]  ECOREVNUM, // ECO revision number

   // System control signals
  output wire         REMAP,             // memory remap
  output wire         PMUENABLE,         // Power Management Unit enable, will be disabled in design
                                         // start version
  output wire         SC_AHB_RSTN,       // AHB Reset Signal
  output wire  [1:0]  SC_SRAM_RTSEL,       // SRAM Extra Margin Adjustment
  output wire  [1:0]  SC_SRAM_WTSEL      // SRAM Extra Margin Adjustment for Writes
  //output wire         SC_PAD_ST,         // PAD schmidt setting
  //output wire  [3:0]  SC_PAD_DS,         // PAD drive strength
  //output wire         SC_PAD_SL          // PAD slew rate control
  );

// --------------------------------------------------------------------------
// Port Definitions
// --------------------------------------------------------------------------

//Local parameter for IDs,
localparam  ARM_CMSDK_CM0_SYSCTRL_PID4        = {32'h00000004}; // 0xFD0 : PID 4
localparam  ARM_CMSDK_CM0_SYSCTRL_PID5        = {32'h00000000}; // 0xFD4 : PID 5
localparam  ARM_CMSDK_CM0_SYSCTRL_PID6        = {32'h00000000}; // 0xFD8 : PID 6
localparam  ARM_CMSDK_CM0_SYSCTRL_PID7        = {32'h00000000}; // 0xFDC : PID 7
localparam  ARM_CMSDK_CM0_SYSCTRL_PID0        = {32'h00000026}; // 0xFE0 : PID 0 part number[7:0]
localparam  ARM_CMSDK_CM0_SYSCTRL_PID1        = {32'h000000B8}; // 0xFE4 : PID 1 [7:4] jep106_id_3_0. [3:0] part number [11:8]
localparam  ARM_CMSDK_CM0_SYSCTRL_PID2        = {32'h0000001B}; // 0xFE8 : PID 2 [7:4] revision, [3] jedec_used. [2:0] jep106_id_6_4
localparam  ARM_CMSDK_CM0_SYSCTRL_PID3        = {32'h00000000}; // 0xFEC : PID 3
localparam  ARM_CMSDK_CM0_SYSCTRL_CID0        = {32'h0000000D}; // 0xFF0 : CID 0
localparam  ARM_CMSDK_CM0_SYSCTRL_CID1        = {32'h000000F0}; // 0xFF4 : CID 1 PrimeCell class
localparam  ARM_CMSDK_CM0_SYSCTRL_CID2        = {32'h00000005}; // 0xFF8 : CID 2
localparam  ARM_CMSDK_CM0_SYSCTRL_CID3        = {32'h000000B1}; // 0xFFC : CID 3
         // Note : Customer changing the design should modify
         // - jep106 value (www.jedec.org)
         // - part number (customer define)
         // - Optional revision and modification number (e.g. rXpY)

  // --------------------------------------------------------------------------
  // Internal wires
  // --------------------------------------------------------------------------

  reg    [31:0]          read_mux;
  reg    [31:0]          read_mux_le; // little endian of read mux
  reg                    reg_remap;
  wire                   reg_pmuenable;
  reg                    reg_lockupreseten;
  reg                    reg_sysreseten;
  reg                    reg_wdogreseten;
  reg                    reg_force_int_rstn;
  reg     [3:0]          reg_resetinfo;
  reg     [1:0]          reg_sramrtsel;
  reg     [1:0]          reg_sramwtsel;
  //reg                    reg_padst;
  //reg     [3:0]          reg_padds;
  //reg                    reg_padsl;
  reg     [1:0]          hrstn_reg;

  // ----------------------------------------------------------
  // Read/write control logic
  // ----------------------------------------------------------

  wire        bigendian    = (BE!=0) ? 1'b1 : 1'b0;
  wire        ahb_access   = HTRANS[1] & HSEL & HREADY;
  wire        ahb_write    = ahb_access &   HWRITE;
  wire        ahb_read     = ahb_access & (~HWRITE);
  wire  [3:0] nxt_byte_strobe;
  reg   [3:0] reg_byte_strobe;
  reg         reg_read_enable;
  reg         reg_write_enable;
  reg  [11:2] reg_addr;
  reg   [1:0] reg_hsize;
  reg  [31:0] HWDATALE; // Little endian version of HWDATA

  // Generate byte strobes to allow the GPIO registers to handle different transfer sizes
  assign nxt_byte_strobe[0] = (HSIZE[1] | ((HADDR[1]==1'b0) & HSIZE[0]) | (HADDR[1:0]==2'b00)) & ahb_access;
  assign nxt_byte_strobe[1] = (HSIZE[1] | ((HADDR[1]==1'b0) & HSIZE[0]) | (HADDR[1:0]==2'b01)) & ahb_access;
  assign nxt_byte_strobe[2] = (HSIZE[1] | ((HADDR[1]==1'b1) & HSIZE[0]) | (HADDR[1:0]==2'b10)) & ahb_access;
  assign nxt_byte_strobe[3] = (HSIZE[1] | ((HADDR[1]==1'b1) & HSIZE[0]) | (HADDR[1:0]==2'b11)) & ahb_access;

  // Data phase read write and byte lane strobe
  always @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      begin
      reg_byte_strobe <= 4'b0000;
      reg_read_enable <= 1'b0;
      reg_write_enable <= 1'b0;
      end
    else if (HREADY)
      begin
      reg_byte_strobe   <= nxt_byte_strobe;
      reg_read_enable  <= ahb_read;
      reg_write_enable <= ahb_write;
      end
  end

  // registered address, update only if selected to reduce toggling
  always @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      reg_addr <= {10{1'b0}};
    else if (ahb_access)
      reg_addr <= HADDR[11:2];
  end

  // registered hsize, update only if selected to reduce toggling
  always @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      reg_hsize <= {2{1'b0}};
    else if (ahb_access)
      reg_hsize <= HSIZE[1:0];
  end


  // Read operation
  always @(reg_addr or reg_remap or reg_pmuenable or ECOREVNUM or
  reg_lockupreseten or reg_sysreseten or reg_wdogreseten or reg_force_int_rstn or
  reg_resetinfo or reg_sramrtsel or reg_sramwtsel or reg_read_enable)
  //reg_padst or reg_padds or reg_padsl or reg_read_enable)
  begin
   case (reg_read_enable)
  1'b1:
    begin
      if (reg_addr[11:5] == 7'h00) begin
         case(reg_addr[4:2])
          3'b000: read_mux_le ={{31{1'b0}}, reg_remap} ;
          3'b001: read_mux_le ={{31{1'b0}}, reg_pmuenable} ;
          3'b010: read_mux_le ={{28{1'b0}}, reg_lockupreseten, reg_wdogreseten, reg_sysreseten} ;
          3'b011: read_mux_le ={{31{1'b0}}, reg_force_int_rstn} ;
          3'b100: read_mux_le ={{28{1'b0}}, reg_resetinfo} ;
          3'b101: read_mux_le ={{28{1'b0}}, reg_sramwtsel, reg_sramrtsel} ;
          3'b110: read_mux_le ={{32{1'b0}}} ; //, reg_padst, reg_padds, reg_padsl} ;
          3'b111: read_mux_le = {32{1'b0}}; // Reserved
          default: read_mux_le = {32{1'bx}};
         endcase
      end
      else if (reg_addr[11:6] == 6'h3F)begin
         case (reg_addr[5:2])
          4'h4:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_PID4;  //0xFD0 Peripheral ID 4
          4'h5:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_PID5;  //0xFD4 Peripheral ID 5
          4'h6:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_PID6;  //0xFD8 Peripheral ID 6
          4'h7:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_PID7;  //0xFDC Peripheral ID 7
          4'h8:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_PID0;  //0xFE0 Peripheral ID 0
          4'h9:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_PID1;  //0xFE4 Peripheral ID 1
          4'hA:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_PID2;  //0xFE8 Peripheral ID 2
          4'hB:  read_mux_le =   {ARM_CMSDK_CM0_SYSCTRL_PID3[31:8], ECOREVNUM[3:0], 4'h0}; //0xFEC Peripheral ID 3
          4'hC:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_CID0;  //0xFF0 Component ID 0
          4'hD:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_CID1;  //0xFF4 Component ID 1
          4'hE:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_CID2;  //0xFF8 Component ID 2
          4'hF:  read_mux_le =   ARM_CMSDK_CM0_SYSCTRL_CID3;  //0xFFC Component ID 3
          4'h0, 4'h1, 4'h2,4'h3: read_mux_le = {32{1'b0}};
          default: read_mux_le = {32{1'bx}};
         endcase
     end
     else begin
        read_mux_le = {32{1'b0}};
     end
    end
  1'b0:// read_enable is not active
    begin
    read_mux_le = {32{1'b0}};
    end
  default:
    read_mux_le = {32{1'bx}};
  endcase
  end

  // endian conversion
  always @(bigendian or reg_hsize or read_mux_le or HWDATA)
  begin
    if ((bigendian)&(reg_hsize==2'b10))
      begin
      read_mux = {read_mux_le[ 7: 0],read_mux_le[15: 8],
                  read_mux_le[23:16],read_mux_le[31:24]};
      HWDATALE = {HWDATA[ 7: 0],HWDATA[15: 8],HWDATA[23:16],HWDATA[ 31:24]};
      end
    else if ((bigendian)&(reg_hsize==2'b01))
      begin
      read_mux = {read_mux_le[23:16],read_mux_le[31:24],
                  read_mux_le[ 7: 0],read_mux_le[15: 8]};
      HWDATALE = {HWDATA[23:16],HWDATA[ 31:24],HWDATA[ 7: 0],HWDATA[15: 8]};
      end
    else
      begin
      read_mux = read_mux_le;
      HWDATALE = HWDATA;
      end
  end
  // ----------------------------------------------------------
  // Remap register
  // ----------------------------------------------------------
  wire      reg_remap_write;
  assign    reg_remap_write = reg_write_enable &
       (reg_addr[11:2]  == 10'h000) & reg_byte_strobe[0];

  //  registering stage
  always @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      reg_remap <= 1'b1;
    else if (reg_remap_write)
      reg_remap <= HWDATALE[0];
  end

  // ----------------------------------------------------------
  // PMUENABLE register
  // ----------------------------------------------------------

  // Power management unit not available with Cortex-M0 DesignStart.
  // PMU control is disabled
  assign    reg_pmuenable = 1'b0;

  // ----------------------------------------------------------
  // LOCKUPRESETEN register
  // ----------------------------------------------------------
  wire      reg_rstctrl_write;
  assign    reg_rstctrl_write = reg_write_enable &
       (reg_addr[11:2]  == 10'h002) & reg_byte_strobe[0];

  //  registering stage
  always @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn) begin
      reg_lockupreseten <= 1'b0;
      reg_wdogreseten   <= 1'b0;
      reg_sysreseten    <= 1'b0;
    end
    else if (reg_rstctrl_write) begin
      reg_lockupreseten <= HWDATALE[2];
      reg_wdogreseten   <= HWDATALE[1];
      reg_sysreseten    <= HWDATALE[0];
    end
  end

  // ----------------------------------------------------------
  // FORCE_INT_RSTN register
  // ----------------------------------------------------------
  wire      reg_force_int_rstn_write;
  assign    reg_force_int_rstn_write = reg_write_enable &
       (reg_addr[11:2]  == 10'h003) & reg_byte_strobe[0];

  //  registering stage
  always @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      reg_force_int_rstn <= 1'b0;
    else if (reg_force_int_rstn_write)
      reg_force_int_rstn <= HWDATALE[0];
  end

  // ----------------------------------------------------------
  // Reset information register
  // ----------------------------------------------------------

  wire      reg_resetinfo_write;
  assign    reg_resetinfo_write = reg_write_enable &
       (reg_addr[11:2]  == 10'h004) & reg_byte_strobe[0];

  // capture reset information
  wire [3:0] nxt_resetinfo;
  // Write 1 to clear
  assign    nxt_resetinfo[0] = ((~(reg_resetinfo_write & HWDATALE[0])) & reg_resetinfo[0]) | (reg_sysreseten & SYSRESETREQ);
  assign    nxt_resetinfo[1] = ((~(reg_resetinfo_write & HWDATALE[1])) & reg_resetinfo[1]) | (reg_wdogreseten & WDOGRESETREQ);
  assign    nxt_resetinfo[2] = ((~(reg_resetinfo_write & HWDATALE[2])) & reg_resetinfo[2]) | (reg_lockupreseten & LOCKUPREQ);
  assign    nxt_resetinfo[3] = ((~(reg_resetinfo_write & HWDATALE[3])) & reg_resetinfo[3]) | reg_force_int_rstn;

  // Enable flip-flop only if it should be updated to reduce power
  wire      reg_resetinfo_en;
  assign    reg_resetinfo_en = reg_resetinfo_write |
                              (reg_sysreseten & SYSRESETREQ) |
                              (reg_wdogreseten & WDOGRESETREQ) |
                              (reg_lockupreseten & LOCKUPREQ) |
                              reg_force_int_rstn;

  //  registering stage
  always @(posedge FCLK or negedge PORESETn)
  begin
    if (~PORESETn)
      reg_resetinfo <= 4'h0;
    else if (reg_resetinfo_en)
      reg_resetinfo <= nxt_resetinfo;
  end

  // ----------------------------------------------------------
  // SRAMEMA register
  // ----------------------------------------------------------
  wire      reg_sramctrl_write;
  assign    reg_sramctrl_write = reg_write_enable &
       (reg_addr[11:2]  == 10'h005) & reg_byte_strobe[0];

  //  registering stage
  always @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn) begin
      reg_sramrtsel <= 2'b01;
      reg_sramwtsel  <= 2'b01;
    end
    else if (reg_sramctrl_write) begin
      reg_sramrtsel <= HWDATALE[3:2];
      reg_sramwtsel  <= HWDATALE[2:0];
    end
  end

  // ----------------------------------------------------------
  // PAD register
  // ----------------------------------------------------------
  //wire      reg_padctrl_write;
  //assign    reg_padctrl_write = reg_write_enable &
  //     (reg_addr[11:2]  == 10'h006) & reg_byte_strobe[0];


  //  registering stage
  //always @(posedge HCLK or negedge HRESETn)
  //begin
  //  if (~HRESETn) begin
  //    reg_padst <= 1'b0;
  //    reg_padds <= 4'b0010;
  //    reg_padsl <= 1'b0;
  //  end
  //  else if (reg_padctrl_write) begin
  //    reg_padst <= HWDATALE[5]; 
  //    reg_padds <= HWDATALE[4:1];
  //    reg_padsl <= HWDATALE[0];
  //  end
  //end


  // ----------------------------------------------------------
  // Reset Generator
  // ----------------------------------------------------------
  wire [1:0] hrstn_nxt;
  wire ahb_reset_sig;
  assign ahb_reset_sig = reg_force_int_rstn |
                        (SYSRESETREQ&reg_sysreseten) |
                        (LOCKUPREQ&reg_lockupreseten) |
                        (WDOGRESETREQ&reg_wdogreseten);
  // 2-cycle delay
  assign hrstn_nxt = {hrstn_reg[0], ahb_reset_sig};
  always @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn) hrstn_reg <= 2'b00;
    else hrstn_reg <= hrstn_nxt;
  end

  // Connect to higher level
  assign REMAP             = reg_remap;
  assign PMUENABLE         = reg_pmuenable;
  assign SC_AHB_RSTN       = hrstn_reg[1];
  assign SC_SRAM_RTSEL       = reg_sramrtsel;
  assign SC_SRAM_WTSEL      = reg_sramwtsel;
  //assign SC_PAD_ST         = reg_padst;
  //assign SC_PAD_DS         = reg_padds;
  //assign SC_PAD_SL         = reg_padsl;

  assign HREADYOUT = 1'b1;
  assign HRDATA    = read_mux;
  assign HRESP     = 1'b0;

endmodule

