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
    /*
     * Baud-rate generator
     *   baud16_tick : fires at 16× the baud rate
     *   baud_tick   : fires at 1×  the baud rate
     */
    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;
    localparam int BAUD_DIV_16 = BAUD_DIV / 16;

    logic [$clog2(BAUD_DIV)-1:0] baud_cnt;
    logic [$clog2(BAUD_DIV_16)-1:0] baud16_cnt;
    logic baud_tick;
    logic baud16_tick;

    // 16x tick counter
    always_ff @(posedge uart_if.clk or negedge uart_if.rst_n) begin
        if (!uart_if.rst_n) begin
            baud16_cnt <= '0;
        end else if (baud16_cnt == BAUD_DIV_16 - 1) begin
            baud16_cnt <= '0;
        end else begin
            baud16_cnt <= baud16_cnt + 1;
        end
    end
    assign baud16_tick = (baud16_cnt == BAUD_DIV_16 - 1);

    // 1x tick counter
    always_ff @(posedge uart_if.clk or negedge uart_if.rst_n) begin
        if (!uart_if.rst_n) begin
            baud_cnt <= '0;
        end else if (baud16_tick) begin
            if (baud_cnt == 15) begin
                baud_cnt <= '0;
            end else begin
                baud_cnt <= baud_cnt + 1;
            end
        end
    end
    assign baud_tick = baud16_tick && (baud_cnt == 15);

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
        .valid    (uart_if.rx_valid),
        .ready    (uart_if.rx_ready)
    );
endmodule
