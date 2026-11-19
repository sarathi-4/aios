#include "sritec/ai/key_store.hpp"
#include <cstdlib>
#include <regex>
#include <algorithm>

namespace sritec::ai {

KeyStore& KeyStore::instance() {
    static KeyStore s_instance;
    return s_instance;
}

KeyStore::KeyStore() {
    reloadFromEnvironment();
}

KeyStore::~KeyStore() {
    clearAll();
}

void KeyStore::secureCleanse(std::string& str) {
    if (!str.empty()) {
        volatile char* p = const_cast<volatile char*>(str.data());
        for (size_t i = 0; i < str.size(); ++i) {
            p[i] = 0;
        }
        str.clear();
    }
}

void KeyStore::reloadFromEnvironment() {
    std::lock_guard<std::mutex> lock(m_mutex);

    if (const char* k = std::getenv("GEMINI_API_KEY")) {
        if (*k) m_keys[ProviderType::Gemini] = k;
    }
    if (const char* k = std::getenv("OPENAI_API_KEY")) {
        if (*k) m_keys[ProviderType::OpenAI] = k;
    }
    if (const char* k = std::getenv("ANTHROPIC_API_KEY")) {
        if (*k) m_keys[ProviderType::Claude] = k;
    }
}

bool KeyStore::hasKey(ProviderType type) const {
    if (type == ProviderType::Mock || type == ProviderType::Ollama) {
        return true; // Mock and local Ollama do not require cloud API keys
    }

    std::lock_guard<std::mutex> lock(m_mutex);
    auto it = m_keys.find(type);
    return (it != m_keys.end() && !it->second.empty());
}

std::string KeyStore::getKey(ProviderType type) const {
    std::lock_guard<std::mutex> lock(m_mutex);
    auto it = m_keys.find(type);
    if (it != m_keys.end()) {
        return it->second;
    }
    return "";
}

void KeyStore::setKey(ProviderType type, std::string key) {
    std::lock_guard<std::mutex> lock(m_mutex);
    auto it = m_keys.find(type);
    if (it != m_keys.end()) {
        secureCleanse(it->second);
    }
    m_keys[type] = std::move(key);
}

void KeyStore::clearKey(ProviderType type) {
    std::lock_guard<std::mutex> lock(m_mutex);
    auto it = m_keys.find(type);
    if (it != m_keys.end()) {
        secureCleanse(it->second);
        m_keys.erase(it);
    }
}

void KeyStore::clearAll() {
    std::lock_guard<std::mutex> lock(m_mutex);
    for (auto& [type, key] : m_keys) {
        secureCleanse(key);
    }
    m_keys.clear();
}

std::string KeyStore::redact(const std::string& text) const {
    if (text.empty()) {
        return text;
    }

    std::string result = text;

    // 1. Scrub exact configured keys
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        for (const auto& [type, key] : m_keys) {
            if (!key.empty() && key.length() >= 4) {
                size_t pos = 0;
                while ((pos = result.find(key, pos)) != std::string::npos) {
                    result.replace(pos, key.length(), "[REDACTED_API_KEY]");
                    pos += 20; // length of replacement
                }
            }
        }
    }

    // 2. Scrub standard API key signatures (Gemini, OpenAI, Anthropic, Bearer tokens)
    try {
        // Gemini: AIzaSy...
        result = std::regex_replace(result, std::regex("AIzaSy[A-Za-z0-9_-]{33}"), "[REDACTED_GEMINI_KEY]");
        // OpenAI: sk-proj-... or sk-... (at least 20 chars)
        result = std::regex_replace(result, std::regex("sk-(proj-)?[A-Za-z0-9_-]{20,}"), "[REDACTED_OPENAI_KEY]");
        // Anthropic: sk-ant-...
        result = std::regex_replace(result, std::regex("sk-ant-[A-Za-z0-9_-]{20,}"), "[REDACTED_CLAUDE_KEY]");
        // Bearer tokens
        result = std::regex_replace(result, std::regex("Bearer\\s+[A-Za-z0-9_.-]{20,}"), "Bearer [REDACTED_TOKEN]");
    } catch (...) {
        // Fallback gracefully on regex error
    }

    return result;
}

} // namespace sritec::ai
