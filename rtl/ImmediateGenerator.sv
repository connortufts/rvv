module ImmediateGenerator
(
    input  rvDefs::instruction_t instruction, // the instruction to generate from
    output rvDefs::word_t        immediate    // the extracted immediate value
);

    rvDefs::opcode_t opcode;
    assign opcode = rvDefs::opcode_t'(instruction[6 : 0]);

    always_comb begin
        case (opcode)
            rvDefs::OPCODE_LUI,
            rvDefs::OPCODE_AUIPC:
                immediate = {instruction[31:12], 12'b0};
            rvDefs::OPCODE_JAL:
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            rvDefs::OPCODE_JALR,
            rvDefs::OPCODE_LOAD,
            rvDefs::OPCODE_OP_IMM:
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            rvDefs::OPCODE_BRANCH:
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            rvDefs::OPCODE_STORE:
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            default:
                immediate = rvDefs::word_t'(0);
        endcase
    end

endmodule
