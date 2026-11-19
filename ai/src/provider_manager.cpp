#include "sritec/ai/provider_manager.hpp"

namespace sritec::ai {

ProviderManager::ProviderManager(std::shared_ptr<ITransport> transport) {
    auto mock = std::make_shared<MockAIProvider>();
    auto gemini = std::make_shared<GeminiProvider>(transport);
    auto openai = std::make_shared<OpenAIProvider>(transport);
    auto claude = std::make_shared<ClaudeProvider>(transport);
    auto ollama = std::make_shared<OllamaProvider>(transport);

    m_providers[ProviderType::Mock] = mock;
    m_providers[ProviderType::Gemini] = gemini;
    m_providers[ProviderType::OpenAI] = openai;
    m_providers[ProviderType::Claude] = claude;
    m_providers[ProviderType::Ollama] = ollama;

    // Default to Mock provider (safe, offline, no API key required)
    m_activeProvider = mock;
}

ProviderManager::~ProviderManager() {
    cancel();
}

std::vector<std::string> ProviderManager::providerNames() const {
    return {
        providerTypeToString(ProviderType::Mock),
        providerTypeToString(ProviderType::Gemini),
        providerTypeToString(ProviderType::OpenAI),
        providerTypeToString(ProviderType::Claude),
        providerTypeToString(ProviderType::Ollama)
    };
}

std::string ProviderManager::activeProviderName() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_activeProvider) {
        return m_activeProvider->providerName();
    }
    return "Mock";
}

ProviderType ProviderManager::activeProviderType() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_activeProvider) {
        return m_activeProvider->type();
    }
    return ProviderType::Mock;
}

bool ProviderManager::selectProvider(const std::string& name) {
    ProviderType type = stringToProviderType(name);
    return selectProvider(type);
}

bool ProviderManager::selectProvider(ProviderType type) {
    std::lock_guard<std::mutex> lock(m_mutex);
    auto it = m_providers.find(type);
    if (it != m_providers.end()) {
        if (m_activeProvider) {
            m_activeProvider->cancel();
        }
        m_activeProvider = it->second;
        return true;
    }
    return false;
}

std::string ProviderManager::activeModel() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_activeProvider) {
        return m_activeProvider->currentModel();
    }
    return "";
}

std::vector<std::string> ProviderManager::availableModels() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_activeProvider) {
        return m_activeProvider->availableModels();
    }
    return {};
}

bool ProviderManager::selectModel(const std::string& modelId) {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_activeProvider) {
        m_activeProvider->setModel(modelId);
        return true;
    }
    return false;
}

bool ProviderManager::hasKeyForActiveProvider() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_activeProvider) {
        return KeyStore::instance().hasKey(m_activeProvider->type());
    }
    return true;
}

void ProviderManager::setKeyForProvider(ProviderType type, const std::string& key) {
    KeyStore::instance().setKey(type, key);
}

void ProviderManager::appendUserMessage(const std::string& content) {
    std::lock_guard<std::mutex> lock(m_mutex);
    m_history.push_back({MessageRole::User, content, "", 0});
}

void ProviderManager::appendAssistantMessage(const std::string& content) {
    std::lock_guard<std::mutex> lock(m_mutex);
    m_history.push_back({MessageRole::Assistant, content, "", 0});
}

const std::vector<ChatMessage>& ProviderManager::history() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_history;
}

void ProviderManager::clearHistory() {
    std::lock_guard<std::mutex> lock(m_mutex);
    m_history.clear();
}

void ProviderManager::stream(
    TokenCallback onToken,
    ErrorCallback onError,
    CompleteCallback onComplete
) {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_activeProvider) {
        m_activeProvider->streamChat(m_history, onToken, onError, onComplete);
    } else {
        onError(500, "No active AI provider selected.");
    }
}

void ProviderManager::cancel() {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_activeProvider) {
        m_activeProvider->cancel();
    }
}

ProviderHealth ProviderManager::health() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_activeProvider) {
        return m_activeProvider->health();
    }
    ProviderHealth h;
    h.state = ConnectionState::Disconnected;
    h.statusMessage = "Inactive";
    return h;
}

} // namespace sritec::ai
