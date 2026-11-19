#pragma once

#include "ai_provider.hpp"
#include "transport.hpp"
#include <memory>
#include <string>
#include <vector>

namespace sritec::ai {

class OllamaProvider : public AIProvider {
public:
    explicit OllamaProvider(std::shared_ptr<ITransport> transport = nullptr);
    ~OllamaProvider() override;

    ProviderType type() const override { return ProviderType::Ollama; }
    std::string providerName() const override { return "Local AI (Ollama)"; }
    std::string currentModel() const override { return m_currentModel; }
    std::vector<std::string> availableModels() const override {
        return {"llama3.2", "llama3.1", "qwen2.5-coder", "mistral"};
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
    static std::string parseChunk(const std::string& chunk, bool* isDoneOut = nullptr);

private:
    std::string m_currentModel{"llama3.2"};
    std::string m_endpoint{"http://localhost:11434/api/chat"};
    std::shared_ptr<ITransport> m_transport;
};

} // namespace sritec::ai
