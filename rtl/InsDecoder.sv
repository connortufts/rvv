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

    // ignoring FENCE, ECALL, EBREAK right now
    // todo (maybe): specify type of comparison

    // RISC V ISA pg 25 and 585
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode   = instr[6:0];
    assign funct3   = instr[14:12];
    assign funct7   = instr[31:25];

    // From alu.sv
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
                    10'b0000000000: alu_op = ADD;
                    10'b0100000000: alu_op = SUB;
                    10'b0000000001: alu_op = SLL;
                    10'b0000000010: alu_op = SLT;
                    10'b0000000011: alu_op = SLTU;
                    10'b0000000100: alu_op = XOR;
                    10'b0000000101: alu_op = SRL;
                    10'b0100000101: alu_op = SRA;
                    10'b0000000110: alu_op = OR;
                    10'b0000000111: alu_op = AND;

                    // --- RV32M multiplication instructions ---
                    10'b0000001000: alu_op = MUL;
                    10'b0000001001: alu_op = MULH;
                    10'b0000001010: alu_op = MULHSU;
                    10'b0000001011: alu_op = MULHU;

                    // --- RV32M division / remainder ---
                    10'b0000001100: alu_op = DIV;
                    10'b0000001101: alu_op = DIVU;
                    10'b0000001110: alu_op = REM;
                    10'b0000001111: alu_op = REMU;

                    default:        alu_op = 5'bxxxxx;
                endcase
            end
            ITYPE: begin
                reg_write   = 1;
                alu_src     = 1; // second operand = immediate value
                case(funct3)
                    3'b000: alu_op = ADD;   // SUB
                    3'b010: alu_op = SLT;
                    3'b011: alu_op = SLTU;
                    3'b100: alu_op = XOR;
                    3'b110: alu_op = OR;
                    3'b111: alu_op = AND;
                    default: alu_op = 5'bxxxxx;
                endcase
            end
            LOADTYPE: begin
                reg_write   = 1;
                mem_read    = 1;
                alu_src     = 1;
                mem_to_reg  = 1;
                alu_op      = ADD;  // for address
            end
            STORETYPE: begin
                mem_write   = 1;
                alu_src     = 1;
                alu_op      = ADD;  // for address
            end
            BTYPE: begin
                branch      = 1;
                alu_src     = 0;
                alu_op      = SUB;  // for comparison
            end
            JTYPE: begin
                jump        = 1;
                reg_write   = 1;
            end
            default: ;
        endcase
    end

endmodule
