module ProgramCounter
#(
    parameter rvDefs::mem_addr_t RESET_VALUE = rvDefs::mem_addr_t'(0)
)
(
    input  logic              clk,        // loads next instruction address on rising edge
    input  logic              resetN,     // async sets the next address to be RESET_VALUE on clock rising edge
    input  logic              enable,     // if the address output can update when clocked
    input  logic              load,       // if addrLoad should become the next address
                                          //   evaluated on falling edge of clock
    input  rvDefs::mem_addr_t addrLoad,   // value to set the next address to
    output rvDefs::mem_addr_t addrOut     // the address of the instruction currently being fetched
);

    localparam rvDefs::mem_addr_t INCREMENT = 4;
    logic resetFlag;
    rvDefs::mem_addr_t addrNext;
    assign addrNext = (load ? (addrLoad) : (addrOut + INCREMENT));

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

