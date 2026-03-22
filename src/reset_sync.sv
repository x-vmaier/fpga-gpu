`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module reset_sync #(
    parameter int NUM_DOMAINS = 2,
    parameter int SYNC_STAGES = 2
) (
    input logic por_clk,
    input logic enable,
    input logic [NUM_DOMAINS-1:0] clk_in,
    output logic [NUM_DOMAINS-1:0] rst_n_out
);
    // POR counter
    logic rst_n;
    logic [3:0] por_cnt;

    always_ff @(posedge por_clk) begin
        if (!enable) begin
            // Hold in reset until enable (locked) asserts
            por_cnt <= '0;
            rst_n   <= 1'b0;
        end else if (por_cnt != 4'hF) begin
            por_cnt <= por_cnt + 1'b1;
            rst_n   <= 1'b0;
        end else begin
            // Deassert when fully counted
            rst_n <= 1'b1;
        end
    end

    // Per-domain synchronised deassert
    for (genvar i = 0; i < NUM_DOMAINS; i++) begin : gen_sync
        input_sync #(
            .NUM_SIGNALS(1),
            .SYNC_STAGES(2)
        ) u_sync (
            .clk     (clk_in[i]),
            .rst_n   (rst_n),
            .async_in(1'(1'b1)),
            .sync_out(rst_n_out[i])
        );
    end
endmodule
