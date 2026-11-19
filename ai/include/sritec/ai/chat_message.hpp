#pragma once

#include <string>
#include <string_view>
#include <vector>

namespace sritec::ai {

enum class MessageRole {
    System,
    User,
    Assistant
};

struct ChatMessage {
    MessageRole role{MessageRole::User};
    std::string content;
    std::string timestamp;
    int tokenCount{0};

    ChatMessage() = default;
    ChatMessage(MessageRole r, std::string c, std::string t = "", int tokens = 0)
        : role(r), content(std::move(c)), timestamp(std::move(t)), tokenCount(tokens) {}

    static std::string_view roleToString(MessageRole r) {
        switch (r) {
            case MessageRole::System:    return "system";
            case MessageRole::User:      return "user";
            case MessageRole::Assistant: return "assistant";
        }
        return "user";
    }

    static MessageRole stringToRole(std::string_view s) {
        if (s == "system") return MessageRole::System;
        if (s == "assistant") return MessageRole::Assistant;
        return MessageRole::User;
    }
};

enum class ProviderType {
    Mock,
    Gemini,
    OpenAI,
    Claude,
    Ollama
};

inline std::string providerTypeToString(ProviderType type) {
    switch (type) {
        case ProviderType::Mock:   return "Mock";
        case ProviderType::Gemini: return "Google Gemini";
        case ProviderType::OpenAI: return "OpenAI";
        case ProviderType::Claude: return "Anthropic Claude";
        case ProviderType::Ollama: return "Local AI (Ollama)";
    }
    return "Mock";
}

inline ProviderType stringToProviderType(std::string_view str) {
    if (str.find("Gemini") != std::string_view::npos || str.find("gemini") != std::string_view::npos) return ProviderType::Gemini;
    if (str.find("OpenAI") != std::string_view::npos || str.find("openai") != std::string_view::npos) return ProviderType::OpenAI;
    if (str.find("Claude") != std::string_view::npos || str.find("claude") != std::string_view::npos) return ProviderType::Claude;
    if (str.find("Ollama") != std::string_view::npos || str.find("ollama") != std::string_view::npos) return ProviderType::Ollama;
    return ProviderType::Mock;
}

enum class ConnectionState {
    Disconnected,
    Ready,
    Connecting,
    Streaming,
    Error
};

inline std::string connectionStateToString(ConnectionState state) {
    switch (state) {
        case ConnectionState::Disconnected: return "Disconnected";
        case ConnectionState::Ready:        return "Ready";
        case ConnectionState::Connecting:   return "Connecting";
        case ConnectionState::Streaming:    return "Streaming";
        case ConnectionState::Error:        return "Error";
    }
    return "Ready";
}

struct ProviderHealth {
    ConnectionState state{ConnectionState::Ready};
    std::string statusMessage{"Ready"};
    int latencyMs{0};
    bool hasKey{false};
};

} // namespace sritec::ai
