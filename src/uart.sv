`timescale 1ns / 1ps

module uart #(
    parameter int CLK_FREQ = 100_000_000,
    parameter int BAUD_RATE = 921_600,
    parameter int DATA_BITS = 8,
    parameter int STOP_BITS = 1,
    parameter int PARITY_BITS = 0
) (
    uart_io.driver uart_if
);
    logic baud_tick;
    logic baud16_tick;

    baud_gen #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) bg0 (
        .clk        (uart_if.clk),
        .rst_n      (uart_if.rst_n),
        .baud_tick  (baud_tick),
        .baud16_tick(baud16_tick)
    );

    uart_tx #(
        .DATA_BITS  (DATA_BITS),
        .STOP_BITS  (STOP_BITS),
        .PARITY_BITS(PARITY_BITS)
    ) u_tx (
        .clk      (uart_if.clk),
        .rst_n    (uart_if.rst_n),
        .baud_tick(baud_tick),
        .data_in  (uart_if.tx_data),
        .valid    (uart_if.tx_valid),
        .ready    (uart_if.tx_ready),
        .tx       (uart_if.tx)
    );

    uart_rx #(
        .DATA_BITS  (DATA_BITS),
        .STOP_BITS  (STOP_BITS),
        .PARITY_BITS(PARITY_BITS)
    ) u_rx (
        .clk      (uart_if.clk),
        .rst_n    (uart_if.rst_n),
        .baud_tick(baud16_tick),
        .rx       (uart_if.rx),
        .data_out (uart_if.rx_data),
        .valid    (uart_if.rx_valid)
    );
endmodule
