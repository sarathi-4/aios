# ==============================================================================
# SRITEC AI OS — Test Suite
# ==============================================================================

# 1. Core Logger & Timestamp Tests
add_executable(test_core
    unit/test_core.cpp
)

target_link_libraries(test_core
    PRIVATE
        sritec_core
)

target_compile_features(test_core PRIVATE cxx_std_20)
sritec_set_target_warnings(test_core)
add_test(NAME CoreLoggerTimestampTest COMMAND test_core)

# 2. AI Safety, Stream Cancellation & Concurrency Tests (Qt6Core-dependent)
if(Qt6Core_FOUND)
    add_executable(test_ai_safety
        unit/test_ai_safety.cpp
    )

    target_link_libraries(test_ai_safety
        PRIVATE
            sritec_core
            sritec_ai
            Qt6::Core
    )

    target_compile_features(test_ai_safety PRIVATE cxx_std_20)
    sritec_set_target_warnings(test_ai_safety)
    add_test(NAME AISafetyAndStreamTest COMMAND test_ai_safety)
endif()

# 3. Phase 2.1 Unified AI Provider Gateway Tests (Qt6Network-dependent)
if(Qt6Core_FOUND AND Qt6Network_FOUND)
    add_executable(test_provider_gateway
        unit/test_provider_gateway.cpp
    )

    target_link_libraries(test_provider_gateway
        PRIVATE
            sritec_core
            sritec_ai
            Qt6::Core
            Qt6::Network
    )

    target_compile_features(test_provider_gateway PRIVATE cxx_std_20)
    sritec_set_target_warnings(test_provider_gateway)
    add_test(NAME AIProviderGatewayTest COMMAND test_provider_gateway)

    # 4. Phase 2.2 Security, Secret Redaction, TLS & Resilience Tests
    add_executable(test_security_and_resilience
        unit/test_security_and_resilience.cpp
    )

    target_link_libraries(test_security_and_resilience
        PRIVATE
            sritec_core
            sritec_ai
            Qt6::Core
            Qt6::Network
    )

    target_compile_features(test_security_and_resilience PRIVATE cxx_std_20)
    sritec_set_target_warnings(test_security_and_resilience)
    add_test(NAME SecurityAndResilienceTest COMMAND test_security_and_resilience)

    # 5. Live Smoke Test Runner (Standalone binary; NOT run automatically by CTest)
    add_executable(test_live_smoke
        smoke/test_live_smoke.cpp
    )

    target_link_libraries(test_live_smoke
        PRIVATE
            sritec_core
            sritec_ai
            Qt6::Core
            Qt6::Network
    )

    target_compile_features(test_live_smoke PRIVATE cxx_std_20)
    sritec_set_target_warnings(test_live_smoke)

    # 6. Milestone 3.2 Desktop Experience Unit Test Suite
    add_executable(test_desktop_system
        unit/test_desktop_system.cpp
        ../shell/src/desktop_manager.cpp
        ../shell/src/desktop_manager.hpp
    )

    target_include_directories(test_desktop_system
        PRIVATE
            ${CMAKE_SOURCE_DIR}/shell/src
            ${CMAKE_SOURCE_DIR}/core/include
            ${CMAKE_SOURCE_DIR}/ai/include
    )

    target_link_libraries(test_desktop_system
        PRIVATE
            sritec_core
            sritec_ai
            Qt6::Core
    )

    target_compile_features(test_desktop_system PRIVATE cxx_std_20)
    sritec_set_target_warnings(test_desktop_system)
    add_test(NAME DesktopSystemTest COMMAND test_desktop_system)

    # 7. Milestone 3.4 Universal App Launch Manager & Internal Ecosystem Test Suite
    add_executable(test_app_launch
        unit/test_app_launch.cpp
        ../shell/src/app_launch_manager.cpp
        ../shell/src/app_launch_manager.hpp
        ../shell/src/app_launcher.cpp
        ../shell/src/app_launcher.hpp
        ../shell/src/desktop_manager.cpp
        ../shell/src/desktop_manager.hpp
        ../shell/src/nebula_file_manager.cpp
        ../shell/src/nebula_file_manager.hpp
        ../shell/src/nebula_terminal_backend.cpp
        ../shell/src/nebula_terminal_backend.hpp
        ../shell/src/nebula_dev_workspace.cpp
        ../shell/src/nebula_dev_workspace.hpp
        ../shell/src/nebula_browser_backend.cpp
        ../shell/src/nebula_browser_backend.hpp
        ../shell/src/nebula_dev_workstation.cpp
        ../shell/src/nebula_dev_workstation.hpp
        ../shell/src/nebula_audio_service.cpp
        ../shell/src/nebula_audio_service.hpp
        ../shell/src/nebula_screen_capture_service.cpp
        ../shell/src/nebula_screen_capture_service.hpp
        ../shell/src/nebula_power_manager.cpp
        ../shell/src/nebula_power_manager.hpp
    )

    target_include_directories(test_app_launch
        PRIVATE
            ${CMAKE_SOURCE_DIR}/shell/src
            ${CMAKE_SOURCE_DIR}/core/include
            ${CMAKE_SOURCE_DIR}/ai/include
    )

    target_link_libraries(test_app_launch
        PRIVATE
            sritec_core
            sritec_ai
            Qt6::Core
            Qt6::Gui
            Qt6::Quick
    )

    target_compile_features(test_app_launch PRIVATE cxx_std_20)
    sritec_set_target_warnings(test_app_launch)
    add_test(NAME AppLaunchManagerTest COMMAND test_app_launch)
    set_tests_properties(AppLaunchManagerTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

    # 8. Section 25 — JARVIS AI Voice and Vision System Tests
    add_executable(test_jarvis_system
        ../jarvis/tests/test_jarvis_system.cpp
        ../shell/src/app_launcher.cpp
        ../shell/src/app_launcher.hpp
        ../shell/src/app_launch_manager.cpp
        ../shell/src/app_launch_manager.hpp
        ../shell/src/desktop_manager.cpp
        ../shell/src/desktop_manager.hpp
        ../shell/src/nebula_file_manager.cpp
        ../shell/src/nebula_file_manager.hpp
        ../shell/src/nebula_terminal_backend.cpp
        ../shell/src/nebula_terminal_backend.hpp
        ../shell/src/nebula_dev_workspace.cpp
        ../shell/src/nebula_dev_workspace.hpp
        ../shell/src/nebula_browser_backend.cpp
        ../shell/src/nebula_browser_backend.hpp
        ../shell/src/nebula_dev_workstation.cpp
        ../shell/src/nebula_dev_workstation.hpp
        ../shell/src/nebula_audio_service.cpp
        ../shell/src/nebula_audio_service.hpp
        ../shell/src/nebula_screen_capture_service.cpp
        ../shell/src/nebula_screen_capture_service.hpp
        ../shell/src/nebula_power_manager.cpp
        ../shell/src/nebula_power_manager.hpp
    )

    target_include_directories(test_jarvis_system
        PRIVATE
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
            ${CMAKE_SOURCE_DIR}/shell/src
            ${CMAKE_SOURCE_DIR}/core/include
            ${CMAKE_SOURCE_DIR}/ai/include
    )

    target_link_libraries(test_jarvis_system
        PRIVATE
            sritec_core
            sritec_ai
            sritec_jarvis
            Qt6::Core
            Qt6::Gui
            Qt6::Quick
    )

    target_compile_features(test_jarvis_system PRIVATE cxx_std_20)
    sritec_set_target_warnings(test_jarvis_system)
    add_test(NAME JarvisVoiceAndVisionTest COMMAND test_jarvis_system)
    set_tests_properties(JarvisVoiceAndVisionTest PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")
endif()
