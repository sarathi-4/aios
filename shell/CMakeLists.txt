add_executable(sritec-shell
    src/main.cpp
    src/app_launcher.cpp
    src/app_launcher.hpp
    src/app_launch_manager.cpp
    src/app_launch_manager.hpp
    src/desktop_manager.cpp
    src/desktop_manager.hpp
    src/nebula_file_manager.cpp
    src/nebula_file_manager.hpp
    src/nebula_terminal_backend.cpp
    src/nebula_terminal_backend.hpp
    src/nebula_dev_workspace.cpp
    src/nebula_dev_workspace.hpp
    src/nebula_browser_backend.cpp
    src/nebula_browser_backend.hpp
    src/nebula_dev_workstation.cpp
    src/nebula_dev_workstation.hpp
    src/nebula_audio_service.cpp
    src/nebula_audio_service.hpp
    src/nebula_screen_capture_service.cpp
    src/nebula_screen_capture_service.hpp
    src/nebula_power_manager.cpp
    src/nebula_power_manager.hpp
    resources.qrc
)

target_include_directories(sritec-shell
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/jarvis
        ${CMAKE_SOURCE_DIR}/jarvis/core
        ${CMAKE_SOURCE_DIR}/jarvis/security
        ${CMAKE_SOURCE_DIR}/jarvis/wakeword
        ${CMAKE_SOURCE_DIR}/jarvis/voice
        ${CMAKE_SOURCE_DIR}/jarvis/speech
        ${CMAKE_SOURCE_DIR}/jarvis/intent
        ${CMAKE_SOURCE_DIR}/jarvis/vision
        ${CMAKE_SOURCE_DIR}/jarvis/gestures
        ${CMAKE_SOURCE_DIR}/jarvis/actions
        ${CMAKE_SOURCE_DIR}/jarvis/settings
)

target_link_libraries(sritec-shell
    PRIVATE
        sritec_core
        sritec_ai
        sritec_jarvis
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
)

target_compile_features(sritec-shell PRIVATE cxx_std_20)
sritec_set_target_warnings(sritec-shell)

# Ensure executable output in bin/
set_target_properties(sritec-shell PROPERTIES
    OUTPUT_NAME "sritec-shell"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
