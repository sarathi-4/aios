#pragma once

#include "chat_message.hpp"
#include <string>
#include <functional>
#include <memory>
#include <vector>

namespace sritec::ai {

struct AIResponse {
    std::string text;
    bool isComplete{false};
    std::string modelName;
    int tokensGenerated{0};
};

using TokenCallback = std::function<void(const std::string& token, bool isFinished)>;
using ErrorCallback = std::function<void(int statusCode, const std::string& errorMessage)>;
using CompleteCallback = std::function<void()>;

class AIProvider {
public:
    virtual ~AIProvider() = default;

    virtual ProviderType type() const = 0;
    virtual std::string providerName() const = 0;
    virtual std::string currentModel() const = 0;
    virtual std::vector<std::string> availableModels() const = 0;
    virtual void setModel(const std::string& modelId) = 0;

    // Phase 1 Backward Compatibility
    virtual void streamQuery(
        const std::string& prompt,
        const std::string& context,
        TokenCallback onToken
    ) {
        std::vector<ChatMessage> history;
        if (!context.empty()) {
            history.push_back({MessageRole::System, context, "", 0});
        }
        history.push_back({MessageRole::User, prompt, "", 0});
        streamChat(history, onToken, [](int, const std::string&) {}, []() {});
    }

    // Phase 2.1 Enhanced Chat Streaming
    virtual void streamChat(
        const std::vector<ChatMessage>& history,
        TokenCallback onToken,
        ErrorCallback onError,
        CompleteCallback onComplete
    ) = 0;

    virtual void cancel() = 0;
    virtual ProviderHealth health() const = 0;
};

} // namespace sritec::ai
