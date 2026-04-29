import rvDefs::*;

module XALU
(
    input  word_t    inputPrimary,   // first input, either value of PC, x[0], or x[rs1]
    input  word_t    inputSecondary, // second input, either value of x[rs2] or immediate
    input  xalu_op_t operation,      // the operation to output
    input  logic             arithmeticFlag, // flag for arithmetic shifts, also doubles as subtract flag
    output word_t    result          // result of operation on inputs
);

    logic [4 : 0] shamt;
    assign shamt = inputSecondary[4 : 0];

    always_comb begin
        result = '0;
        case (operation)
            XALU_OP_SUM:
                result = arithmeticFlag ? (inputPrimary - inputSecondary) : (inputPrimary + inputSecondary);
            XALU_OP_SLL:
                result = inputPrimary << shamt;
            XALU_OP_SLT:
                result = {31'b0, ($signed(inputPrimary) < $signed(inputSecondary))};
            XALU_OP_SLTU:
                result = {31'b0, (inputPrimary < inputSecondary)};
            XALU_OP_XOR:
                result = inputPrimary ^ inputSecondary;
            XALU_OP_SR:
                begin
                    if (arithmeticFlag)
                        result = $signed(inputPrimary) >>> shamt;
                    else
                        result = inputPrimary >>> shamt;
                end
            XALU_OP_OR:
                result = inputPrimary | inputSecondary;
            XALU_OP_AND:
                result = inputPrimary & inputSecondary;
            default:
                result = '0;
        endcase
    end

endmodule
