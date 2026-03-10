# clk_out1_clk_wiz_0 is inferred by Vivado from the MMCM output and does not
# exist at synthesis time. This file must be marked used_in_synthesis false.


# System clock
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_osc]

# Clock domain crossing
set_clock_groups -name cdc_sys_vga -asynchronous \
    -group [get_clocks sys_clk_pin] \
    -group [get_clocks clk_out1_clk_wiz_0]


# Non-critical inputs
set_false_path -from [get_ports {sw[*]}]
set_false_path -from [get_ports RsRx]


# Non-critical outputs
set_false_path -to [get_ports {vgaRed[*]}]
set_false_path -to [get_ports {vgaGreen[*]}]
set_false_path -to [get_ports {vgaBlue[*]}]
set_false_path -to [get_ports Hsync]
set_false_path -to [get_ports Vsync]
set_false_path -to [get_ports {LED[*]}]
set_false_path -to [get_ports {seg[*]}]
set_false_path -to [get_ports {an[*]}]
set_false_path -to [get_ports dp]
set_false_path -to [get_ports RsTx]
