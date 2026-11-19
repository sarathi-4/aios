add_library(sritec_ai STATIC
    include/sritec/ai/chat_message.hpp
    include/sritec/ai/key_store.hpp
    include/sritec/ai/transport.hpp
    include/sritec/ai/ai_provider.hpp
    include/sritec/ai/mock_provider.hpp
    include/sritec/ai/gemini_provider.hpp
    include/sritec/ai/openai_provider.hpp
    include/sritec/ai/claude_provider.hpp
    include/sritec/ai/ollama_provider.hpp
    include/sritec/ai/provider_manager.hpp
    include/sritec/ai/ai_bridge.hpp
    src/key_store.cpp
    src/transport.cpp
    src/mock_provider.cpp
    src/gemini_provider.cpp
    src/openai_provider.cpp
    src/claude_provider.cpp
    src/ollama_provider.cpp
    src/provider_manager.cpp
    src/ai_bridge.cpp
)

target_include_directories(sritec_ai
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(sritec_ai
    PUBLIC
        sritec_core
        Qt6::Core
        Qt6::Network
)

target_compile_features(sritec_ai PUBLIC cxx_std_20)
sritec_set_target_warnings(sritec_ai)
