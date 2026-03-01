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
    // Clocks & resets
    localparam int DOM_SYS = 1;
    localparam int DOM_VGA = 0;

    logic clk_vga;
    logic [1:0] clk_arr;
    logic [1:0] rst_arr;
    logic rst_n_clk_osc;
    logic rst_n_clk_vga;
    logic pll_locked;

    logic rx_sync;
    logic [15:0] sw_sync;
    logic [16:0] async_in;
    logic [16:0] sync_out;

    logic [15:0] segment_data_in;
    logic [3:0] segment_point_in;

    assign segment_point_in = '0;
    assign LED = sw_sync;

    // Clock wizard (MMCM)
    clk_wiz_0 cw0 (
        .clk_in1 (clk_osc),
        .resetn  (1'b1),     // MMCM has its own POR on Xilinx 7-series
        .clk_out1(clk_vga),
        .locked  (pll_locked)
    );

    // Global reset
    assign clk_arr[DOM_SYS] = clk_osc;
    assign clk_arr[DOM_VGA] = clk_vga;

    global_reset gr0 (
        .por_clk  (clk_osc),
        .clk_in   (clk_arr),
        .rst_n_out(rst_arr),
        .enable   (pll_locked) // stall POR counter until clocks stable
    );

    assign rst_n_clk_osc = rst_arr[DOM_SYS];
    assign rst_n_clk_vga = rst_arr[DOM_VGA];

    // Input synchronization
    assign async_in = {sw, RsRx};

    input_sync #(
        .NUM_SIGNALS(17),
        .SYNC_STAGES(2)
    ) input_sync0 (
        .clk     (clk_osc),
        .rst_n   (rst_n_clk_osc),
        .async_in(async_in),
        .sync_out(sync_out)
    );

    assign rx_sync = sync_out[0];
    assign sw_sync = sync_out[16:1];

    // UART interface
    uart_io uart_if (
        .clk  (clk_osc),
        .rst_n(rst_n_clk_osc)
    );

    assign uart_if.rx = rx_sync;
    assign RsTx = uart_if.tx;

    assign segment_data_in = {8'b0, uart_if.rx_data};

    // Sub-blocks
    uart u_uart0 (.uart_if(uart_if));

    seven_segment_translator sst0 (
        .clk             (clk_osc),
        .rst_n           (rst_n_clk_osc),
        .segment_data_in (segment_data_in),
        .segment_point_in(segment_point_in),
        .seg             (seg),
        .an              (an),
        .dp              (dp)
    );

    display_engine de0 (
        .clk     (clk_vga),
        .rst_n   (rst_n_clk_vga),
        .vgaRed  (vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue (vgaBlue),
        .Hsync   (Hsync),
        .Vsync   (Vsync)
    );
endmodule
