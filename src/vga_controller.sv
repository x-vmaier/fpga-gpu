`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module vga_controller #(
    parameter int H_ACTIVE = 640,
    parameter int H_FP = 16,
    parameter int H_SYNC = 96,
    parameter int H_BP = 48,
    parameter int V_ACTIVE = 480,
    parameter int V_FP = 10,
    parameter int V_SYNC = 2,
    parameter int V_BP = 33
) (
    input logic clk,
    input logic rst_n,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic Hsync,
    output logic Vsync
);

    localparam int H_TOTAL = H_SYNC + H_BP + H_ACTIVE + H_FP;
    localparam int V_TOTAL = V_SYNC + V_BP + V_ACTIVE + V_FP;

    logic [$clog2(H_TOTAL)-1:0] Hcnt;
    logic [$clog2(V_TOTAL)-1:0] Vcnt;
    logic display_active;

    // Counters
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Hcnt <= '0;
            Vcnt <= '0;
        end else begin
            if (Hcnt == H_TOTAL - 1) begin
                Hcnt <= '0;
                Vcnt <= (Vcnt == V_TOTAL - 1) ? '0 : Vcnt + 1'b1;
            end else begin
                Hcnt <= Hcnt + 1'b1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Hsync <= 1'b1;
            Vsync <= 1'b1;
            display_active <= 1'b0;
        end else begin
            Hsync <= ~(Hcnt >= H_ACTIVE + H_FP && Hcnt < H_ACTIVE + H_FP + H_SYNC);
            Vsync <= ~(Vcnt >= V_ACTIVE + V_FP && Vcnt < V_ACTIVE + V_FP + V_SYNC);

            display_active <= (Hcnt >= H_SYNC + H_BP && Hcnt < H_SYNC + H_BP + H_ACTIVE) &&
                              (Vcnt >= V_SYNC + V_BP && Vcnt < V_SYNC + V_BP + V_ACTIVE);
        end
    end

    // Pixel output
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vgaRed   <= 4'h0;
            vgaGreen <= 4'h0;
            vgaBlue  <= 4'h0;
        end else begin
            if (display_active) begin
                vgaRed   <= 4'h0;
                vgaGreen <= 4'hF;
                vgaBlue  <= 4'hF;
            end else begin
                // Drive black outside active region
                vgaRed   <= 4'h0;
                vgaGreen <= 4'h0;
                vgaBlue  <= 4'h0;
            end
        end
    end

endmodule
