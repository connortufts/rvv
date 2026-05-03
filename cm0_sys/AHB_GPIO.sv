// AHB_GPIO.sv - Systemverilog wrapper for CMSDK GPIO peripheral
// PNW 12 2015


module AHB_GPIO (
input logic HCLK, HRESETn,
ahb_s_intf.source S,

input  logic [15:0] PORTIN,   
output logic [15:0] PORTOUT,  
output logic [15:0] PORTEN,   
output logic [15:0] PORTFUNC, 
output logic [15:0] GPIOINT,  
output logic        COMBINT  
);


// GPIO is driven from the AHB
cmsdk_ahb_gpio #(
  .ALTERNATE_FUNC_MASK     (16'h0000), // No pin muxing
  .ALTERNATE_FUNC_DEFAULT  (16'h0000), // All pins default to GPIO
  .BE                      (1'b0)
  )
  u_ahb_gpio_0  (
 // AHB Inputs
  .HCLK         (HCLK),
  .HRESETn      (HRESETn),
  .FCLK         (HCLK),           // I think this is just a free-running version of HCLK
  .HSEL         (S.HSEL),
  .HREADY       (S.HREADY),
  .HTRANS       (S.HTRANS),
  .HSIZE        (S.HSIZE),
  .HWRITE       (S.HWRITE),
  .HADDR        (S.HADDR[11:0]),
  .HWDATA       (S.HWDATA),
 // AHB Outputs
  .HREADYOUT    (S.HREADYOUT),
  .HRESP        (S.HRESP),
  .HRDATA       (S.HRDATA),

  .ECOREVNUM    (4'h0),             // Engineering-change-order revision bits

  .PORTIN       (PORTIN[15:0]),            // GPIO Interface inputs
  .PORTOUT      (PORTOUT[15:0]),           // GPIO Interface outputs
  .PORTEN       (PORTEN[15:0]),
  .PORTFUNC     (PORTFUNC[15:0]),       // Alternate function control

  .GPIOINT      (GPIOINT[15:0]),  // Interrupt outputs
  .COMBINT      (COMBINT)
);


endmodule
