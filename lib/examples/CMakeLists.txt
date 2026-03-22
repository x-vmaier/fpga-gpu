function(add_example NAME)
    add_executable(${NAME} ${NAME}.c)

    target_link_libraries(${NAME} PRIVATE fgl)

    # Copy .dll file
    if(NOT FTD2XX_STATIC)
        add_custom_command(TARGET ${NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${FTD2XX_ROOT}/${D2XX_ARCH}/FTD2XX64.dll"
            "$<TARGET_FILE_DIR:${NAME}>"
            COMMENT "Copying FTD2XX64.dll to output directory"
        )
    endif()
endfunction()

add_example(hello_gpu)
