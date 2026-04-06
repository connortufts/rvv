module ProgramCounter
#(
    parameter rvDefs::mem_addr_t RESET_VALUE = rvDefs::mem_addr_t'(16'h1000)
)
(
    input  logic              clk,        // loads next instruction address on rising edge
    input  logic              resetN,     // async sets the next address to be RESET_VALUE on clock rising edge
    input  logic              enable,     // if the address output can update when clocked
    input  logic              loadOffset, // if addrOffset should be added to the current address to become the next address
                                          //   evaluated on falling edge of clock
    input  rvDefs::mem_addr_t addrOffset, // offset to add to the current address
    output rvDefs::mem_addr_t addrOut     // the address of the instruction currently being fetched
);

    localparam rvDefs::mem_addr_t INCREMENT = 4;
    logic resetFlag;
    rvDefs::mem_addr_t addrNext;
    assign addrNext = (loadOffset ? (addrOut + addrOffset) : (addrOut + INCREMENT));

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            addrOut <= RESET_VALUE;
            resetFlag <= 1;
        end else if (enable) begin
            addrOut <= (resetFlag ? RESET_VALUE : addrNext);
            resetFlag <= 0;
        end
    end

endmodule
