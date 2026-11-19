#pragma once

#include "ai_provider.hpp"
#include "transport.hpp"
#include "key_store.hpp"
#include <memory>
#include <string>
#include <vector>

namespace sritec::ai {

class ClaudeProvider : public AIProvider {
public:
    explicit ClaudeProvider(std::shared_ptr<ITransport> transport = nullptr);
    ~ClaudeProvider() override;

    ProviderType type() const override { return ProviderType::Claude; }
    std::string providerName() const override { return "Anthropic Claude"; }
    std::string currentModel() const override { return m_currentModel; }
    std::vector<std::string> availableModels() const override {
        return {"claude-3-5-sonnet-20241022", "claude-3-5-haiku-20241022", "claude-3-opus-20240229"};
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

    static std::string buildPayload(const std::string& model, const std::vector<ChatMessage>& history);
    static std::string parseSseChunk(const std::string& chunk);

private:
    std::string m_currentModel{"claude-3-5-sonnet-20241022"};
    std::shared_ptr<ITransport> m_transport;
};

} // namespace sritec::ai
