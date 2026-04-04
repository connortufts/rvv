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

    import ALU_ops::*;

    // shift to come in from mux in b
    logic [4:0] shamt;
    assign shamt = b[4:0];
    
    // Multiplication variants
    
    // 64 bit multiplication results
    logic signed [63:0] mul_ss; // signed x signed
    // needed to add this cus verilator was tweaking
    logic [63:0] mul_uu; // unsigned x unsigned
    logic signed [63:0] mul_su;    // signed x unsigned
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
            ALU_ADD: result = a+b;
            ALU_SUB: result = a-b;
            ALU_SLL: result = a<< shamt;
            ALU_SLT: begin
                if ($signed(a) < $signed(b))
                    result = 32'd1;
                else
                    result = 32'd0;
            end
            ALU_SLTU: begin
                if (a < b)
                    result = 32'd1;
                else
                    result = 32'd0;
            end
            ALU_XOR: result = a^b;
            ALU_SRL: result = a>> shamt;
            ALU_SRA: result = $signed(a) >>> shamt;
            ALU_OR: result = a|b;
            ALU_AND: result = a&b;
            // m stuff
            ALU_MUL: result = mul_ss[31:0]; //lower 32
            ALU_MULH: result = mul_ss[63:32]; //high 32 sxs
            ALU_MULHSU: result = mul_su[63:32]; // high 32 sxu
            ALU_MULHU: result = mul_uu[63:32]; // high 32 uxu

            // division stuff
            ALU_DIV: begin
                if (div_by_zero)
                    result = 32'hFFFFFFFF; // fill w 1
                else if (signed_overflow)
                    result = 32'h80000000; //return biggest neg
                else
                    result = $signed(a)/$signed(b);
            end
            ALU_DIVU: begin
                if (div_by_zero)
                    result = 32'hFFFFFFFF; // fill w 1
                else
                    result = a/b;
            end
            ALU_REM: begin
                if (div_by_zero)
                    result = a; // return a
                else if (signed_overflow)
                    result = 32'd0;
                else
                    result = $signed(a) % $signed(b);
            end
            ALU_REMU: begin
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

