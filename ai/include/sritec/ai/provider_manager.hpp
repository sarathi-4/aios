#pragma once

#include "ai_provider.hpp"
#include "mock_provider.hpp"
#include "gemini_provider.hpp"
#include "openai_provider.hpp"
#include "claude_provider.hpp"
#include "ollama_provider.hpp"
#include "key_store.hpp"

#include <memory>
#include <string>
#include <vector>
#include <unordered_map>
#include <mutex>

namespace sritec::ai {

class ProviderManager {
public:
    explicit ProviderManager(std::shared_ptr<ITransport> transport = nullptr);
    ~ProviderManager();

    std::vector<std::string> providerNames() const;
    std::string activeProviderName() const;
    ProviderType activeProviderType() const;
    bool selectProvider(const std::string& name);
    bool selectProvider(ProviderType type);

    std::string activeModel() const;
    std::vector<std::string> availableModels() const;
    bool selectModel(const std::string& modelId);

    // Key management (delegates to KeyStore)
    bool hasKeyForActiveProvider() const;
    void setKeyForProvider(ProviderType type, const std::string& key);

    // Multi-turn Conversation Context Management
    void appendUserMessage(const std::string& content);
    void appendAssistantMessage(const std::string& content);
    const std::vector<ChatMessage>& history() const;
    void clearHistory();

    // Streaming Execution
    void stream(
        TokenCallback onToken,
        ErrorCallback onError,
        CompleteCallback onComplete
    );

    void cancel();
    ProviderHealth health() const;

private:
    std::unordered_map<ProviderType, std::shared_ptr<AIProvider>> m_providers;
    std::shared_ptr<AIProvider> m_activeProvider;
    std::vector<ChatMessage> m_history;
    mutable std::mutex m_mutex;
};

} // namespace sritec::ai
