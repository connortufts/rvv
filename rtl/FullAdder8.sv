module FullAdder8
(
    input logic [7 : 0] a,
    input logic [7 : 0] b,
    input logic cIn,
    output logic [7 : 0] s,
    output logic cOut
);

assign {cOut, s} = a + b + cIn;

endmodule
