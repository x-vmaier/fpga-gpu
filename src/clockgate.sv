`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module clockgate #(
    parameter int GATES = 4
) (
    input logic clk,
    input logic rst_n,
    output logic [GATES-1:0] cg_clk
);
    logic [GATES-2:0] cnt;

    // Counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= '0;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

    assign cg_clk[0] = 1'b1;

    generate
        // Reduction AND over a slice
        for (genvar k = 1; k < GATES; k++) begin : gen_gate
            assign cg_clk[k] = &cnt[k-1:0];
        end
    endgenerate

endmodule
