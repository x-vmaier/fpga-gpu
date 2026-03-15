`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module vga_controller #(
    parameter int H_ACTIVE = 640,
    parameter int V_ACTIVE = 480,
    parameter int H_FP     = 16,
    parameter int H_SYNC   = 96,
    parameter int H_BP     = 48,
    parameter int V_FP     = 10,
    parameter int V_SYNC   = 2,
    parameter int V_BP     = 33
) (
    input logic clk,
    input logic rst_n,
    input logic [11:0] pixel_data,
    output logic [$clog2(H_ACTIVE)-1:0] x_dest,
    output logic [$clog2(V_ACTIVE)-1:0] y_dest,
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
    logic display_active_r;
    logic display_active_rr;
    logic Hsync_r, Vsync_r;

    // Horizontal and vertical counters
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Hcnt <= '0;
            Vcnt <= '0;
        end else begin
            // Increase vertical count if horizontal count wraps
            if (Hcnt == H_TOTAL - 1) begin
                Hcnt <= '0;
                Vcnt <= (Vcnt == V_TOTAL - 1) ? '0 : Vcnt + 1'b1;
            end else begin
                Hcnt <= Hcnt + 1'b1;
            end
        end
    end

    // Signal goes high when counters are within the visible region
    assign display_active = (Hcnt >= H_SYNC + H_BP && Hcnt < H_SYNC + H_BP + H_ACTIVE) &&
                            (Vcnt >= V_SYNC + V_BP && Vcnt < V_SYNC + V_BP + V_ACTIVE);

    // Pixel coordinates and sync signals
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_dest <= '0;
            y_dest <= '0;
            Hsync_r <= 1'b1;
            Vsync_r <= 1'b1;
            display_active_r <= 1'b0;
        end else begin
            // Translate counter values to pixel coordinates
            x_dest <= display_active ? Hcnt - (H_SYNC + H_BP) : '0;
            y_dest <= display_active ? Vcnt - (V_SYNC + V_BP) : '0;

            // First pipeline stage for BRAM latency alignment
            Hsync_r <= ~(Hcnt < H_SYNC);
            Vsync_r <= ~(Vcnt < V_SYNC);
            display_active_r <= display_active;
        end
    end

    // Align Hsync/Vsync with BRAM read latency
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Hsync <= 1'b1;
            Vsync <= 1'b1;
            display_active_rr <= 1'b0;
        end else begin
            // Second pipeline stage for BRAM latency alignment
            Hsync <= Hsync_r;
            Vsync <= Vsync_r;
            display_active_rr <= display_active_r;
        end
    end

    // RGB output
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vgaRed   <= 4'h0;
            vgaGreen <= 4'h0;
            vgaBlue  <= 4'h0;
        end else begin
            vgaRed   <= display_active_rr ? pixel_data[11:8] : 4'h0;
            vgaGreen <= display_active_rr ? pixel_data[7:4] : 4'h0;
            vgaBlue  <= display_active_rr ? pixel_data[3:0] : 4'h0;
        end
    end
endmodule
