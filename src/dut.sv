`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module dut (
    input logic clk_osc,
    input logic [15:0] sw,
    input logic RsRx,
    output logic RsTx,
    output logic Hsync,
    output logic Vsync,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic [15:0] LED,
    output logic [6:0] seg,
    output logic [3:0] an,
    output logic dp
);
    localparam int DOM_SYS = 0;
    localparam int DOM_VGA = 1;

    // Clocks and resets
    logic [1:0] clk_arr;
    logic [1:0] rst_arr;
    logic pll_locked;

    // Input synchronization
    logic rx_sync;
    logic [15:0] sw_sync;

    // 7-Segment display
    logic [15:0] segment_data_in;
    logic [3:0] segment_point_in;

    assign segment_point_in = '0;
    assign LED = sw_sync;

    // Clock wizard (MMCM)
    assign clk_arr[DOM_SYS] = clk_osc;

    clk_wiz_0 u_clk_wiz (
        .clk_in1 (clk_osc),
        .resetn  (1'b1),
        .clk_out1(clk_arr[DOM_VGA]),
        .locked  (pll_locked)
    );

    // Global reset
    global_reset #(
        .NUM_DOMAINS(2),
        .SYNC_STAGES(2)
    ) u_global_reset (
        .por_clk  (clk_osc),
        .clk_in   (clk_arr),
        .rst_n_out(rst_arr),
        .enable   (pll_locked)
    );

    // Synchronize external signals
    input_sync #(
        .NUM_SIGNALS(17),
        .SYNC_STAGES(2)
    ) u_sync (
        .clk     (clk_osc),
        .rst_n   (rst_arr[DOM_SYS]),
        .async_in({sw, RsRx}),
        .sync_out({sw_sync, rx_sync})
    );

    // UART interface
    uart_io uart_if (
        .clk  (clk_osc),
        .rst_n(rst_arr[DOM_SYS])
    );

    assign uart_if.rx = rx_sync;
    assign RsTx = uart_if.tx;

    logic [7:0] echo_data;
    logic echo_pending;

    assign uart_if.tx_data  = echo_data;
    assign uart_if.tx_valid = echo_pending && uart_if.tx_ready;

    always_ff @(posedge clk_osc or negedge rst_arr[DOM_SYS]) begin
        if (!rst_arr[DOM_SYS]) begin
            echo_data <= '0;
            echo_pending <= 1'b0;
        end else begin
            if (uart_if.rx_valid) begin
                echo_data <= uart_if.rx_data;
                echo_pending <= 1'b1;
            end else if (!uart_if.tx_ready && echo_pending) begin
                // TX latched the byte this cycle
                echo_pending <= 1'b0;
            end
        end
    end

    // UART module
    uart #(
        .BAUD_RATE(921_600),
        .BAUD_OSR (8),
        .DATA_BITS(8),
        .STOP_BITS(1)
    ) u_uart (
        .uart_if(uart_if)
    );

    // Display UART Rx data
    assign segment_data_in = {8'b0, uart_if.rx_data};

    seven_segment_translator #(
        .REFRESH_BITS(17)
    ) u_seven_seg (
        .clk             (clk_osc),
        .rst_n           (rst_arr[DOM_SYS]),
        .segment_data_in (segment_data_in),
        .segment_point_in(segment_point_in),
        .seg             (seg),
        .an              (an),
        .dp              (dp)
    );

    // VGA display output
    display_engine #(
        .H_ACTIVE(640),
        .V_ACTIVE(480)
    ) u_display_engine (
        .clk     (clk_arr[DOM_VGA]),
        .rst_n   (rst_arr[DOM_VGA]),
        .vgaRed  (vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue (vgaBlue),
        .Hsync   (Hsync),
        .Vsync   (Vsync)
    );
endmodule
