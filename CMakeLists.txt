# ==============================================================================
# SRITEC AI OS — Root CMake Project
# Phase 2: Standalone Digital Workspace & Unified AI Gateway
# ==============================================================================
cmake_minimum_required(VERSION 3.25)

project(SRITEC_AI_OS
    VERSION 0.2.0
    DESCRIPTION "Original AI-Native Operating System Workspace (Qt 6 / C++20 / Ubuntu LTS)"
    LANGUAGES C CXX
)

# Standard C++20 enforcement
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable Qt Meta-Object, Resource, and UI Compilers globally
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Global output paths
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

# Custom CMake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(CompilerWarnings)

# Build configuration options
option(SRITEC_BUILD_TESTS "Build automated unit and integration tests" ON)

message(STATUS "========================================================")
message(STATUS "  SRITEC AI OS: Configuring Phase 2 Workspace (v${PROJECT_VERSION})")
message(STATUS "  C++ Standard:    C++${CMAKE_CXX_STANDARD}")
message(STATUS "  Execution Mode:  Standalone Native Desktop Application")
message(STATUS "  AI Subsystem:    Unified AI Provider Gateway")
message(STATUS "========================================================")

# Search for Qt 6 components required for Phase 2 desktop & network gateway
find_package(Qt6 6.5 COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Network
)

# Core shared library
add_subdirectory(core)

# AI subsystem (Multi-provider Gateway & Qt Bridge)
if(Qt6Core_FOUND AND Qt6Network_FOUND)
    add_subdirectory(ai)
    add_subdirectory(jarvis)
else()
    message(WARNING "[!] Qt6Core or Qt6Network not found. AI Gateway module skipped.")
endif()

# Shell desktop window application
if(Qt6_FOUND AND Qt6Quick_FOUND AND Qt6QuickControls2_FOUND)
    message(STATUS "[✓] Qt 6 GUI & QML components available. Shell target enabled.")
    add_subdirectory(shell)
else()
    message(WARNING "[!] Qt 6 components missing. Run './scripts/setup-dev-env.sh' to install required packages.")
endif()

# Tests
if(SRITEC_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

message(STATUS "========================================================")
message(STATUS "  SRITEC AI OS configuration ready.")
message(STATUS "========================================================")
