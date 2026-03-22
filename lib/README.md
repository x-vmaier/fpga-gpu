# libFpgaGpu

C/C++ library for the fixed-function graphics pipeline.

## Prerequisites

- CMake 3.16 or later
- A C++17-capable compiler (MSVC, GCC, or Clang)
- [FTDI D2XX Driver](https://ftdichip.com/drivers/d2xx-drivers/)

## Setup

1. Clone this repo:

   ```bash
   git clone https://github.com/x-vmaier/fpga-gpu.git
   cd fpga-gpu
   ```

2. Download the [D2XX Driver package](https://ftdichip.com/drivers/d2xx-drivers/) for your platform and extract its contents into `lib/third_party/ftdi`.

## Build

1. Navigate to the `lib/` directory inside `fpga-gpu/`:

   ```bash
   cd lib
   ```

2. Configure and build using a preset:

   ```bash
   cmake --preset x64-release
   cmake --build --preset x64-release
   ```

   Use `x64-debug` for a debug build. To override options at configure time:

   | Option                    | Default | Description                          |
   | ------------------------- | ------- | ------------------------------------ |
   | `FTD2XX_STATIC`           | `OFF`   | Link against the static D2XX library |
   | `FPGA_GPU_BUILD_EXAMPLES` | `ON`    | Build the example programs           |

## Usage

Link `libFpgaGpu` into your target and include the public header:

```cpp
#include <fpga_gpu.h>
```

See the [`examples/`](examples/) directory for usage examples.
