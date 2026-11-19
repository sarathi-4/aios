#include "sritec/ai/provider_manager.hpp"
#include "sritec/ai/ai_bridge.hpp"
#include "sritec/ai/key_store.hpp"
#include "sritec/ai/transport.hpp"
#include "sritec/ai/gemini_provider.hpp"
#include "sritec/ai/openai_provider.hpp"
#include "sritec/ai/claude_provider.hpp"
#include "sritec/ai/ollama_provider.hpp"

#include <cassert>
#include <iostream>
#include <memory>
#include <atomic>
#include <chrono>
#include <thread>

void test_provider_registry_and_models() {
    std::cout << "[TEST] 1. Verifying Provider Registry and Model Switching..." << std::endl;

    auto transport = std::make_shared<sritec::ai::MockHttpTransport>();
    sritec::ai::ProviderManager manager(transport);

    // Default provider must be Mock
    assert(manager.activeProviderType() == sritec::ai::ProviderType::Mock);
    assert(manager.activeProviderName() == "SRITEC Neural Core (Simulated)");

    // Switch to Gemini
    assert(manager.selectProvider("Gemini"));
    assert(manager.activeProviderType() == sritec::ai::ProviderType::Gemini);
    auto geminiModels = manager.availableModels();
    assert(!geminiModels.empty());
    assert(manager.selectModel("gemini-1.5-pro"));
    assert(manager.activeModel() == "gemini-1.5-pro");

    // Switch to OpenAI
    assert(manager.selectProvider("OpenAI"));
    assert(manager.activeProviderType() == sritec::ai::ProviderType::OpenAI);
    assert(manager.selectModel("gpt-4o-mini"));
    assert(manager.activeModel() == "gpt-4o-mini");

    // Switch to Claude
    assert(manager.selectProvider("Claude"));
    assert(manager.activeProviderType() == sritec::ai::ProviderType::Claude);
    assert(manager.selectModel("claude-3-5-haiku-20241022"));

    // Switch to Ollama
    assert(manager.selectProvider("Ollama"));
    assert(manager.activeProviderType() == sritec::ai::ProviderType::Ollama);

    // Switch back to Mock
    assert(manager.selectProvider(sritec::ai::ProviderType::Mock));
    assert(manager.activeProviderType() == sritec::ai::ProviderType::Mock);

    std::cout << "       [✓] Provider registry and model switching verified." << std::endl;
}

void test_mock_http_streaming_and_parsing() {
    std::cout << "[TEST] 2. Verifying Mock HTTP SSE Streaming across Providers..." << std::endl;

    auto mockTransport = std::make_shared<sritec::ai::MockHttpTransport>();

    // Test Gemini SSE Parsing
    std::string geminiChunk = "data: {\"candidates\":[{\"content\":{\"parts\":[{\"text\":\"Hello Gemini\"}]}}]}\n\n";
    std::string parsedGemini = sritec::ai::GeminiProvider::parseSseChunk(geminiChunk);
    assert(parsedGemini == "Hello Gemini");

    // Test OpenAI SSE Parsing
    std::string openAiChunk = "data: {\"choices\":[{\"delta\":{\"content\":\"Hello OpenAI\"}}]}\n\n";
    bool isDone = false;
    std::string parsedOpenAI = sritec::ai::OpenAIProvider::parseSseChunk(openAiChunk, &isDone);
    assert(parsedOpenAI == "Hello OpenAI");
    assert(!isDone);

    sritec::ai::OpenAIProvider::parseSseChunk("data: [DONE]\n\n", &isDone);
    assert(isDone);

    // Test Claude SSE Parsing
    std::string claudeChunk = "event: content_block_delta\ndata: {\"type\":\"content_block_delta\",\"delta\":{\"type\":\"text_delta\",\"text\":\"Hello Claude\"}}\n\n";
    std::string parsedClaude = sritec::ai::ClaudeProvider::parseSseChunk(claudeChunk);
    assert(parsedClaude == "Hello Claude");

    // Test Streaming via Gemini with MockHttpTransport
    mockTransport->setSimulatedResponse(200, {geminiChunk});
    sritec::ai::KeyStore::instance().setKey(sritec::ai::ProviderType::Gemini, "test-gemini-key");

    sritec::ai::GeminiProvider gemini(mockTransport);
    std::atomic<bool> tokenReceived{false};
    std::atomic<bool> streamCompleted{false};

    std::vector<sritec::ai::ChatMessage> history = {
        {sritec::ai::MessageRole::User, "Hi", "", 0}
    };

    gemini.streamChat(history,
        [&tokenReceived](const std::string& token, bool) {
            if (token == "Hello Gemini") tokenReceived = true;
        },
        [](int, const std::string&) {},
        [&streamCompleted]() {
            streamCompleted = true;
        }
    );

    std::this_thread::sleep_for(std::chrono::milliseconds(50));
    assert(tokenReceived.load());
    assert(streamCompleted.load());

    std::cout << "       [✓] Mock HTTP SSE streaming and payload parsing verified." << std::endl;
}

void test_error_and_timeout_handling() {
    std::cout << "[TEST] 3. Verifying HTTP Error (401, 429, 504) Handling..." << std::endl;

    auto mockTransport = std::make_shared<sritec::ai::MockHttpTransport>();
    sritec::ai::KeyStore::instance().setKey(sritec::ai::ProviderType::OpenAI, "test-openai-key");

    // Test 401 Unauthorized
    mockTransport->setSimulatedResponse(401, {}, "Incorrect API key provided");
    sritec::ai::OpenAIProvider openai(mockTransport);

    std::atomic<int> errorCode{0};
    std::string errorString;

    std::vector<sritec::ai::ChatMessage> history = {
        {sritec::ai::MessageRole::User, "Ping", "", 0}
    };

    openai.streamChat(history,
        [](const std::string&, bool) {},
        [&errorCode, &errorString](int code, const std::string& msg) {
            errorCode = code;
            errorString = msg;
        },
        []() {}
    );

    std::this_thread::sleep_for(std::chrono::milliseconds(30));
    assert(errorCode.load() == 401);
    assert(errorString.find("Incorrect API key") != std::string::npos);

    // Test 429 Rate Limit
    mockTransport->setSimulatedResponse(429, {}, "Rate limit exceeded");
    openai.streamChat(history,
        [](const std::string&, bool) {},
        [&errorCode, &errorString](int code, const std::string& msg) {
            errorCode = code;
            errorString = msg;
        },
        []() {}
    );

    std::this_thread::sleep_for(std::chrono::milliseconds(30));
    assert(errorCode.load() == 429);

    // Test 504 Gateway Timeout
    mockTransport->setSimulatedResponse(504, {}, "Gateway Timeout");
    openai.streamChat(history,
        [](const std::string&, bool) {},
        [&errorCode, &errorString](int code, const std::string& msg) {
            errorCode = code;
            errorString = msg;
        },
        []() {}
    );

    std::this_thread::sleep_for(std::chrono::milliseconds(30));
    assert(errorCode.load() == 504);

    std::cout << "       [✓] HTTP Error and Timeout handling (401, 429, 504) verified." << std::endl;
}

void test_api_key_isolation() {
    std::cout << "[TEST] 4. Verifying API Key Isolation & QML Security..." << std::endl;

    auto& ks = sritec::ai::KeyStore::instance();
    ks.clearKey(sritec::ai::ProviderType::Claude);
    assert(!ks.hasKey(sritec::ai::ProviderType::Claude));

    ks.setKey(sritec::ai::ProviderType::Claude, "sk-ant-test-secret-12345");
    assert(ks.hasKey(sritec::ai::ProviderType::Claude));

    // Verify key matches what was stored internally
    assert(ks.getKey(sritec::ai::ProviderType::Claude) == "sk-ant-test-secret-12345");

    // Verify AIBridge isolation:
    // AIBridge only exposes hasApiKey() returning boolean
    auto transport = std::make_shared<sritec::ai::MockHttpTransport>();
    sritec::ai::AIBridge bridge(nullptr, transport);
    bridge.selectProvider("Claude");
    assert(bridge.hasApiKey() == true);

    ks.clearKey(sritec::ai::ProviderType::Claude);
    bridge.selectProvider("Claude");
    assert(bridge.hasApiKey() == false);

    std::cout << "       [✓] API Key isolation verified (Backend isolated, frontend receives boolean only)." << std::endl;
}

void test_conversation_history_context() {
    std::cout << "[TEST] 5. Verifying Conversation History Context Retention..." << std::endl;

    auto transport = std::make_shared<sritec::ai::MockHttpTransport>();
    sritec::ai::ProviderManager manager(transport);

    manager.appendUserMessage("What is SRITEC AI OS?");
    manager.appendAssistantMessage("SRITEC AI OS is an AI-native company operating system.");
    manager.appendUserMessage("What is its kernel foundation?");

    const auto& history = manager.history();
    assert(history.size() == 3);
    assert(history[0].role == sritec::ai::MessageRole::User);
    assert(history[1].role == sritec::ai::MessageRole::Assistant);
    assert(history[2].role == sritec::ai::MessageRole::User);

    manager.clearHistory();
    assert(manager.history().empty());

    std::cout << "       [✓] Conversation history context retention verified." << std::endl;
}

int main() {
    std::cout << "======================================================" << std::endl;
    std::cout << "  SRITEC AI Provider Gateway Unit Test Suite" << std::endl;
    std::cout << "======================================================" << std::endl;

    test_provider_registry_and_models();
    test_mock_http_streaming_and_parsing();
    test_error_and_timeout_handling();
    test_api_key_isolation();
    test_conversation_history_context();

    std::cout << "======================================================" << std::endl;
    std::cout << "  [✓] All Phase 2.1 Provider Gateway Tests Passed!" << std::endl;
    std::cout << "======================================================" << std::endl;
    return 0;
}
