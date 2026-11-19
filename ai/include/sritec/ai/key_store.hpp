#pragma once

#include "chat_message.hpp"
#include <string>
#include <unordered_map>
#include <mutex>

namespace sritec::ai {

class KeyStore {
public:
    static KeyStore& instance();
    ~KeyStore();

    bool hasKey(ProviderType type) const;
    std::string getKey(ProviderType type) const;
    void setKey(ProviderType type, std::string key);
    void clearKey(ProviderType type);
    void clearAll();

    // Reload keys from host environment variables
    void reloadFromEnvironment();

    // Redaction utility: scrubs any configured key or known secret signature from string
    std::string redact(const std::string& text) const;

    // Secure memory erasure helper
    static void secureCleanse(std::string& str);

private:
    KeyStore();
    mutable std::mutex m_mutex;
    std::unordered_map<ProviderType, std::string> m_keys;
};

} // namespace sritec::ai
