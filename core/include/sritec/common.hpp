#pragma once

#include <string>
#include <string_view>
#include <cstdint>

namespace sritec {

inline constexpr std::string_view OS_NAME = "SRITEC AI OS";
inline constexpr std::string_view OS_VERSION = "0.1.0-alpha";
inline constexpr std::string_view OS_CODENAME = "Nebula";

enum class LogLevel {
    Debug,
    Info,
    Warning,
    Error,
    Security
};

} // namespace sritec
