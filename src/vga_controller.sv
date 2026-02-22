`timescale 1ns / 1ps


(* keep_hierarchy = "yes" *) module vga_controller #(
    parameter H_ACTIVE = 640,
    parameter H_FP = 16,
    parameter H_SYNC = 96,
    parameter H_BP = 48,
    parameter V_ACTIVE = 480,
    parameter V_FP = 10,
    parameter V_SYNC = 2,
    parameter V_BP = 33
) (
    input logic clk,
    input logic rst_n,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic Hsync,
    output logic Vsync
);

    localparam H_TOTAL = H_SYNC + H_BP + H_ACTIVE + H_FP;
    localparam V_TOTAL = V_SYNC + V_BP + V_ACTIVE + V_FP;

    logic [9:0] Hcnt;
    logic [9:0] Vcnt;
    logic display_active;

    // Counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Hcnt <= 0;
            Vcnt <= 0;
        end else begin
            if (Hcnt == H_TOTAL - 1) begin
                Hcnt <= 0;
                Vcnt <= (Vcnt == V_TOTAL - 1) ? 0 : Vcnt + 1;
            end else begin
                Hcnt <= Hcnt + 1;
            end
        end
    end

    assign Hsync = ~((Hcnt >= H_FP && Hcnt < H_FP + H_SYNC) || Vcnt < (V_SYNC + V_BP));
    assign Vsync = ~(Vcnt >= V_FP && Vcnt < V_FP + V_SYNC);

    assign display_active = (Hcnt >= (H_SYNC + H_BP)) && (Hcnt < (H_SYNC + H_BP + H_ACTIVE)) &&
                            (Vcnt >= (V_SYNC + V_BP)) && (Vcnt < (V_SYNC + V_BP + V_ACTIVE));

    // Display
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vgaRed   <= 4'h0;
            vgaGreen <= 4'h0;
            vgaBlue  <= 4'h0;
        end else begin
            vgaRed   <= display_active ? Hcnt[5:2] : 4'h0;
            vgaGreen <= display_active ? Vcnt[5:2] : 4'h0;
        end
    end

endmodule
