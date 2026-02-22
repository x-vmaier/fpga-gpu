`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module clockgate (
    input logic clk,
    input logic rst_n,
    output logic [3:0] cg_clk
);

    logic [2:0] cg_clk_cnt;

    // Clock Gating
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cg_clk_cnt <= '0;
        end else begin
            cg_clk_cnt <= cg_clk_cnt + 1;
        end
    end

    assign cg_clk = {
        &cg_clk_cnt[2:0],
        &cg_clk_cnt[1:0],
        cg_clk_cnt[0],
        1'b1
    };
endmodule
