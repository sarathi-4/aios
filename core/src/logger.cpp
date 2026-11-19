#include "sritec/logger.hpp"
#include <regex>

namespace sritec {

Logger& Logger::instance() {
    static Logger s_instance;
    return s_instance;
}

std::string Logger::levelToString(LogLevel level) {
    switch (level) {
        case LogLevel::Debug:    return "[DEBUG]   ";
        case LogLevel::Info:     return "[INFO]    ";
        case LogLevel::Warning:  return "[WARN]    ";
        case LogLevel::Error:    return "[ERROR]   ";
        case LogLevel::Security: return "[SECURITY]";
    }
    return "[UNKNOWN] ";
}

std::string Logger::currentTimestamp() {
    auto now = std::chrono::system_clock::now();
    auto in_time_t = std::chrono::system_clock::to_time_t(now);
    auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()) % 1000;

    // Thread-safe POSIX localtime_r
    struct tm timeinfo{};
    localtime_r(&in_time_t, &timeinfo);

    std::stringstream ss;
    ss << std::put_time(&timeinfo, "%Y-%m-%d %H:%M:%S")
       << '.' << std::setfill('0') << std::setw(3) << ms.count();
    return ss.str();
}

std::string Logger::sanitize(std::string_view message) {
    if (message.empty()) {
        return "";
    }
    std::string s(message);
    try {
        // Redact Gemini API keys
        s = std::regex_replace(s, std::regex("AIzaSy[A-Za-z0-9_-]{33}"), "[REDACTED_API_KEY]");
        // Redact OpenAI API keys
        s = std::regex_replace(s, std::regex("sk-(proj-)?[A-Za-z0-9_-]{20,}"), "[REDACTED_API_KEY]");
        // Redact Anthropic API keys
        s = std::regex_replace(s, std::regex("sk-ant-[A-Za-z0-9_-]{20,}"), "[REDACTED_API_KEY]");
        // Redact Bearer authorization tokens
        s = std::regex_replace(s, std::regex("Bearer\\s+[A-Za-z0-9_.-]{20,}"), "Bearer [REDACTED_TOKEN]");
    } catch (...) {
        // Continue on regex failure
    }
    return s;
}

void Logger::log(LogLevel level, std::string_view component, std::string_view message) {
    std::lock_guard<std::mutex> lock(m_mutex);
    std::cout << currentTimestamp() << " "
              << levelToString(level) << " ["
              << component << "] "
              << sanitize(message) << std::endl;
}

} // namespace sritec
