`timescale 1ns / 1ps

module global_reset #(
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
            por_cnt <= '0;  // hold in reset until enable (locked) asserts
            rst_n   <= 1'b0;
        end else if (por_cnt != 4'hF) begin
            por_cnt <= por_cnt + 1'b1;
            rst_n   <= 1'b0;
        end else begin
            rst_n <= 1'b1;  // deassert when fully counted
        end
    end

    // Per-domain synchronised deassert
    generate
        for (genvar i = 0; i < NUM_DOMAINS; i++) begin : gen_sync
            (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
            logic [SYNC_STAGES-1:0] sync_chain;

            always_ff @(posedge clk_in[i] or negedge rst_n) begin
                if (!rst_n) begin
                    sync_chain <= '0;
                end else begin
                    sync_chain <= {sync_chain[SYNC_STAGES-2:0], 1'b1};
                end
            end

            assign rst_n_out[i] = sync_chain[SYNC_STAGES-1];
        end
    endgenerate
endmodule
