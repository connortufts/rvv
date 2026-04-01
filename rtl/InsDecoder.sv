module InsDecoder(
    /* verilator lint_off UNUSEDSIGNAL */
    input [31:0]        instr,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic [4:0]  alu_op,
    output logic        reg_write,
    output logic        mem_read,
    output logic        mem_write,
    output logic        branch,
    output logic        jump,
    output logic        alu_src,
    output logic        mem_to_reg
);

    import ALU_ops::*;

    // ignoring FENCE, ECALL, EBREAK right now
    // todo (maybe): specify type of comparison

    // RISC V ISA pg 25 and 585
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode   = instr[6:0];
    assign funct3   = instr[14:12];
    assign funct7   = instr[31:25];
    
    localparam RTYPE = 7'b0110011;
    localparam ITYPE = 7'b0010011;
    localparam LOADTYPE = 7'b0000011;
    localparam STORETYPE = 7'b0100011;
    localparam BTYPE = 7'b1100011;
    localparam JTYPE = 7'b1101111;

    always_comb begin
        alu_op      = 5'b00000;
        reg_write   = 0;
        mem_read    = 0;
        mem_write   = 0;
        branch      = 0;
        jump        = 0;
        alu_src     = 0;
        mem_to_reg  = 0;

        case (opcode)
            RTYPE: begin
                reg_write   = 1;
                alu_src     = 0;    // second operand = register
                case({funct7, funct3})
                    10'b0000000000: alu_op = ALU_ADD;
                    10'b0100000000: alu_op = ALU_SUB;
                    10'b0000000001: alu_op = ALU_SLL;
                    10'b0000000010: alu_op = ALU_SLT;
                    10'b0000000011: alu_op = ALU_SLTU;
                    10'b0000000100: alu_op = ALU_XOR;
                    10'b0000000101: alu_op = ALU_SRL;
                    10'b0100000101: alu_op = ALU_SRA;
                    10'b0000000110: alu_op = ALU_OR;
                    10'b0000000111: alu_op = ALU_AND;

                    // --- RV32M multiplication instructions ---
                    10'b0000001000: alu_op = ALU_MUL;
                    10'b0000001001: alu_op = ALU_MULH;
                    10'b0000001010: alu_op = ALU_MULHSU;
                    10'b0000001011: alu_op = ALU_MULHU;

                    // --- RV32M division / remainder ---
                    10'b0000001100: alu_op = ALU_DIV;
                    10'b0000001101: alu_op = ALU_DIVU;
                    10'b0000001110: alu_op = ALU_REM;
                    10'b0000001111: alu_op = ALU_REMU;

                    default:        alu_op = 5'bxxxxx;
                endcase
            end
            ITYPE: begin
                reg_write   = 1;
                alu_src     = 1; // second operand = immediate value
                case(funct3)
                    3'b000: alu_op = ALU_ADD;   // SUB
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: alu_op = 5'bxxxxx;
                endcase
            end
            LOADTYPE: begin
                reg_write   = 1;
                mem_read    = 1;
                alu_src     = 1;
                mem_to_reg  = 1;
                alu_op      = ALU_ADD;  // for address
            end
            STORETYPE: begin
                mem_write   = 1;
                alu_src     = 1;
                alu_op      = ALU_ADD;  // for address
            end
            BTYPE: begin
                branch      = 1;
                alu_src     = 0;
                alu_op      = ALU_SUB;  // for comparison
            end
            JTYPE: begin
                jump        = 1;
                reg_write   = 1;
            end
            default: ;
        endcase
    end

endmodule
