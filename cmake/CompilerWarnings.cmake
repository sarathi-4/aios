# ==============================================================================
# SRITEC AI OS — Compiler Warnings & Code Quality Configuration
# ==============================================================================

function(sritec_set_target_warnings TARGET_NAME)
    # Check if target links against Qt or should suppress Qt macro warnings
    set(EXTRA_WARNINGS "")

    if(MSVC)
        target_compile_options(${TARGET_NAME} PRIVATE
            /W4
            /permissive-
        )
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        # Base high-rigor warnings for all targets
        target_compile_options(${TARGET_NAME} PRIVATE
            -Wall
            -Wextra
            -Wpedantic
            -Wshadow
            -Wnon-virtual-dtor
            -Wcast-align
            -Wunused
            -Woverloaded-virtual
            -Wformat=2
            -Wno-unknown-pragmas
        )

        # Apply -Wold-style-cast ONLY to non-Qt targets (Fix 2: avoids Qt macro cast noise)
        get_target_property(TARGET_LIBS ${TARGET_NAME} LINK_LIBRARIES)
        string(FIND "${TARGET_LIBS}" "Qt" HAS_QT)
        if(HAS_QT EQUAL -1)
            target_compile_options(${TARGET_NAME} PRIVATE -Wold-style-cast)
        else()
            target_compile_options(${TARGET_NAME} PRIVATE -Wno-old-style-cast)
        endif()
    endif()
endfunction()
