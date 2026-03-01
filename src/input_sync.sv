`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module input_sync #(
    parameter int NUM_SIGNALS = 1,
    parameter int SYNC_STAGES = 2
) (
    input logic clk,
    input logic rst_n,
    input logic [NUM_SIGNALS-1:0] async_in,
    output logic [NUM_SIGNALS-1:0] sync_out
);
    for (genvar i = 0; i < NUM_SIGNALS; i++) begin : gen_sync
        // Ensure Flip-Flops are close together
        (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
        logic [SYNC_STAGES-1:0] sync_chain;

        always_ff @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                sync_chain <= '0;
            end else begin
                // Propagate one step forward in the synchronizer
                sync_chain <= {sync_chain[SYNC_STAGES-2:0], async_in[i]};
            end
        end

        // Input synchronized in last stage
        assign sync_out[i] = sync_chain[SYNC_STAGES-1];
    end
endmodule
