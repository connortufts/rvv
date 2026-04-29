import rvDefs::*;

module ProgramCounter #(
    parameter mem_addr_t RESET_VALUE = mem_addr_t'(0)
)(
    input  logic clk,
    input  logic resetN,
    input  logic enable,
    input  logic load,
    input  mem_addr_t addrLoad,
    output mem_addr_t addrOut
);

    localparam mem_addr_t INCREMENT = 4;

    mem_addr_t addrNext;
    mem_addr_t pc_plus4;

    assign pc_plus4 = addrOut + INCREMENT;

    always_comb begin
        if (load)
            addrNext = addrLoad;
        else
            addrNext = pc_plus4;
    end

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN)
            addrOut <= RESET_VALUE;
        else if (enable)
            addrOut <= addrNext;
    end

endmodule