module RegisterFile(
    input  logic [4:0]  RR1,
    input  logic [4:0]  RR2,
    input  logic [4:0]  WR,
    input  logic [31:0] WD,
    input  logic        WE,
    input  logic        CLK,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);

    // 31 registers, each 32 bits wide
    logic [31:0] regFile [1:31];

    // write on posedge
    always_ff @(posedge CLK) begin
        if (WE && (WR != 5'd0)) begin
            regFile[WR] <= WD;
        end
    end // always_ff

    // combinational reads
    assign RD1 = (RR1 == 5'd0) ? 32'b0 : regFile[RR1]; // xzr safeguard
    assign RD2 = (RR2 == 5'd0) ? 32'b0 : regFile[RR2];

endmodule
