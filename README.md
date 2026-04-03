# FPGA GPU

Fixed-function graphics pipeline with a UART interface, implemented on the [Basys 3](https://digilent.com/reference/programmable-logic/basys-3/start) FPGA board.

For library build instructions, see [lib/README.md](lib/README.md).

## Prerequisites

- [Vivado Design Suite](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html)
- [Python 3](https://www.python.org/downloads/)

## Build

1. Clone this repo:

   ```bash
   git clone https://github.com/x-vmaier/fpga-gpu.git
   cd fpga-gpu
   ```

2. Generate a `.coe` file from an image using the script in `scripts/`:

   ```bash
   python scripts/img2coe.py <input_image> -o resources/image.coe
   ```

   > The output path `resources/image.coe` is what the project expects by default. Do not change it unless you also update the block memory IP configuration in Vivado.

3. Open Vivado and run the `create.tcl` Tcl script.

4. Synthesize and implement by running `build.tcl`.

## Program Device

To program the SPI flash memory, select `s25fl032p-spi-x1_x2_x4` and follow the prompts to flash the bitstream.
