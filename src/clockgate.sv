`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module clockgate #(
    parameter int GATES = 4
) (
    input logic clk,
    input logic rst_n,
    output logic [GATES-1:0] cg_clk
);
    logic [GATES-2:0] cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= '0;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

    // cg_clk[0] is the full-rate clock
    assign cg_clk[0] = 1'b1;

    // Enables via reduction AND
    for (genvar i = 1; i < GATES; i++) begin : gen_gate
        assign cg_clk[i] = &cnt[i-1:0];
    end
endmodule
