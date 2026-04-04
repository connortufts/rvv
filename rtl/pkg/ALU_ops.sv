package ALU_ops;

// RV32I Base Operations
localparam ALU_ADD  = 5'b00000;
localparam ALU_SUB  = 5'b00001;
localparam ALU_SLL  = 5'b00010; //shift left
localparam ALU_SLT  = 5'b00011; //set less than
localparam ALU_SLTU = 5'b00100; // same but unsigned
localparam ALU_XOR  = 5'b00101;
localparam ALU_SRL  = 5'b00110; //shift right
localparam ALU_SRA  = 5'b00111; // shift right but fill w/ sign bit
localparam ALU_OR   = 5'b01000;
localparam ALU_AND  = 5'b01001;

// RV32M Multiply/Divide Operations
// mulw dont exist cus we in 32 bit
// page 77
localparam ALU_MUL    = 5'b01010;
localparam ALU_MULH   = 5'b01011;
localparam ALU_MULHSU = 5'b01100;
localparam ALU_MULHU  = 5'b01101;
localparam ALU_DIV    = 5'b01110;
localparam ALU_DIVU   = 5'b01111;
localparam ALU_REM    = 5'b10000;
localparam ALU_REMU   = 5'b10001;

endpackage
