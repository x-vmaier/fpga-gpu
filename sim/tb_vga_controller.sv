`timescale 1ns / 1ps

`include "TB_macro_collection.vh"

program tb_vga_controller ();
    localparam int CLK_PERIOD_PS  = 39_722;
    localparam int H_SYNC         = 96;
    localparam int H_TOTAL        = 640 + 16 + 96 + 48;
    localparam int V_TOTAL        = 480 + 10 +  2 + 33;
    localparam int H_SYNC_START   = 640 + 16;
    localparam int H_SYNC_END     = 656 + 96;
    localparam int V_SYNC_START   = 480 + 10;
    localparam int V_SYNC_END     = 490 +  2;
    localparam int H_ACTIVE_START = 96 + 48;
    localparam int V_ACTIVE_START =  2 + 33;

    time t0, t1, t2;

    `TB_TEST_START("VGA Controller", 1)

    `TB_TEST_PART("Hsync pulse width and period")
        `wait_for_negedge(TB.u_gpu.Hsync, 2ms)
        t0 = $time;
        `wait_for_posedge(TB.u_gpu.Hsync, 10ms)
        t1 = $time;
        `wait_for_negedge(TB.u_gpu.Hsync, 10ms)
        t2 = $time;
        `Check_blur(t1 - t0, H_SYNC * CLK_PERIOD_PS / 1000, 2,
            ("Hsync width: got %0t ns expected ~%0d ns", t1-t0, H_SYNC * CLK_PERIOD_PS / 1000))
        `Check_blur(t2 - t0, H_TOTAL * CLK_PERIOD_PS / 1000, 5,
            ("Hsync period: got %0t ns expected ~%0d ns", t2-t0, H_TOTAL * CLK_PERIOD_PS / 1000))

    `TB_TEST_PART("display_active region")

        // Should be inactive: Hcnt is in the front-porch, before sync
        force TB.u_gpu.u_display_engine.u_vga_controller.Hcnt = H_SYNC_START - 1;
        force TB.u_gpu.u_display_engine.u_vga_controller.Vcnt = '0;
        @(posedge TB.clk);
        `Check(TB.u_gpu.u_display_engine.u_vga_controller.display_active == 1'b0, ("display_active should be 0 in front-porch"))
        release TB.u_gpu.u_display_engine.u_vga_controller.Hcnt;
        release TB.u_gpu.u_display_engine.u_vga_controller.Vcnt;
        repeat(4) @(posedge TB.clk);

        // Should be active: first active pixel
        force TB.u_gpu.u_display_engine.u_vga_controller.Hcnt = H_ACTIVE_START;
        force TB.u_gpu.u_display_engine.u_vga_controller.Vcnt = V_ACTIVE_START;
        @(posedge TB.clk);
        `Check(TB.u_gpu.u_display_engine.u_vga_controller.display_active == 1'b1, ("display_active should be 1 at first active pixel"))
        release TB.u_gpu.u_display_engine.u_vga_controller.Hcnt;
        release TB.u_gpu.u_display_engine.u_vga_controller.Vcnt;
        repeat(4) @(posedge TB.clk);

    `TB_TEST_END(70ms)
endprogram
