# Detect target architecture
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(D2XX_ARCH "amd64")
else()
    set(D2XX_ARCH "i386")
endif()

find_path(D2XX_INCLUDE_DIR
    NAMES ftd2xx.h
    PATHS "${FTD2XX_ROOT}"
    NO_DEFAULT_PATH
)

if(FTD2XX_STATIC)
    find_library(D2XX_LIBRARY
        NAMES FTD2XX ftd2xx
        PATHS "${FTD2XX_ROOT}/Static/${D2XX_ARCH}"
        NO_DEFAULT_PATH
    )
else()
    find_library(D2XX_LIBRARY
        NAMES ftd2xx FTD2XX
        PATHS "${FTD2XX_ROOT}/${D2XX_ARCH}"
        NO_DEFAULT_PATH
    )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(D2XX
    REQUIRED_VARS D2XX_LIBRARY D2XX_INCLUDE_DIR
    FAIL_MESSAGE
    "D2XX not found. Download the driver package from \
https://ftdichip.com/drivers/d2xx-drivers/ and extract it into third_party/ftdi, \
then set FTD2XX_ROOT to that path."
)

if(D2XX_FOUND AND NOT TARGET D2XX::D2XX)
    add_library(D2XX::D2XX UNKNOWN IMPORTED)
    set_target_properties(D2XX::D2XX PROPERTIES
        IMPORTED_LOCATION "${D2XX_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${D2XX_INCLUDE_DIR}"
    )
endif()

mark_as_advanced(D2XX_INCLUDE_DIR D2XX_LIBRARY)
