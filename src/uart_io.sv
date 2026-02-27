`timescale 1ns / 1ps

interface uart_io #(
    parameter int DATA_BITS = 8
) (
    input logic clk,
    input logic rst_n
);
    logic tx;
    logic rx;
    logic tx_valid;
    logic tx_ready;
    logic rx_valid;
    logic [DATA_BITS-1:0] tx_data;
    logic [DATA_BITS-1:0] rx_data;

    // UART hardware module
    modport driver(
        input clk,
        input rst_n,
        input tx_data,
        input tx_valid,
        input rx,
        output tx,
        output tx_ready,
        output rx_data,
        output rx_valid
    );

    // Host/controller
    modport controller(
        input clk,
        input rst_n,
        input rx_data,
        input rx_valid,
        input tx_ready,
        output tx_data,
        output tx_valid
    );
endinterface
