`timescale 1ns / 1ps

module uart_rx #(
    parameter int DATA_BITS = 8
) (
    input logic clk,
    input logic rst_n,
    input logic baud_tick,
    input logic rx,
    output logic [DATA_BITS-1:0] data_out,
    output logic valid,
    output logic ready
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= '0;
        end
    end
endmodule
