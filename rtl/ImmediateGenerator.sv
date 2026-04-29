import rvDefs::*;

module ImmediateGenerator
(
    input  instruction_t instruction, // the instruction to generate from
    output word_t        immediate    // the extracted immediate value
);

    opcode_t opcode;
    assign opcode = opcode_t'(instruction[6 : 0]);

    always_comb begin
        case (opcode)
            OPCODE_LUI,
            OPCODE_AUIPC:
                immediate = {instruction[31:12], 12'b0};
            OPCODE_JAL:
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            OPCODE_JALR,
            OPCODE_LOAD,
            OPCODE_OP_IMM:
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            OPCODE_BRANCH:
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            OPCODE_STORE:
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            default:
                immediate = word_t'(0);
        endcase
    end

endmodule
