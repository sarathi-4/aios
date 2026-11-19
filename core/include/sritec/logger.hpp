#pragma once

#include "common.hpp"
#include <iostream>
#include <string>
#include <string_view>
#include <mutex>
#include <chrono>
#include <iomanip>
#include <sstream>

namespace sritec {

class Logger {
public:
    static Logger& instance();

    void log(LogLevel level, std::string_view component, std::string_view message);

    void debug(std::string_view component, std::string_view message) {
        log(LogLevel::Debug, component, message);
    }

    void info(std::string_view component, std::string_view message) {
        log(LogLevel::Info, component, message);
    }

    void warn(std::string_view component, std::string_view message) {
        log(LogLevel::Warning, component, message);
    }

    void error(std::string_view component, std::string_view message) {
        log(LogLevel::Error, component, message);
    }

    void security(std::string_view component, std::string_view message) {
        log(LogLevel::Security, component, message);
    }

    // Public static methods for unit testing
    static std::string currentTimestamp();
    static std::string sanitize(std::string_view message);

private:
    Logger() = default;
    std::mutex m_mutex;

    static std::string levelToString(LogLevel level);
};

} // namespace sritec
