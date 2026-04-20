module InstructionDecoder
(
    input  rvDefs::instruction_t    instruction,            // value of instruction to decode
    output rvDefs::xreg_addr_t      rs1,                    // rs1/vs1 field
    output rvDefs::xreg_addr_t      rs2,                    // rs2/vs2/lumop/somop field
    output rvDefs::xreg_addr_t      rd,                     // rd/vd/vs3 field
    output logic                    xaluArithmeticFlag,     // arithmetic (HI) vs logical (LO) shift flag (doubles as sub (HI) vs add (LO) flag) 
    output rvDefs::xalu_op_t        xaluOp,                 // operation to perform in XALU
    output logic                    zeroXaluPrimary,        // select x[0] instead of x[rs1] for primary input
    output logic                    pcXaluPrimary,          // select program counter instead of x[rs1] for primary input
    output logic                    immediateXaluSecondary, // select immediate instead of x[rs2] for secondary input
    output rvDefs::memory_op_size_t memoryOpSize,           // for memory operations, size of data being moved and also doubles as not a memory op signal
    output logic                    unsignedLoad,           // load operation value is sign extended into x[rd]
    output logic                    storeLoad,              // memory operation is a store (HI) or a load (LO)
    output rvDefs::branch_op_t      branchOp,               // for branch operations, comparison to look at and also doubles as not a branch op signal
    output logic                    branchNegate,           // if the branch test should be negated
    output logic                    jump,                   // signals jump operation
    output rvDefs::write_src_t      writeSource,            // where to take writes from to set x[rd]

    output rvDefs::valu_op_t        valuOp,                 // operation to perform in VALU
    output rvDefs::vec_mode_t       vecMode,                // vector mode
    output logic                    isVectorOp,             // is a vector operation
    output logic                    isVectorMemOp           // 
    output logic                    vm,                     // vector masking (0 = mask enabled, 1 = mask disabled)
    output logic [2 : 0]            nf,                     // specifies the number of fields in each segment, for segment load/stores
    output logic [2 : 0]            width,                  // specifies size of memory elements, and distinguishes from FP scalar
    output logic                    mew,                    // extended memory addressing mode
    output logic [1 : 0]            mop                     // specifies memory addressing mode
);

    // notes for XALU:
    // shamt field of SLLI, SRLI, SRAI = x[rs2]
    // for store and load, x[rs1] is ALWAYS the base that is added to the immediate value

    rvDefs::opcode_t opcode;
    logic [2 : 0] funct3;
    logic funct7_5;
    logic [6 : 0] funct7;
    logic [5 : 0] funct6;

    assign opcode =   rvDefs::opcode_t'(instruction[6 : 0]);
    assign funct3 =   instruction[14 : 12];
    assign funct7 =   instruction[31 : 25];
    assign funct7_5 = instruction[30];
    assign funct6 =   instruction[31 : 26];
    assign rs1 =      rvDefs::xreg_addr_t'(instruction[19 : 15]);
    assign rs2 =      rvDefs::xreg_addr_t'(instruction[24 : 20]);
    assign rd =       rvDefs::xreg_addr_t'(instruction[11 : 7]);
    assign zeroXaluPrimary = (opcode == rvDefs::OPCODE_LUI); // so that we can just access the immediate value from the XALU result
    assign pcXaluPrimary = ( // to mux in program counter value
        (opcode == rvDefs::OPCODE_AUIPC) ||
        (opcode == rvDefs::OPCODE_JAL) ||
        (opcode == rvDefs::OPCODE_BRANCH)
    );
    assign immediateXaluSecondary = ( // all of these opcodes need something done with an immediate value
        (opcode == rvDefs::OPCODE_LUI) ||
        (opcode == rvDefs::OPCODE_AUIPC) ||
        (opcode == rvDefs::OPCODE_JAL) ||
        (opcode == rvDefs::OPCODE_JALR) ||
        (opcode == rvDefs::OPCODE_BRANCH) ||
        (opcode == rvDefs::OPCODE_LOAD) ||
        (opcode == rvDefs::OPCODE_STORE) ||
        (opcode == rvDefs::OPCODE_OP_IMM)
    );
    assign xaluArithmeticFlag = (opcode == rvDefs::OPCODE_OP && funct7_5); // when to use subtraction instead of addition and arithmetic instead of logical shift
    assign unsignedLoad = funct3[2]; // when doing a load, this bit says if it is unsigned or not
    assign storeLoad = (opcode == rvDefs::OPCODE_STORE); // if a memory op is a store vs a load
    assign branchOp = rvDefs::branch_op_t'(opcode == rvDefs::OPCODE_BRANCH ? funct3[2 : 1] : rvDefs::BRANCH_OP_NONE); // what to check for
    assign branchNegate = funct3[0]; // when branching, this bit says if the condition is to be reversed/negated
    assign jump = ( // if the program counter should unconditionally load an offset because of a jump
        (opcode == rvDefs::OPCODE_JAL) ||
        (opcode == rvDefs::OPCODE_JALR)
    );
    assign memoryOpSize = (
        ((opcode == rvDefs::OPCODE_LOAD) || (opcode == rvDefs::OPCODE_STORE)) ?
            (rvDefs::memory_op_size_t'(funct3[1 : 0])) :
            (rvDefs::MEMORY_OP_SIZE_NONE)
    );
    assign isVectorOp = (opcode == rvDefs::OPCODE_OP_V);
    assign isVectorMemOp = isVectorMemOp && (instruction[27 : 26] != 2'b00);

    assign vm =       isVectorOp ? instruction[25] : 1'b0;
    assign mop =      isVectorOp ? instruction[27 : 26] : 2'b00;
    assign mew =      isVectorOp ? instruction[28] : 1'b0;
    assign nf =       isVectorOp ? instruction[31 : 29] : 3'b000;
    assign width =    isVectorOp ? instruction[14 : 12] : 3'b000;
    assign vecMode = isVectorOp ? rvDefs::vec_mode_t'(funct3) : rvDefs::VEC_MODE_IVV;

    always_comb begin
        case (opcode)
            rvDefs::OPCODE_OP_V:
                writeSource = rvDefs::WRITE_SRC_VEC;
            rvDefs::OPCODE_LUI,
            rvDefs::OPCODE_AUIPC,
            rvDefs::OPCODE_OP_IMM,
            rvDefs::OPCODE_OP:
                writeSource = rvDefs::WRITE_SRC_ALU;
            rvDefs::OPCODE_JAL,
            rvDefs::OPCODE_JALR:
                writeSource = rvDefs::WRITE_SRC_PC;
            rvDefs::OPCODE_LOAD:
                writeSource = rvDefs::WRITE_SRC_MEM;
            default:
                writeSource = rvDefs::WRITE_SRC_NONE;
        endcase
    end

    always_comb begin
        xaluOp = rvDefs::XALU_OP_SUM;
        valuOp = rvDefs::VALU_OP_NONE;
        case (opcode)
            rvDefs::OPCODE_OP_IMM,
            rvDefs::OPCODE_OP:
                xaluOp = rvDefs::xalu_op_t'(funct3);
            rvDefs::OPCODE_OP_V:
                valuOp = rvDefs::valu_op_t'(funct6);
            default: ;
        endcase
    end

endmodule
