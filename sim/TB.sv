`timescale 1ns / 1ps
`include "TB_macro_collection.vh"

module TB ();
    logic clk;
    logic RsRx;
    logic RsTx;
    logic Hsync;
    logic Vsync;
    logic [3:0] vgaRed;
    logic [3:0] vgaGreen;
    logic [3:0] vgaBlue;

    time Vsync_start, Vsync_end;
    time Vfporch_start, Vfporch_end;

    // DUT Instance
    dut dut0 (
        .CLK100MHZ(clk),
        .*
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end

    // Test Sequence
    `TB_TEST_START("VGA Test", 1)

    `TB_TEST_PART("Vertical front porch timing measurement")
    //`wait_for_posedge(TB.dut0.rst_n, 100us)
    Vfporch_start = $time;
    `wait_for_negedge(TB.dut0.Vsync, 1ms)
    Vfporch_end = $time;
    `Check_blur(Vfporch_end - Vfporch_start, 318us, 10us, ("Front porch time was not as expected"))

    `TB_TEST_PART("Vertical sync timing measurement")
    Vsync_start = $time;  // Already on negedge Vsync
    `wait_for_posedge(TB.dut0.Vsync, 100us)
    Vsync_end = $time;
    `Check_blur(Vsync_end - Vsync_start, 64us, 1us, ("Vertical sync time was not as expected"))

    `TB_TEST_PART("Check signals during vertical sync")
    `wait_for_negedge(TB.dut0.Vsync, 20ms)

    fork
        begin
            // Check if Hsync remains high while Vsync is low
            `Check(TB.dut0.vga0.Hsync == 1, ("Hsync turned low during vertical sync"))
        end
        begin
            // Check if Hcnt is 0 at the start of Vsync
            `Check(TB.dut0.vga0.Hcnt == 0, ("Hcnt not 0 at Vsync start. Hcnt was: %0d", TB.dut0.vga0.Hcnt))
        end
    join

    `TB_TEST_PART("Vertical counter after sync")
    `wait_for_posedge(TB.dut0.Vsync, 100us)
    `Check(TB.dut0.vga0.Vcnt == TB.dut0.vga0.V_SYNC, ("Vcnt not at V_SYNC after first sync. Vcnt was: %0d", TB.dut0.vga0.Vcnt))

    `TB_TEST_END(34ms)

endmodule
