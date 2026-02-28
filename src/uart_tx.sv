`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module uart_tx #(
    parameter int DATA_BITS = 8,
    parameter int STOP_BITS = 1
) (
    input logic clk,
    input logic rst_n,
    input logic baud_tick,
    input logic [DATA_BITS-1:0] data_in,
    output logic valid,
    output logic ready,
    output logic tx
);
    assign tx = 1'b1;
    assign ready = 1'b0;
    assign valid = 1'b0;
endmodule
