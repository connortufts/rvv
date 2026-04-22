// CSRRegfile.sv
// Devon Kumar
// 4/17/26

module CSRRegfile
#(
    parameter logic [31:0] HART_ID = 32'd0,
    parameter logic [31:0] MISA_VALUE = 32'h40000100,
    parameter logic [31:0] MTVEC_RESET_VALUE = 32'h00000000
) (
    input  logic        clk,
    input  logic        rst,

    input  logic        csrWrite,
    input  logic        csrSet,
    input  logic        csrClear,
    input  logic [11:0] csrAddr,
    input  logic [31:0] csrWriteData,
    output logic [31:0] csrReadData,

    input  logic        exception,
    input  logic [31:0] exceptionCode,
    input  logic [31:0] trapValue,
    input  logic [31:0] pc,
    input  logic        mret,

    input  logic        extInterrupt,
    input  logic        timerInterrupt,
    input  logic        softInterrupt,

    input  logic        instret,

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

    localparam logic [11:0] CSR_MSTATUS = 12'h300;
    localparam logic [11:0] CSR_MISA = 12'h301;
    localparam logic [11:0] CSR_MIE = 12'h304;
    localparam logic [11:0] CSR_MTVEC = 12'h305;
    localparam logic [11:0] CSR_MSCRATCH = 12'h340;
    localparam logic [11:0] CSR_MEPC = 12'h341;
    localparam logic [11:0] CSR_MCAUSE = 12'h342;
    localparam logic [11:0] CSR_MTVAL = 12'h343;
    localparam logic [11:0] CSR_MIP = 12'h344;
    localparam logic [11:0] CSR_MCYCLE = 12'hB00;
    localparam logic [11:0] CSR_MINSTRET = 12'hB02;
    localparam logic [11:0] CSR_MCYCLEH = 12'hB80;
    localparam logic [11:0] CSR_MINSTRETH = 12'hB82;
    localparam logic [11:0] CSR_CYCLE = 12'hC00;
    localparam logic [11:0] CSR_TIME = 12'hC01;
    localparam logic [11:0] CSR_INSTRET = 12'hC02;
    localparam logic [11:0] CSR_CYCLEH = 12'hC80;
    localparam logic [11:0] CSR_TIMEH = 12'hC81;
    localparam logic [11:0] CSR_INSTRETH = 12'hC82;
    localparam logic [11:0] CSR_MHARTID = 12'hF14;

    localparam int MSTATUS_MIE_BIT = 3;
    localparam int MSTATUS_MPIE_BIT = 7;
    localparam int MSTATUS_MPP_LSB = 11;

    localparam logic [31:0] MSTATUS_WRITE_MASK = 32'h0000_1888;
    localparam logic [31:0] MIE_WRITE_MASK = 32'h0000_0888;
    localparam logic [31:0] MIP_READ_MASK = 32'h0000_0888;
    localparam logic [31:0] MTVEC_WRITE_MASK = 32'hFFFF_FFFC;
    localparam logic [31:0] MEPC_WRITE_MASK = 32'hFFFF_FFFC;

    localparam logic [31:0] IRQ_SOFT = 32'd3;
    localparam logic [31:0] IRQ_TIMER = 32'd7;
    localparam logic [31:0] IRQ_EXT = 32'd11;

    logic [31:0] mscratch;
    logic [31:0] mtval;
    logic [63:0] cycleCounter;
    logic [63:0] instretCounter;

    logic [31:0] mipNext;
    logic interruptPending;
    logic [31:0] interruptCause;
    logic [31:0] csrCurrentValue;
    logic [31:0] csrWriteValue;

    assign mipNext = {
        20'b0,
        extInterrupt,
        3'b0,
        timerInterrupt,
        3'b0,
        softInterrupt,
        3'b0
    };

    assign interruptPending = mstatus[MSTATUS_MIE_BIT] && (
        (mie[IRQ_EXT] && mipNext[IRQ_EXT])   ||
        (mie[IRQ_TIMER] && mipNext[IRQ_TIMER]) ||
        (mie[IRQ_SOFT] && mipNext[IRQ_SOFT])
    );

    always_comb begin
        if (mie[IRQ_EXT] && mipNext[IRQ_EXT]) begin
            interruptCause = 32'h8000_0000 | IRQ_EXT;
        end else if (mie[IRQ_TIMER] && mipNext[IRQ_TIMER]) begin
            interruptCause = 32'h8000_0000 | IRQ_TIMER;
        end else if (mie[IRQ_SOFT] && mipNext[IRQ_SOFT]) begin
            interruptCause = 32'h8000_0000 | IRQ_SOFT;
        end else begin
            interruptCause = 32'b0;
        end
    end

    always_comb begin
        case (csrAddr)
            CSR_MSTATUS: csrCurrentValue = mstatus;
            CSR_MISA: csrCurrentValue = MISA_VALUE;
            CSR_MIE: csrCurrentValue = mie;
            CSR_MTVEC: csrCurrentValue = mtvec;
            CSR_MSCRATCH: csrCurrentValue = mscratch;
            CSR_MEPC: csrCurrentValue = mepc;
            CSR_MCAUSE: csrCurrentValue = mcause;
            CSR_MTVAL: csrCurrentValue = mtval;
            CSR_MIP: csrCurrentValue = mip;
            CSR_MCYCLE,
            CSR_CYCLE,
            CSR_TIME: csrCurrentValue = cycleCounter[31:0];
            CSR_MCYCLEH,
            CSR_CYCLEH,
            CSR_TIMEH: csrCurrentValue = cycleCounter[63:32];
            CSR_MINSTRET,
            CSR_INSTRET: csrCurrentValue = instretCounter[31:0];
            CSR_MINSTRETH,
            CSR_INSTRETH: csrCurrentValue = instretCounter[63:32];
            CSR_MHARTID: csrCurrentValue = HART_ID;
            default: csrCurrentValue = 32'b0;
        endcase
    end

    assign csrReadData = csrCurrentValue;

    always_comb begin
        if (csrWrite) begin
            csrWriteValue = csrWriteData;
        end else if (csrSet) begin
            csrWriteValue = csrCurrentValue | csrWriteData;
        end else if (csrClear) begin
            csrWriteValue = csrCurrentValue & ~csrWriteData;
        end else begin
            csrWriteValue = csrCurrentValue;
        end
    end

    assign interruptTaken = interruptPending;
    assign trapTaken      = exception || interruptPending;
    assign trapPC         = interruptPending ? {mtvec[31:2], 2'b00} :
                                           exception ? {mtvec[31:2], 2'b00} :
                                           mret ? {mepc[31:2], 2'b00} : 32'b0;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mstatus       <= 32'h00001800;
            mie           <= 32'b0;
            mip           <= 32'b0;
            mtvec         <= MTVEC_RESET_VALUE & MTVEC_WRITE_MASK;
            mepc          <= 32'b0;
            mcause        <= 32'b0;
            mscratch      <= 32'b0;
            mtval         <= 32'b0;
            cycleCounter  <= 64'b0;
            instretCounter <= 64'b0;
        end else begin
            cycleCounter <= cycleCounter + 64'd1;
            mip          <= mipNext;

            if (instret) begin
                instretCounter <= instretCounter + 64'd1;
            end

            if (interruptPending) begin
                mepc                   <= {pc[31:2], 2'b00};
                mcause                 <= interruptCause;
                mtval                  <= 32'b0;
                mstatus[MSTATUS_MPIE_BIT] <= mstatus[MSTATUS_MIE_BIT];
                mstatus[MSTATUS_MIE_BIT]  <= 1'b0;
                mstatus[MSTATUS_MPP_LSB +: 2] <= 2'b11;
            end else if (exception) begin
                mepc                   <= {pc[31:2], 2'b00};
                mcause                 <= exceptionCode;
                mtval                  <= trapValue;
                mstatus[MSTATUS_MPIE_BIT] <= mstatus[MSTATUS_MIE_BIT];
                mstatus[MSTATUS_MIE_BIT]  <= 1'b0;
                mstatus[MSTATUS_MPP_LSB +: 2] <= 2'b11;
            end else if (mret) begin
                mstatus[MSTATUS_MIE_BIT]  <= mstatus[MSTATUS_MPIE_BIT];
                mstatus[MSTATUS_MPIE_BIT] <= 1'b1;
                mstatus[MSTATUS_MPP_LSB +: 2] <= 2'b00;
            end

            if (!(exception || interruptPending || mret)) begin
                unique case (csrAddr)
                    CSR_MSTATUS: begin
                        if (csrWrite || csrSet || csrClear) begin
                            mstatus <= (mstatus & ~MSTATUS_WRITE_MASK) |
                                       (csrWriteValue & MSTATUS_WRITE_MASK);
                        end
                    end
                    CSR_MIE: begin
                        if (csrWrite || csrSet || csrClear) begin
                            mie <= csrWriteValue & MIE_WRITE_MASK;
                        end
                    end
                    CSR_MTVEC: begin
                        if (csrWrite || csrSet || csrClear) begin
                            mtvec <= csrWriteValue & MTVEC_WRITE_MASK;
                        end
                    end
                    CSR_MSCRATCH: begin
                        if (csrWrite || csrSet || csrClear) begin
                            mscratch <= csrWriteValue;
                        end
                    end
                    CSR_MEPC: begin
                        if (csrWrite || csrSet || csrClear) begin
                            mepc <= csrWriteValue & MEPC_WRITE_MASK;
                        end
                    end
                    CSR_MCAUSE: begin
                        if (csrWrite || csrSet || csrClear) begin
                            mcause <= csrWriteValue;
                        end
                    end
                    CSR_MTVAL: begin
                        if (csrWrite || csrSet || csrClear) begin
                            mtval <= csrWriteValue;
                        end
                    end
                    CSR_MCYCLE,
                    CSR_CYCLE,
                    CSR_TIME: begin
                        if (csrWrite || csrSet || csrClear) begin
                            cycleCounter[31:0] <= csrWriteValue;
                        end
                    end
                    CSR_MCYCLEH,
                    CSR_CYCLEH,
                    CSR_TIMEH: begin
                        if (csrWrite || csrSet || csrClear) begin
                            cycleCounter[63:32] <= csrWriteValue;
                        end
                    end
                    CSR_MINSTRET,
                    CSR_INSTRET: begin
                        if (csrWrite || csrSet || csrClear) begin
                            instretCounter[31:0] <= csrWriteValue;
                        end
                    end
                    CSR_MINSTRETH,
                    CSR_INSTRETH: begin
                        if (csrWrite || csrSet || csrClear) begin
                            instretCounter[63:32] <= csrWriteValue;
                        end
                    end
                    default: begin
                    end
                endcase
            end
        end
    end

endmodule
