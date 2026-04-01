module MUX32(
    input logic         s0,
    input logic [31:0]  in0,
    input logic [31:0]  in1,
    output logic [31:0] out
);

    assign out = s0 ? in1 : in0;

endmodule
