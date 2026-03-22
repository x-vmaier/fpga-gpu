cmake_minimum_required(VERSION 3.16)
project(fgl VERSION 0.0.1)

set(FTD2XX_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/third_party/ftdi" CACHE PATH "Root of the FTDI D2XX package")
option(FTD2XX_STATIC "Link against the static D2XX library" OFF)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
find_package(D2XX REQUIRED)

add_library(${PROJECT_NAME}
    src/fgl.c
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    C_STANDARD 11
    C_STANDARD_REQUIRED ON
    C_EXTENSIONS OFF
)

target_include_directories(${PROJECT_NAME}
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    D2XX::D2XX
)

option(FGL_BUILD_EXAMPLES "Build the example programs" ON)

if(FGL_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()
