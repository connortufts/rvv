module ProgramCounter(
    input logic clk,
    input logic enable,
    input logic resetN,
    input logic load,
    input logic [31 : 0] addrIn,
    output logic [31 : 0] addrOut
);

    // synchronous reset and only resets on enable high

    always_ff @(posedge clk) begin
        if(enable) begin
            if(!resetN) begin
                // reset to 0
                addrOut <= 32'b0;
            end else begin
                addrOut <= load ? addrIn : addrOut + 32'd4;
            end
        end
    end

endmodule
