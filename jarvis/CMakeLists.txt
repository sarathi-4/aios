# ==============================================================================
# SRITEC AI OS — JARVIS Multimodal Voice & Vision Subsystem
# ==============================================================================

add_library(sritec_jarvis STATIC
    core/jarvis_types.hpp
    core/jarvis_engine.hpp
    core/jarvis_engine.cpp
    security/jarvis_security_manager.hpp
    security/jarvis_security_manager.cpp
    wakeword/wakeword_detector.hpp
    wakeword/wakeword_detector.cpp
    voice/voice_system.hpp
    voice/voice_system.cpp
    speech/speech_recognizer.hpp
    speech/speech_recognizer.cpp
    intent/intent_recognizer.hpp
    intent/intent_recognizer.cpp
    vision/camera_service.hpp
    vision/camera_service.cpp
    gestures/gesture_recognizer.hpp
    gestures/gesture_recognizer.cpp
    actions/action_dispatcher.hpp
    actions/action_dispatcher.cpp
    settings/jarvis_settings.hpp
    settings/jarvis_settings.cpp
)

target_include_directories(sritec_jarvis
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/core
        ${CMAKE_CURRENT_SOURCE_DIR}/security
        ${CMAKE_CURRENT_SOURCE_DIR}/wakeword
        ${CMAKE_CURRENT_SOURCE_DIR}/voice
        ${CMAKE_CURRENT_SOURCE_DIR}/speech
        ${CMAKE_CURRENT_SOURCE_DIR}/intent
        ${CMAKE_CURRENT_SOURCE_DIR}/vision
        ${CMAKE_CURRENT_SOURCE_DIR}/gestures
        ${CMAKE_CURRENT_SOURCE_DIR}/actions
        ${CMAKE_CURRENT_SOURCE_DIR}/settings
        ${CMAKE_SOURCE_DIR}/shell/src
)

target_link_libraries(sritec_jarvis
    PUBLIC
        sritec_core
        sritec_ai
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
)

target_compile_features(sritec_jarvis PUBLIC cxx_std_20)
sritec_set_target_warnings(sritec_jarvis)
