`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module clockgate (
    input logic clk,
    output logic [3:0] cg_clk,
    output logic rst_n
);

    logic [2:0] cg_clk_cnt;
    logic [3:0] por_cnt = 0;

    // Power on Reset
    always_ff @(posedge clk) begin
        if (por_cnt != 4'hF) begin
            por_cnt <= por_cnt + 1;
            rst_n   <= 0;
        end else begin
            rst_n <= 1;
        end
    end

    // Clock Gating
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cg_clk_cnt <= 0;
        end else begin
            cg_clk_cnt <= cg_clk_cnt + 1;
        end
    end

    assign cg_clk = {&cg_clk_cnt[2:0], &cg_clk_cnt[1:0], cg_clk_cnt[0], 1'b1};

endmodule
