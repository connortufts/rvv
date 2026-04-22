// CPU.sv
// modified by Devon Kumar on 4/21/26

module CPU
(
    input  logic sysclk,
    input  logic sysreset,
    input  logic cpu_enable,
    output rvDefs::mem_addr_t instructionAddr,
    input  rvDefs::instruction_t instruction,
    output logic [31:0] dmem_addr,
    output logic [7:0] dmem_wdata [4],
    output logic dmem_write,
    output logic dmem_read,
    output logic [3:0] dmem_byte_write_enable,
    input  logic [7:0] dmem_rdata [4]
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
    logic mret;
    logic ecall;
    logic ebreak;

    rvDefs::word_t immediate;
    rvDefs::xreg_t read1Data;
    rvDefs::xreg_t read2Data;
    rvDefs::word_t writeData;
    rvDefs::word_t aluResult;
    rvDefs::word_t memoryMask;
    logic [31:0] dmem_rdata_word;
    logic branchPass;

    logic [31:0] csrReadData;
    logic csrTrapTaken;
    logic [31:0] csrTrapPC;
    logic csrInterruptTaken;
    logic [31:0] mstatus;
    logic [31:0] mie;
    logic [31:0] mip;
    logic [31:0] mtvec;
    logic [31:0] mepc;
    logic [31:0] mcause;

    logic exception;
    logic [31:0] exceptionCode;
    logic [31:0] trapValue;
    logic pcLoad;
    logic [31:0] pcNext;

    assign dmem_addr = aluResult;
    assign dmem_write = (memoryOpSize != rvDefs::MEMORY_OP_SIZE_NONE) & storeLoad;
    assign dmem_read  = (memoryOpSize != rvDefs::MEMORY_OP_SIZE_NONE) & ~storeLoad;

    assign dmem_wdata[0] = read2Data[7:0];
    assign dmem_wdata[1] = read2Data[15:8];
    assign dmem_wdata[2] = read2Data[23:16];
    assign dmem_wdata[3] = read2Data[31:24];

    always_comb begin
        case (memoryOpSize)
            rvDefs::MEMORY_OP_SIZE_BYTE: dmem_byte_write_enable = 4'b0001;
            rvDefs::MEMORY_OP_SIZE_HALF: dmem_byte_write_enable = 4'b0011;
            rvDefs::MEMORY_OP_SIZE_WORD: dmem_byte_write_enable = 4'b1111;
            default:                     dmem_byte_write_enable = 4'b0000;
        endcase
    end

    always_comb begin
        case (memoryOpSize)
            rvDefs::MEMORY_OP_SIZE_BYTE:
                dmem_rdata_word = unsignedLoad ? {24'b0, dmem_rdata[0]} : {{24{dmem_rdata[0][7]}}, dmem_rdata[0]};
            rvDefs::MEMORY_OP_SIZE_HALF:
                dmem_rdata_word = unsignedLoad ? {16'b0, dmem_rdata[1], dmem_rdata[0]} : {{16{dmem_rdata[1][7]}}, dmem_rdata[1], dmem_rdata[0]};
            default:
                dmem_rdata_word = {dmem_rdata[3], dmem_rdata[2], dmem_rdata[1], dmem_rdata[0]};
        endcase
    end

    always_comb begin
        case (branchOp)
            rvDefs::BRANCH_OP_EQ:  branchPass = ((read1Data == read2Data) ^ branchNegate);
            rvDefs::BRANCH_OP_LT:  branchPass = (($signed(read1Data) < $signed(read2Data)) ^ branchNegate);
            rvDefs::BRANCH_OP_LTU: branchPass = ((read1Data < read2Data) ^ branchNegate);
            default:               branchPass = 1'b0;
        endcase
    end

    assign exception = ecall || ebreak;
    assign exceptionCode = ebreak ? 32'd3 :
                           ecall  ? 32'd11 : 32'd0;
    assign trapValue = 32'd0;

    assign pcLoad = csrTrapTaken || mret || jump || branchPass;
    assign pcNext = (csrTrapTaken || mret) ? csrTrapPC : aluResult;

    ProgramCounter programCounter(
        .clk(sysclk),
        .resetN(sysreset),
        .enable(cpu_enable),
        .load(pcLoad),
        .addrLoad(pcNext),
        .addrOut(instructionAddr)
    );

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
        .writeSource(writeSource),
        .mret(mret),
        .ecall(ecall),
        .ebreak(ebreak)
    );

    always_comb begin
        case (memoryOpSize)
            rvDefs::MEMORY_OP_SIZE_BYTE: memoryMask = rvDefs::word_t'(8'hFF);
            rvDefs::MEMORY_OP_SIZE_HALF: memoryMask = rvDefs::word_t'(16'hFFFF);
            rvDefs::MEMORY_OP_SIZE_WORD: memoryMask = rvDefs::word_t'(32'hFFFF_FFFF);
            default:                     memoryMask = rvDefs::word_t'(0);
        endcase
    end

    always_comb begin
        case (writeSource)
            rvDefs::WRITE_SRC_ALU: writeData = aluResult;
            rvDefs::WRITE_SRC_MEM: writeData = dmem_rdata_word;
            rvDefs::WRITE_SRC_PC:  writeData = instructionAddr + rvDefs::word_t'(32'd4);
            rvDefs::WRITE_SRC_CSR: writeData = csrReadData;
            default:               writeData = 32'b0;
        endcase
    end

    XRegisterFile xRegisterFile(
        .clk(sysclk),
        .writeEnable((writeSource != rvDefs::WRITE_SRC_NONE) & cpu_enable),
        .read1Reg(zeroXaluPrimary ? rvDefs::xreg_addr_t'(0) : rs1),
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

    CSR csr(
        .clk(sysclk),
        .rst(~sysreset),
        .instruction(instruction),
        .pc(instructionAddr),
        .rs1Data(read1Data),
        .exception(exception),
        .exceptionCode(exceptionCode),
        .trapValue(trapValue),
        .mret(mret),
        .extInterrupt(1'b0),
        .timerInterrupt(1'b0),
        .softInterrupt(1'b0),
        .instret(cpu_enable),
        .csrReadData(csrReadData),
        .trapTaken(csrTrapTaken),
        .trapPC(csrTrapPC),
        .interruptTaken(csrInterruptTaken),
        .mstatus(mstatus),
        .mie(mie),
        .mip(mip),
        .mtvec(mtvec),
        .mepc(mepc),
        .mcause(mcause)
    );

endmodule
