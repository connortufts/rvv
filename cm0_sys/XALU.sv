module XALU
(
    input  rvDefs::word_t    inputPrimary,   // first input, either value of PC, x[0], or x[rs1]
    input  rvDefs::word_t    inputSecondary, // second input, either value of x[rs2] or immediate
    input  rvDefs::xalu_op_t operation,      // the operation to output
    input  logic             arithmeticFlag, // flag for arithmetic shifts, also doubles as subtract flag
    output rvDefs::word_t    result          // result of operation on inputs
);

    logic [4 : 0] shamt;
    assign shamt = inputSecondary[4 : 0];

    always_comb begin
        case (operation)
            rvDefs::XALU_OP_SUM:
                result = arithmeticFlag ? (inputPrimary - inputSecondary) : (inputPrimary + inputSecondary);
            rvDefs::XALU_OP_SLL:
                result = inputPrimary << shamt;
            rvDefs::XALU_OP_SLT:
                result = {31'b0, ($signed(inputPrimary) < $signed(inputSecondary))};
            rvDefs::XALU_OP_SLTU:
                result = {31'b0, (inputPrimary < inputSecondary)};
            rvDefs::XALU_OP_XOR:
                result = inputPrimary ^ inputSecondary;
            rvDefs::XALU_OP_SR:
                begin
                    if (arithmeticFlag)
                        result = $signed(inputPrimary) >>> shamt;
                    else
                        result = inputPrimary >>> shamt;
                end
            rvDefs::XALU_OP_OR:
                result = inputPrimary | inputSecondary;
            rvDefs::XALU_OP_AND:
                result = inputPrimary & inputSecondary;
        endcase
    end

endmodule

