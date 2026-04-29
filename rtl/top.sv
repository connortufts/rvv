import rvDefs::*;

module top
(
    input  logic CLK,
    input  logic RSTN,
    output mem_addr_t instructionAddr,
    input  instruction_t instruction,
    output word_t dmemview,
    input  mem_addr_t viewaddr
);

    xreg_addr_t rs1;
    xreg_addr_t rs2;
    xreg_addr_t rd;
    logic xaluArithmeticFlag;
    xalu_op_t xaluOp;
    logic zeroXaluPrimary;
    logic pcXaluPrimary;
    logic immediateXaluSecondary;
    memory_op_size_t memoryOpSize;
    logic unsignedLoad;
    logic storeLoad;
    branch_op_t branchOp;
    logic branchNegate;
    logic jump;
    write_src_t writeSource;

    logic branchPass;
    word_t immediate;
    word_t memoryMask;
    xreg_t read1Data;
    xreg_t read2Data;
    word_t writeData;
    word_t aluResult;

    word_t dmem [0 : 15];
    assign dmemview = dmem[viewaddr[3:0]];
    always_ff @(posedge CLK) begin
        if ((memoryOpSize != MEMORY_OP_SIZE_NONE) && storeLoad) begin
            dmem[aluResult[3:0]] <= (read2Data & memoryMask);
        end
    end

    ProgramCounter programCounter(
        .clk(CLK),
        .resetN(RSTN),
        .enable(1'b1),
        .load(jump | branchPass),
        .addrLoad(aluResult),
        .addrOut(instructionAddr)
    );

    always_comb begin
        case (branchOp)
            BRANCH_OP_EQ:
                branchPass = ((read1Data == read2Data) ^ branchNegate);
            BRANCH_OP_LT:
                branchPass = (($signed(read1Data) < $signed(read2Data)) ^ branchNegate);
            BRANCH_OP_LTU:
                branchPass = ((read1Data < read2Data) ^ branchNegate);
            default: branchPass = 0;
        endcase
    end

    ImmediateGenerator immediateGenerator(
        .instruction(instruction),
        .immediate(immediate)
    );

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

    always_comb begin
        memoryMask = '0;
        case (memoryOpSize)
            MEMORY_OP_SIZE_BYTE:
                memoryMask = word_t'(8'hFF);
            MEMORY_OP_SIZE_HALF:
                memoryMask = word_t'(16'hFFFF);
            MEMORY_OP_SIZE_WORD:
                memoryMask = word_t'(32'hFFFFFFFF);
            MEMORY_OP_SIZE_NONE:
                memoryMask = word_t'(0);
        endcase
    end

    always_comb begin
        writeData = '0;
        case (writeSource)
            WRITE_SRC_ALU:
                writeData = aluResult;
            WRITE_SRC_MEM:
                writeData = dmem[aluResult[3:0]] & memoryMask;
            WRITE_SRC_PC:
                writeData = instructionAddr + word_t'(3'd4);
            default:
                writeData = 0;
        endcase
    end
    XRegisterFile xRegisterFile(
        .clk(CLK),
        .writeEnable(writeSource != WRITE_SRC_NONE),
        .read1Reg(zeroXaluPrimary ? xreg_addr_t'(0) : rs1),
        .read2Reg(rs2),
        .writeReg(rd),
        .read1Data(read1Data),
        .read2Data(read2Data),
        .writeData(writeData)
    );
    
    XALU xAlu(
        .inputPrimary(pcXaluPrimary ? instructionAddr : read1Data),
        .inputSecondary(immediateXaluSecondary ? immediate : read2Data),
        .operation(xaluOp),
        .arithmeticFlag(xaluArithmeticFlag),
        .result(aluResult)
    );

endmodule
