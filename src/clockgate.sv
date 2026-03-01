`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module clockgate #(
    parameter int GATES = 4
) (
    input logic clk,
    input logic rst_n,
    output logic [GATES-1:0] cg_clk
);
    logic [GATES-2:0] cnt;
    logic [GATES-2:0] clk_en;

    // Counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= '0;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

    // Clock enable logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_en <= '0;
        end else begin
            for (int i = 0; i < GATES - 1; i++) begin
                clk_en[i] <= &cnt[i:0];
            end
        end
    end

    // cg_clk[0] is the full-rate clock
    assign cg_clk[0] = clk;

    // BUFGCE per gated clock output
    for (genvar i = 1; i < GATES; i++) begin : gen_bufgce
        BUFGCE u_bufgce (
            .I (clk),
            .CE(clk_en[i-1]),
            .O (cg_clk[i])
        );
    end
endmodule
