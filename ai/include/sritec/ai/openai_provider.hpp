#pragma once

#include "ai_provider.hpp"
#include "transport.hpp"
#include "key_store.hpp"
#include <memory>
#include <string>
#include <vector>

namespace sritec::ai {

class OpenAIProvider : public AIProvider {
public:
    explicit OpenAIProvider(std::shared_ptr<ITransport> transport = nullptr);
    ~OpenAIProvider() override;

    ProviderType type() const override { return ProviderType::OpenAI; }
    std::string providerName() const override { return "OpenAI"; }
    std::string currentModel() const override { return m_currentModel; }
    std::vector<std::string> availableModels() const override {
        return {"gpt-4o", "gpt-4o-mini", "o1-mini"};
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
    static std::string parseSseChunk(const std::string& chunk, bool* isDoneOut = nullptr);

private:
    std::string m_currentModel{"gpt-4o"};
    std::shared_ptr<ITransport> m_transport;
};

} // namespace sritec::ai
