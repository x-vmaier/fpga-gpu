`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module uart_tx #(
    parameter int DATA_BITS   = 8,
    parameter int STOP_BITS   = 1,
    parameter int PARITY_BITS = 0
) (
    input logic clk,
    input logic rst_n,
    input logic baud_tick,
    input logic [DATA_BITS-1:0] data_in,
    output logic valid,
    output logic ready,
    output logic tx
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx <= 0;
        end
    end
endmodule
