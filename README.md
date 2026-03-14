# FPGA GPU

Fixed-function graphics pipeline with a UART interface, implemented on the Basys 3 FPGA board.

## Prerequisites

- [Vivado Design Suite](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html)
- [Python 3](https://www.python.org/downloads/)

## Build

1. Clone this repo:
   ```bash
   git clone https://github.com/x-vmaier/fpga-gpu.git
   cd fpga-gpu
   ```
2. Generate a `.coe` file from an image using the script in `/scripts`:
   ```bash
   python scripts/img2coe.py <input_image> -o resources/image.coe
   ```
3. Open Vivado and run the `build.tcl` Tcl script.

## Program Device

To program the SPI flash memory, select `s25fl032p-spi-x1_x2_x4` and follow the prompts to flash the bitstream.
