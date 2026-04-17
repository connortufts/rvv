module CSR (
    input logic                 clk,
    input logic                 rstn,
    input logic                 csr_we,
    input logic                 csr_re,
    input rvDefs::mem_addr_t    csr_addr,
    input rvDefs::word_t        csr_wdata,
    input rvDefs::word_t        vl_next,
    input logic                 vxsat_set,

    output rvDefs::word_t       csr_rdata,
    output rvDefs::word_t       vl,
    output rvDefs::word_t       vtype,
    output rvDefs::word_t       vstart,
    output logic                vxsat
);

    // Internal architectural registers
    rvDefs::word_t vl_r;
    rvDefs::word_t vtype_r;
    rvDefs::word_t vstart_r;
    logic          vxsat_r;

    // CSR write + hardware update logic
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            vl_r     <= rvDefs::word_t'(0);
            vtype_r  <= rvDefs::word_t'(0);
            vstart_r <= rvDefs::word_t'(0);
            vxsat_r  <= 1'b0;
        end
        else begin

            // Software CSR writes (from SYSTEM instruction path)
            if (csr_we) begin
                case (csr_addr)

                    rvDefs::CSR_VL:
                        vl_r <= csr_wdata;

                    rvDefs::CSR_VTYPE:
                        vtype_r <= csr_wdata;

                    rvDefs::CSR_VSTART:
                        vstart_r <= csr_wdata;

                    // RVV-style sticky behavior (simplified)
                    rvDefs::CSR_VXSAT:
                        vxsat_r <= vxsat_r & ~csr_wdata;

                    default: ;
                endcase
            end

            // Vector execution
            // VL is usually updated by hardware after vector ops
            vl_r <= vl_next;

            // vxsat is sticky and set by vector arithmetic
            if (vxsat_set)
                vxsat_r <= 1'b1;

        end
    end

    // CSR read logic
    always_comb begin
        csr_rdata = rvDefs::word_t'(0);

        if (csr_re) begin
            case (csr_addr)

                rvDefs::CSR_VL:
                    csr_rdata = vl_r;

                rvDefs::CSR_VTYPE:
                    csr_rdata = vtype_r;

                rvDefs::CSR_VSTART:
                    csr_rdata = vstart_r;

                rvDefs::CSR_VXSAT:
                    csr_rdata = rvDefs::word_t'({31'b0, vxsat_r});

                default:
                    csr_rdata = rvDefs::word_t'(0);

            endcase
        end
    end

    // ============================================================
    // Architectural outputs to vector unit / core
    // ============================================================
    assign vl     = vl_r;
    assign vtype  = vtype_r;
    assign vstart = vstart_r;
    assign vxsat  = vxsat_r;

endmodule
