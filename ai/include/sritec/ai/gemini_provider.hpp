#pragma once

#include "ai_provider.hpp"
#include "transport.hpp"
#include "key_store.hpp"
#include <memory>
#include <string>
#include <vector>

namespace sritec::ai {

class GeminiProvider : public AIProvider {
public:
    explicit GeminiProvider(std::shared_ptr<ITransport> transport = nullptr);
    ~GeminiProvider() override;

    ProviderType type() const override { return ProviderType::Gemini; }
    std::string providerName() const override { return "Google Gemini"; }
    std::string currentModel() const override { return m_currentModel; }
    std::vector<std::string> availableModels() const override {
        return {"gemini-2.0-flash", "gemini-1.5-pro", "gemini-1.5-flash"};
    }
    void setModel(const std::string& modelId) override { m_currentModel = modelId; }

    void streamChat(
        const std::vector<ChatMessage>& history,
        TokenCallback onToken,
        ErrorCallback onError,
        CompleteCallback onComplete
    ) override;

    void cancel() override;
    ProviderHealth health() const override;

    // Helper to format payload and parse SSE stream (exposed for unit testing)
    static std::string buildPayload(const std::vector<ChatMessage>& history);
    static std::string parseSseChunk(const std::string& chunk);

private:
    std::string m_currentModel{"gemini-2.0-flash"};
    std::shared_ptr<ITransport> m_transport;
};

} // namespace sritec::ai
