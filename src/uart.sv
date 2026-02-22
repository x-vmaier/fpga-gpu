`timescale 1ns / 1ps

module uart #(
    parameter int CLK_FREQ  = 100_000_000,
    parameter int BAUD_RATE = 921_600
) (
    uart_io.driver uart_if
);
    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;

    logic baud_tick;
    logic [$clog2(BAUD_DIV)-1:0] baud_cnt;

    // Baud Generator
    always_ff @(posedge uart_if.clk or negedge uart_if.rst_n) begin
        if (!uart_if.rst_n) baud_cnt <= '0;
        else if (baud_cnt == BAUD_DIV - 1) baud_cnt <= '0;
        else baud_cnt <= baud_cnt + 1;
    end

    assign baud_tick = (baud_cnt == BAUD_DIV - 1);

    // Tx
    uart_tx u_tx (
        .clk      (uart_if.clk),
        .rst_n    (uart_if.rst_n),
        .baud_tick(baud_tick),
        .data_in  (uart_if.tx_data),
        .valid    (uart_if.tx_valid),
        .ready    (uart_if.tx_ready),
        .tx       (uart_if.tx)
    );

    // Rx
    uart_rx u_rx (
        .clk      (uart_if.clk),
        .rst_n    (uart_if.rst_n),
        .baud_tick(baud_tick),
        .rx       (uart_if.rx),
        .data_out (uart_if.rx_data),
        .valid    (uart_if.rx_valid),
        .ready    (uart_if.rx_ready)
    );

endmodule
