// ALU
// RV32IM
// page 587

module ALU(
    input logic [31:0] a, //rs1
    input logic [31:0] b, //rs2 or immediate
    input logic [4:0] operation,
    output logic [31:0] result,
    output logic zero //flag for 0 had it from ee25
);

    // RV32I Base Operations
    localparam ADD  = 5'b00000;
    localparam SUB  = 5'b00001;
    localparam SLL  = 5'b00010; //shift left
    localparam SLT  = 5'b00011; //set less than
    localparam SLTU = 5'b00100; // same but unsigned
    localparam XOR  = 5'b00101;
    localparam SRL  = 5'b00110; //shift right
    localparam SRA  = 5'b00111; // shift right but fill w/ sign bit
    localparam OR   = 5'b01000;
    localparam AND  = 5'b01001;

    // RV32M Multiply/Divide Operations
    // mulw dont exist cus we in 32 bit
    // page 77
    localparam MUL    = 5'b01010;
    localparam MULH   = 5'b01011;
    localparam MULHSU = 5'b01100;
    localparam MULHU  = 5'b01101;
    localparam DIV    = 5'b01110;
    localparam DIVU   = 5'b01111;
    localparam REM    = 5'b10000;
    localparam REMU   = 5'b10001;

    // shift to come in from mux in b
    logic [4:0] shamt;
    assign shamt = b[4:0];
    
    // Multiplication variants
    
    // 64 bit multiplication results
    logic signed [63:0] mul_ss; // signed x signed
    /* verilator lint_off UNUSED */
    // needed to add this cus verilator was tweaking
    logic [63:0] mul_uu; // unsigned x unsigned
    logic signed [63:0] mul_su;    // signed x unsigned
    /* verilator lint_on UNUSED */
    assign mul_ss = $signed(a) * $signed(b);
    assign mul_uu = $unsigned(a) * $unsigned(b);
    assign mul_su = $signed(a) * $unsigned(b);
    
    // Division special cases
    logic div_by_zero;
    logic signed_overflow;
    
    assign div_by_zero = (b == 32'd0);
    // cant get biggest negative number in positive form
    assign signed_overflow = (a == 32'h80000000) && (b == 32'hFFFFFFFF);

    always_comb begin
        case (operation)
            ADD: result = a+b;
            SUB: result = a-b;
            SLL: result = a<< shamt;
            SLT: begin
                if ($signed(a) < $signed(b))
                    result = 32'd1;
                else
                    result = 32'd0;
            end
            SLTU: begin
                if (a < b)
                    result = 32'd1;
                else
                    result = 32'd0;
            end
            XOR: result = a^b;
            SRL: result = a>> shamt;
            SRA: result = $signed(a) >>> shamt;
            OR: result = a|b;
            AND: result = a&b;
            // m stuff
            MUL: result = mul_ss[31:0]; //lower 32
            MULH: result = mul_ss[63:32]; //high 32 sxs
            MULHSU: result = mul_su[63:32]; // high 32 sxu
            MULHU: result = mul_uu[63:32]; // high 32 uxu

            // division stuff
            DIV: begin
                if (div_by_zero)
                    result = 32'hFFFFFFFF; // fill w 1
                else if (signed_overflow)
                    result = 32'h80000000; //return biggest neg
                else
                    result = $signed(a)/$signed(b);
            end
            DIVU: begin
                if (div_by_zero)
                    result = 32'hFFFFFFFF; // fill w 1
                else
                    result = a/b;
            end
            REM: begin
                if (div_by_zero)
                    result = a; // return a
                else if (signed_overflow)
                    result = 32'd0;
                else
                    result = $signed(a) % $signed(b);
            end
            REMU: begin
                if (div_by_zero)
                    result = a; // return a
                else
                    result = a%b;
            end
            default: result = 32'd0;
        endcase
    end
    assign zero = (result==32'd0);
endmodule

