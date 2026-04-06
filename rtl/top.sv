module top
(
    input  logic sysclk,
    input  logic sysreset,
    output rvDefs::mem_addr_t instructionAddr,
    input  rvDefs::instruction_t instruction,
    output rvDefs::word_t dmemview,
    input  rvDefs::mem_addr_t viewaddr
);

    rvDefs::word_t dmem [0 : 15];
    assign dmemview = dmem[viewaddr];
    always_ff @(posedge sysclk) begin
        if ((memoryOpSize != rvDefs::MEMORY_OP_SIZE_NONE) & storeLoad) begin
            dmem[aluResult] <= (read2Data & memoryMask);
        end
    end

    ProgramCounter programCounter(
        .clk(sysclk),
        .resetN(sysreset),
        .enable(1'b1),
        .loadOffset(jump | branchPass),
        .addrOffset(jump ? aluResult : immediate),
        .addrOut(instructionAddr)
    );

    logic branchPass;
    always_comb begin
        case (branchOp)
            rvDefs::BRANCH_OP_EQ:
                branchPass = ((aluResult == rvDefs::word_t'(0)) ^ branchNegate);
            rvDefs::BRANCH_OP_LT, 
            rvDefs::BRANCH_OP_LTU:
                branchPass = ((aluResult == rvDefs::word_t'(1)) ^ branchNegate);
            default: branchPass = 0;
        endcase
    end

    rvDefs::word_t immediate;
    ImmediateGenerator immedaiteGenerator(
        .instruction(instruction),
        .immediate(immediate)
    );

    rvDefs::xreg_addr_t rs1;
    rvDefs::xreg_addr_t rs2;
    rvDefs::xreg_addr_t rd;
    logic xaluArithmeticFlag;
    rvDefs::xalu_op_t xaluOp;
    logic zeroXaluPrimary;
    logic pcXaluPrimary;
    logic immediateXaluSecondary;
    rvDefs::memory_op_size_t memoryOpSize;
    logic unsignedLoad;
    logic storeLoad;
    rvDefs::branch_op_t branchOp;
    logic branchNegate;
    logic jump;
    rvDefs::write_src_t writeSource;

    InstructionDecoder instructionDecoder(
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .xaluArithmeticFlag(xaluArithmeticFlag),
        .xaluOp(xaluOp),
        .zeroXaluPrimary(zeroXaluPrimary),
        .pcXaluPrimary(pcXaluPrimary),
        .immediateXaluSecondary(immediateXaluSecondary),
        .memoryOpSize(memoryOpSize),
        .unsignedLoad(unsignedLoad),
        .storeLoad(storeLoad),
        .branchOp(branchOp),
        .branchNegate(branchNegate),
        .jump(jump),
        .writeSource(writeSource)
    );

    rvDefs::word_t memoryMask;
    always_comb begin
        case (memoryOpSize)
            rvDefs::MEMORY_OP_SIZE_BYTE:
                memoryMask = rvDefs::word_t'(8'hFF);
            rvDefs::MEMORY_OP_SIZE_HALF:
                memoryMask = rvDefs::word_t'(16'hFFFF);
            rvDefs::MEMORY_OP_SIZE_WORD:
                memoryMask = rvDefs::word_t'(32'hFFFFFFFF);
            rvDefs::MEMORY_OP_SIZE_NONE:
                memoryMask = rvDefs::word_t'(0);
        endcase
    end

    rvDefs::xreg_t read1Data;
    rvDefs::xreg_t read2Data;
    rvDefs::word_t writeData;
    always_comb begin
        case (writeSource)
            rvDefs::WRITE_SRC_ALU:
                writeData = aluResult;
            rvDefs::WRITE_SRC_MEM:
                writeData = dmem[aluResult] & memoryMask;
            rvDefs::WRITE_SRC_PC:
                writeData = instructionAddr + rvDefs::word_t'(3'd4);
            default:
                writeData = 0;
        endcase
    end
    XRegisterFile xRegisterFile(
        .clk(sysclk),
        .writeEnable(writeSource != rvDefs::WRITE_SRC_NONE),
        .read1Reg(zeroXaluPrimary ? rvDefs::xreg_addr_t'(0) : rs1),
        .read2Reg(rs2),
        .writeReg(rd),
        .read1Data(read1Data),
        .read2Data(read2Data),
        .writeData(writeData)
    );
    
    rvDefs::word_t aluResult;
    XALU xAlu(
        .inputPrimary(pcXaluPrimary ? instructionAddr : read1Data),
        .inputSecondary(immediateXaluSecondary ? immediate : read2Data),
        .operation(xaluOp),
        .arithmeticFlag(xaluArithmeticFlag),
        .result(aluResult)
    );

endmodule
