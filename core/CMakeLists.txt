add_library(sritec_core STATIC
    include/sritec/common.hpp
    include/sritec/logger.hpp
    src/logger.cpp
)

target_include_directories(sritec_core
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_compile_features(sritec_core PUBLIC cxx_std_20)
sritec_set_target_warnings(sritec_core)
