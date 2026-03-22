# FGL

FPGA Graphics Library (FGL) is a C library for the fixed-function graphics pipeline.

## Prerequisites

- CMake 3.16 or later
- A C11-capable compiler (MSVC, GCC, or Clang)
- [FTDI D2XX Driver](https://ftdichip.com/drivers/d2xx-drivers/)

## Setup

1. Clone this repo:

   ```bash
   git clone https://github.com/x-vmaier/fpga-gpu.git
   cd fpga-gpu
   ```

2. Download the [D2XX Driver package](https://ftdichip.com/drivers/d2xx-drivers/) for your platform and extract its contents into `lib/third_party/ftdi`.

## Build

Configure and build from `lib/` using a preset:

```bash
cd lib
cmake --preset x64-release
cmake --build --preset x64-release
```

Use `x64-debug` for a debug build. To override options at configure time:

| Option               | Default | Description                          |
| -------------------- | ------- | ------------------------------------ |
| `FTD2XX_STATIC`      | `OFF`   | Link against the static D2XX library |
| `FGL_BUILD_EXAMPLES` | `ON`    | Build the example programs           |

Example:

```bash
cmake --preset x64-release -DFTD2XX_STATIC=ON -DFGL_BUILD_EXAMPLES=OFF
```

## Usage

### FetchContent

```cmake
FetchContent_Declare(
    fgl
    GIT_REPOSITORY https://github.com/x-vmaier/fpga-gpu.git
    GIT_TAG        main
    SOURCE_SUBDIR  lib
)
FetchContent_MakeAvailable(fgl)

target_link_libraries(your_target PRIVATE fgl)
```

### Direct use

Link `fgl` into your target and include the public header:

```c
#include <fgl.h>
```

See the [`examples/`](examples/) directory for usage examples.
