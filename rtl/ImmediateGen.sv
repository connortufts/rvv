module ImmediateGen(
    input logic [31:0]        instruction,
    output logic [31:0] out
);

    import Opcode_ops::*;

    logic [6:0] opcode;
    assign opcode = instruction[6:0];

    always_comb begin
        case (opcode)
            ITYPE, LOADTYPE: begin
                out = {{20{instruction[31]}}, instruction[31:20]};
            end
            STORETYPE: begin
                out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            BTYPE: begin
                out = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            JTYPE: begin
                out = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            LUTYPE: begin
                out = {instruction[31:12], 12'b0};
            end
            AUTYPE: begin
                out = {instruction[31:12], 12'b0};
            end
            default: begin
                out = 32'b0;
            end
        endcase
    end

endmodule
