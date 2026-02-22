`timescale 1ns / 1ps

`include "TB_macro_collection.vh"

program tb_vga_controller ();
    localparam int CLK_PERIOD_PS = 39_722;
    localparam int H_SYNC        = 96;
    localparam int H_TOTAL       = 640 + 16 + 96 + 48;
    localparam int V_TOTAL       = 480 + 10 +  2 + 33;
    localparam int H_SYNC_START  = 640 + 16;
    localparam int H_SYNC_END    = 656 + 96;
    localparam int V_SYNC_START  = 480 + 10;
    localparam int V_SYNC_END    = 490 +  2;
    
    time t0, t1, t2;

    `TB_TEST_START("VGA Controller", 1)

    `TB_TEST_PART("Hsync pulse width and period")
        // Measure two consecutive Hsync pulses, check width and period
        `wait_for_negedge(TB.dut0.Hsync, 2ms)
        t0 = $time;
        `wait_for_posedge(TB.dut0.Hsync, 10ms)
        t1 = $time;
        `wait_for_negedge(TB.dut0.Hsync, 10ms)
        t2 = $time;
        `Check_blur(t1 - t0, H_SYNC * CLK_PERIOD_PS / 1000, 2, ("Hsync width: got %0t ns expected %0d ns", t1-t0, H_SYNC * CLK_PERIOD_PS/1000))
        `Check_blur(t2 - t0, H_TOTAL * CLK_PERIOD_PS / 1000, 2, ("Hsync period: got %0t ns expected %0d ns", t2-t0, H_TOTAL * CLK_PERIOD_PS/1000))

    `TB_TEST_PART("display_active region")
        // Force counters to active/inactive boundary, check pixel output
        force TB.dut0.de0.vga0.Hcnt = H_SYNC_START - 1;
        force TB.dut0.de0.vga0.Vcnt = 0;
        @(posedge TB.clk);
        `Check(TB.dut0.de0.vga0.display_active == 0, ("display_active should be 0 in sync region"))
        force TB.dut0.de0.vga0.Hcnt = 96 + 48;  // H_SYNC + H_BP = first active pixel
        force TB.dut0.de0.vga0.Vcnt = 2  + 33;  // V_SYNC + V_BP = first active line
        @(posedge TB.clk);
        `Check(TB.dut0.de0.vga0.display_active == 1, ("display_active should be 1 at first active pixel"))
        release TB.dut0.de0.vga0.Hcnt;
        release TB.dut0.de0.vga0.Vcnt;

    `TB_TEST_PART("Vsync — skip to boundary")
        force TB.dut0.de0.vga0.Vcnt = V_SYNC_START - 1;
        force TB.dut0.de0.vga0.Hcnt = H_TOTAL - 1;
        @(posedge TB.clk);
        release TB.dut0.de0.vga0.Vcnt;
        release TB.dut0.de0.vga0.Hcnt;
        `wait_for_negedge(TB.dut0.Vsync, 100us)

    `TB_TEST_END(50ms)
endprogram
