#include "sritec/ai/key_store.hpp"
#include "sritec/ai/transport.hpp"
#include "sritec/ai/gemini_provider.hpp"
#include "sritec/ai/openai_provider.hpp"
#include "sritec/ai/claude_provider.hpp"
#include "sritec/ai/ollama_provider.hpp"
#include "sritec/ai/provider_manager.hpp"
#include "sritec/ai/ai_bridge.hpp"
#include "sritec/logger.hpp"

#include <iostream>
#include <cassert>
#include <string>
#include <vector>
#include <atomic>
#include <chrono>
#include <thread>

using namespace sritec::ai;

void testSecretRedaction() {
    std::cout << "[TEST] 1. Verifying Secret Redaction & Memory Cleansing...\n";

    // A. Pattern-based sanitization in Logger
    std::string geminiLog = "Connecting with key AIzaSyD4e5F6g7H8i9J0k1L2m3N4o5P6q7R8s9T";
    std::string sanitizedGemini = sritec::Logger::sanitize(geminiLog);
    assert(sanitizedGemini.find("AIzaSy") == std::string::npos);
    assert(sanitizedGemini.find("[REDACTED_API_KEY]") != std::string::npos);

    std::string openaiLog = "OpenAI request auth header: Bearer sk-proj-1234567890abcdefghijklmnopqrstuvwxyz";
    std::string sanitizedOpenai = sritec::Logger::sanitize(openaiLog);
    assert(sanitizedOpenai.find("sk-proj-1234567890") == std::string::npos);
    assert(sanitizedOpenai.find("[REDACTED_API_KEY]") != std::string::npos || sanitizedOpenai.find("[REDACTED_TOKEN]") != std::string::npos);

    std::string claudeLog = "Claude header x-api-key: sk-ant-api03-abcdefghijklmnopqrstuvwxyz12345678";
    std::string sanitizedClaude = sritec::Logger::sanitize(claudeLog);
    assert(sanitizedClaude.find("sk-ant-") == std::string::npos);
    assert(sanitizedClaude.find("[REDACTED_API_KEY]") != std::string::npos);

    // B. KeyStore exact-match scrubbing
    std::string secretKey = "super-secret-test-enterprise-token-xyz999";
    KeyStore::instance().setKey(ProviderType::OpenAI, secretKey);

    std::string errorWithSecret = "Request failed to endpoint https://api.openai.com with key super-secret-test-enterprise-token-xyz999 (rejected)";
    std::string scrubbed = KeyStore::instance().redact(errorWithSecret);
    assert(scrubbed.find(secretKey) == std::string::npos);
    assert(scrubbed.find("[REDACTED_API_KEY]") != std::string::npos);

    // C. Secure Memory Cleansing
    std::string secretMemory = "transient-secret-in-memory-to-be-cleansed";
    KeyStore::secureCleanse(secretMemory);
    assert(secretMemory.empty());

    KeyStore::instance().clearAll();
    assert(!KeyStore::instance().hasKey(ProviderType::OpenAI));

    std::cout << "       [✓] Secret redaction and secure cleansing verified.\n";
}

void testTlsFailureHandling() {
    std::cout << "[TEST] 2. Verifying TLS Failure Handling...\n";

    auto mockTransport = std::make_shared<MockHttpTransport>();
    mockTransport->setSimulatedLatencyMs(5);
    // Code 495: SSL Certificate Error
    mockTransport->setSimulatedResponse(495, {}, "TLS Verification Failed: Certificate has expired or self-signed");

    GeminiProvider provider(mockTransport);
    KeyStore::instance().setKey(ProviderType::Gemini, "dummy-test-key");

    std::atomic<bool> errorReported{false};
    int receivedCode = 0;
    std::string receivedMsg;

    std::vector<ChatMessage> history = {{MessageRole::User, "Hello"}};
    provider.streamChat(
        history,
        [](const std::string&, bool) {},
        [&](int code, const std::string& msg) {
            errorReported = true;
            receivedCode = code;
            receivedMsg = msg;
        },
        []() {}
    );

    int waitCount = 0;
    while (!errorReported && waitCount++ < 50) {
        std::this_thread::sleep_for(std::chrono::milliseconds(5));
    }

    assert(errorReported);
    assert(receivedCode == 495);
    assert(receivedMsg.find("TLS Verification Failed") != std::string::npos);

    KeyStore::instance().clearAll();
    std::cout << "       [✓] Strict TLS certificate failure handling verified.\n";
}

void testInvalidCredentials() {
    std::cout << "[TEST] 3. Verifying Invalid Credentials (401 Unauthorized)...\n";

    auto mockTransport = std::make_shared<MockHttpTransport>();
    mockTransport->setSimulatedLatencyMs(5);
    mockTransport->setSimulatedResponse(401, {}, "HTTP 401 Unauthorized: Invalid API Key sk-proj-badkey1234567890abcdef");

    ClaudeProvider provider(mockTransport);
    KeyStore::instance().setKey(ProviderType::Claude, "sk-proj-badkey1234567890abcdef");

    std::atomic<bool> errorReported{false};
    int receivedCode = 0;
    std::string receivedMsg;

    std::vector<ChatMessage> history = {{MessageRole::User, "Test query"}};
    provider.streamChat(
        history,
        [](const std::string&, bool) {},
        [&](int code, const std::string& msg) {
            errorReported = true;
            receivedCode = code;
            receivedMsg = msg;
        },
        []() {}
    );

    int waitCount = 0;
    while (!errorReported && waitCount++ < 50) {
        std::this_thread::sleep_for(std::chrono::milliseconds(5));
    }

    assert(errorReported);
    assert(receivedCode == 401);
    // Redaction must scrub the bad key from the error message
    assert(receivedMsg.find("sk-proj-badkey") == std::string::npos);

    KeyStore::instance().clearAll();
    std::cout << "       [✓] Invalid credentials reporting and key redaction verified.\n";
}

void testNetworkDisconnect() {
    std::cout << "[TEST] 4. Verifying Network Disconnect & Timeout Handling...\n";

    auto mockTransport = std::make_shared<MockHttpTransport>();
    mockTransport->setSimulatedLatencyMs(5);
    // Simulate connection refused / service unavailable
    mockTransport->setSimulatedResponse(503, {}, "Connection refused by peer (Network unreachable)");

    OpenAIProvider provider(mockTransport);
    KeyStore::instance().setKey(ProviderType::OpenAI, "dummy-openai-key");

    std::atomic<bool> errorReported{false};
    int receivedCode = 0;

    std::vector<ChatMessage> history = {{MessageRole::User, "Hello"}};
    provider.streamChat(
        history,
        [](const std::string&, bool) {},
        [&](int code, const std::string&) {
            errorReported = true;
            receivedCode = code;
        },
        []() {}
    );

    int waitCount = 0;
    while (!errorReported && waitCount++ < 50) {
        std::this_thread::sleep_for(std::chrono::milliseconds(5));
    }

    assert(errorReported);
    assert(receivedCode == 503);

    KeyStore::instance().clearAll();
    std::cout << "       [✓] Network disconnect handling verified.\n";
}

void testRequestCancellation() {
    std::cout << "[TEST] 5. Verifying Stream Cancellation...\n";

    auto mockTransport = std::make_shared<MockHttpTransport>();
    mockTransport->setSimulatedLatencyMs(20);
    mockTransport->setSimulatedResponse(200, {
        "data: {\"choices\":[{\"delta\":{\"content\":\"Chunk 1\"}}]}\n\n",
        "data: {\"choices\":[{\"delta\":{\"content\":\"Chunk 2\"}}]}\n\n",
        "data: {\"choices\":[{\"delta\":{\"content\":\"Chunk 3\"}}]}\n\n",
        "data: [DONE]\n\n"
    });

    OpenAIProvider provider(mockTransport);
    KeyStore::instance().setKey(ProviderType::OpenAI, "dummy-openai-key");

    std::atomic<int> tokenCount{0};
    std::vector<ChatMessage> history = {{MessageRole::User, "Long prompt"}};

    provider.streamChat(
        history,
        [&](const std::string& token, bool) {
            if (!token.empty()) {
                tokenCount++;
            }
        },
        [](int, const std::string&) {},
        []() {}
    );

    // Let it emit 1 chunk then cancel
    std::this_thread::sleep_for(std::chrono::milliseconds(30));
    provider.cancel();

    int tokensAtCancel = tokenCount.load();
    std::this_thread::sleep_for(std::chrono::milliseconds(50));
    // After cancel, no further chunks should be received
    assert(tokenCount.load() == tokensAtCancel);
    assert(!mockTransport->isBusy());

    KeyStore::instance().clearAll();
    std::cout << "       [✓] Request cancellation and thread join verified.\n";
}

void testProviderSwitching() {
    std::cout << "[TEST] 6. Verifying Dynamic Provider & Model Switching...\n";

    auto mockTransport = std::make_shared<MockHttpTransport>();
    ProviderManager mgr(mockTransport);

    // Initial state: Mock
    assert(mgr.activeProviderType() == ProviderType::Mock);
    assert(mgr.activeModel() == "sritec-mock-v1");

    // Switch to Gemini
    assert(mgr.selectProvider("Google Gemini"));
    assert(mgr.activeProviderType() == ProviderType::Gemini);
    assert(mgr.activeModel() == "gemini-2.0-flash");
    assert(mgr.selectModel("gemini-1.5-pro"));
    assert(mgr.activeModel() == "gemini-1.5-pro");

    // Switch to OpenAI
    assert(mgr.selectProvider("OpenAI"));
    assert(mgr.activeProviderType() == ProviderType::OpenAI);
    assert(mgr.activeModel() == "gpt-4o");

    // Switch to Claude
    assert(mgr.selectProvider("Anthropic Claude"));
    assert(mgr.activeProviderType() == ProviderType::Claude);
    assert(mgr.activeModel() == "claude-3-5-sonnet-20241022");

    // Switch to Ollama
    assert(mgr.selectProvider("Local AI (Ollama)"));
    assert(mgr.activeProviderType() == ProviderType::Ollama);
    assert(mgr.activeModel() == "llama3.2");

    std::cout << "       [✓] Provider and model switching verified.\n";
}

void testLocalAiUnavailable() {
    std::cout << "[TEST] 7. Verifying Local AI (Ollama) Unavailable Handling...\n";

    auto mockTransport = std::make_shared<MockHttpTransport>();
    mockTransport->setSimulatedLatencyMs(5);
    // Simulate connection refused on localhost:11434
    mockTransport->setSimulatedResponse(503, {}, "Connection refused: localhost:11434");

    OllamaProvider provider(mockTransport);

    std::atomic<bool> errorReported{false};
    int receivedCode = 0;
    std::string receivedError;

    std::vector<ChatMessage> history = {{MessageRole::User, "Hello local model"}};
    provider.streamChat(
        history,
        [](const std::string&, bool) {},
        [&](int code, const std::string& err) {
            errorReported = true;
            receivedCode = code;
            receivedError = err;
        },
        []() {}
    );

    int waitCount = 0;
    while (!errorReported && waitCount++ < 50) {
        std::this_thread::sleep_for(std::chrono::milliseconds(5));
    }

    assert(errorReported);
    assert(receivedCode == 503);
    assert(receivedError.find("Connection refused") != std::string::npos);

    std::cout << "       [✓] Local AI unavailable handled gracefully.\n";
}

void testSecureFallbackToMock() {
    std::cout << "[TEST] 8. Verifying Secure Fallback to Mock Provider...\n";

    auto mockTransport = std::make_shared<MockHttpTransport>();
    ProviderManager mgr(mockTransport);

    // Select Claude without API key -> fails
    mgr.selectProvider("Anthropic Claude");
    assert(!mgr.hasKeyForActiveProvider());

    std::atomic<bool> errorReported{false};
    mgr.appendUserMessage("Test query without credentials");
    mgr.stream(
        [](const std::string&, bool) {},
        [&](int code, const std::string&) {
            if (code == 401) {
                errorReported = true;
            }
        },
        []() {}
    );

    assert(errorReported);

    // Fallback to Mock Provider
    assert(mgr.selectProvider("Mock"));
    assert(mgr.hasKeyForActiveProvider());

    std::atomic<bool> streamFinished{false};
    std::string response;

    mgr.stream(
        [&](const std::string& token, bool finished) {
            response += token;
            if (finished) streamFinished = true;
        },
        [](int, const std::string&) {},
        [&]() { streamFinished = true; }
    );

    int waitCount = 0;
    while (!streamFinished && waitCount++ < 100) {
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }

    assert(streamFinished);
    assert(!response.empty());

    std::cout << "       [✓] Secure fallback to Mock provider verified.\n";
}

int main() {
    std::cout << "======================================================\n";
    std::cout << "  SRITEC Security & Resilience Unit Test Suite\n";
    std::cout << "======================================================\n";

    testSecretRedaction();
    testTlsFailureHandling();
    testInvalidCredentials();
    testNetworkDisconnect();
    testRequestCancellation();
    testProviderSwitching();
    testLocalAiUnavailable();
    testSecureFallbackToMock();

    std::cout << "======================================================\n";
    std::cout << "  [✓] All Security & Resilience Tests Passed!\n";
    std::cout << "======================================================\n";
    return 0;
}
