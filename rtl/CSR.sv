// CSR.sv
// Devon Kumar
// 4/19/26

module CSR
(
    input  logic        clk,
    input  logic        rst,

    input  logic [31:0] instruction,
    input  logic [31:0] pc,
    input  logic [31:0] rs1Data,

    input  logic        exception,
    input  logic [31:0] exceptionCode,
    input  logic [31:0] trapValue,
    input  logic        mret,

    input  logic        extInterrupt,
    input  logic        timerInterrupt,
    input  logic        softInterrupt,

    input  logic        instret,

    output logic [31:0] csrReadData,
    output logic        trapTaken,
    output logic [31:0] trapPC,
    output logic        interruptTaken,
    output logic [31:0] mstatus,
    output logic [31:0] mie,
    output logic [31:0] mip,
    output logic [31:0] mtvec,
    output logic [31:0] mepc,
    output logic [31:0] mcause
);

    logic [11:0] csrAddr;
    logic [2:0]  funct3;
    logic [4:0]  zimm;

    logic [31:0] csrWriteData;
    logic        csrWrite;
    logic        csrSet;
    logic        csrClear;
    logic        csrUseImm;

    logic [31:0] rs1OrImm;

    assign csrAddr   = instruction[31:20];
    assign funct3    = instruction[14:12];
    assign zimm      = instruction[19:15];
    assign csrUseImm = funct3[2];
    assign rs1OrImm  = csrUseImm ? {27'b0, zimm} : rs1Data;

    always_comb begin
        csrWriteData = rs1OrImm;
        csrWrite     = 1'b0;
        csrSet       = 1'b0;
        csrClear     = 1'b0;

        case (funct3)
            3'b001,
            3'b101: csrWrite = 1'b1; // CSRRW / CSRRWI
            3'b010,
            3'b110: csrSet   = 1'b1; // CSRRS / CSRRSI
            3'b011,
            3'b111: csrClear = 1'b1; // CSRRC / CSRRCI
            default: begin
                csrWrite = 1'b0;
                csrSet   = 1'b0;
                csrClear = 1'b0;
            end
        endcase
    end

    CSRRegfile csrRegfile
    (
        .clk(clk),
        .rst(rst),
        .csrWrite(csrWrite),
        .csrSet(csrSet),
        .csrClear(csrClear),
        .csrAddr(csrAddr),
        .csrWriteData(csrWriteData),
        .csrReadData(csrReadData),
        .exception(exception),
        .exceptionCode(exceptionCode),
        .trapValue(trapValue),
        .pc(pc),
        .mret(mret),
        .extInterrupt(extInterrupt),
        .timerInterrupt(timerInterrupt),
        .softInterrupt(softInterrupt),
        .instret(instret),
        .trapTaken(trapTaken),
        .trapPC(trapPC),
        .interruptTaken(interruptTaken),
        .mstatus(mstatus),
        .mie(mie),
        .mip(mip),
        .mtvec(mtvec),
        .mepc(mepc),
        .mcause(mcause)
    );

endmodule
