#pragma once

#include "ai_provider.hpp"
#include <thread>
#include <mutex>
#include <atomic>
#include <string>
#include <vector>

namespace sritec::ai {

class MockAIProvider : public AIProvider {
public:
    MockAIProvider();
    ~MockAIProvider() override;

    ProviderType type() const override { return ProviderType::Mock; }
    std::string providerName() const override { return "SRITEC Neural Core (Simulated)"; }
    std::string currentModel() const override { return m_currentModel; }
    std::vector<std::string> availableModels() const override {
        return {"sritec-mock-v1", "sritec-neural-fast", "sritec-coder-mock"};
    }
    void setModel(const std::string& modelId) override { m_currentModel = modelId; }

    // Phase 1 Backward Compatibility
    void streamQuery(
        const std::string& prompt,
        const std::string& context,
        TokenCallback onToken
    ) override;

    // Phase 2.1 Multi-Turn Chat
    void streamChat(
        const std::vector<ChatMessage>& history,
        TokenCallback onToken,
        ErrorCallback onError,
        CompleteCallback onComplete
    ) override;

    void cancel() override;
    bool isStreaming() const;
    ProviderHealth health() const override;

private:
    std::string m_currentModel{"sritec-mock-v1"};
    mutable std::mutex m_threadMutex;
    std::jthread m_workerThread;
    std::atomic<bool> m_isStreaming{false};

    std::string generateSimulatedResponse(const std::string& prompt) const;
};

} // namespace sritec::ai
