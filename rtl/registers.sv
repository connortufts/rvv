module registers (
    input  logic [4:0]  RR1,
    input  logic [4:0]  RR2,
    input  logic [4:0]  WR,
    input  logic [31:0] WD,
    input  logic        RW,
    input  logic        CLK,
    input  logic        RST,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);

    // 32 registers, each 32 bits wide
    logic [31:0] regFile [0:31];

    integer i;

    // write on posedge
    always_ff @(posedge CLK or posedge RST) begin
        if(RST) begin
            for (i = 0; i < 32; i = i + 1)
                regFile[i] <= 32'b0; // async reset
        end else begin 
            if (RW && (WR != 5'd0))
            regFile[WR] <= WD;
            regFile[0] <= 32'b0;
        end // else
    end // always_ff

    // combinational reads
    assign RD1 = (RR1 == 5'd0) ? 32'b0 : regFile[RR1]; // xzr safeguard
    assign RD2 = (RR2 == 5'd0) ? 32'b0 : regFile[RR2];

endmodule
