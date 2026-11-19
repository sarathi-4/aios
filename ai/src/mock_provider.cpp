#include "sritec/ai/mock_provider.hpp"
#include <sstream>
#include <chrono>
#include <algorithm>

namespace sritec::ai {

MockAIProvider::MockAIProvider() = default;

MockAIProvider::~MockAIProvider() {
    cancel();
}

void MockAIProvider::cancel() {
    std::lock_guard<std::mutex> lock(m_threadMutex);
    if (m_workerThread.joinable()) {
        m_workerThread.request_stop();
        m_workerThread.join();
    }
    m_isStreaming = false;
}

bool MockAIProvider::isStreaming() const {
    return m_isStreaming.load();
}

ProviderHealth MockAIProvider::health() const {
    ProviderHealth h;
    h.state = m_isStreaming.load() ? ConnectionState::Streaming : ConnectionState::Ready;
    h.statusMessage = "Local Mock Provider Active";
    h.latencyMs = 0;
    h.hasKey = true;
    return h;
}

std::string MockAIProvider::generateSimulatedResponse(const std::string& prompt) const {
    std::string lowerPrompt = prompt;
    std::transform(lowerPrompt.begin(), lowerPrompt.end(), lowerPrompt.begin(), ::tolower);

    if (lowerPrompt.find("hello") != std::string::npos || lowerPrompt.find("hi") != std::string::npos) {
        return "Greetings, Operator. SRITEC AI OS is online and operational. All neural cores are synchronized in unprivileged desktop mode. How can I assist your workflow today?";
    }

    if (lowerPrompt.find("terminal") != std::string::npos || lowerPrompt.find("command") != std::string::npos || lowerPrompt.find("run") != std::string::npos) {
        return "Command Analysis:\n```bash\n# Inspect system telemetry without elevated privileges\nps aux --sort=-%mem | head -n 10\n```\nSafety Status: [VERIFIED SAFE]. Note: Commands must be reviewed in the Developer Workspace before execution.";
    }

    if (lowerPrompt.find("status") != std::string::npos || lowerPrompt.find("system") != std::string::npos) {
        return "SRITEC System Telemetry:\n- Subsystem: User-space Workspace v0.1-alpha\n- Display Backend: Wayland Direct Client\n- Neural Engine: Mock Provider (0ms API latency, 0 credentials stored)\n- Security Sandbox: Active (Strict unprivileged profile)\n- Memory Allocation: 142 MB clean resident";
    }

    if (lowerPrompt.find("code") != std::string::npos || lowerPrompt.find("cpp") != std::string::npos || lowerPrompt.find("qml") != std::string::npos) {
        return "Here is a modular C++20 concept for an asynchronous system sensor:\n```cpp\n#include <concepts>\n\ntemplate<typename T>\nconcept SystemSensor = requires(T s) {\n    { s.pollStatus() } -> std::same_as<bool>;\n    { s.telemetrySnapshot() } -> std::convertible_to<std::string>;\n};\n```\nSynthesized cleanly for integration into `services/`.";
    }

    return "Received directive: \"" + prompt + "\".\n\nSRITEC Neural Engine has processed your query within the local development context. All parameters are verified safe under Phase 1 operation guidelines.";
}

void MockAIProvider::streamQuery(
    const std::string& prompt,
    [[maybe_unused]] const std::string& context,
    TokenCallback onToken
) {
    std::string fullResponse = generateSimulatedResponse(prompt);

    std::lock_guard<std::mutex> lock(m_threadMutex);

    if (m_workerThread.joinable()) {
        m_workerThread.request_stop();
        m_workerThread.join();
    }

    m_isStreaming = true;

    m_workerThread = std::jthread([this, fullResponse, onToken](std::stop_token stopToken) {
        std::istringstream stream(fullResponse);
        std::string word;

        while (stream >> word) {
            if (stopToken.stop_requested()) {
                m_isStreaming = false;
                return;
            }

            onToken(word + " ", false);

            for (int i = 0; i < 5; ++i) {
                if (stopToken.stop_requested()) {
                    m_isStreaming = false;
                    return;
                }
                std::this_thread::sleep_for(std::chrono::milliseconds(5));
            }
        }

        if (!stopToken.stop_requested()) {
            onToken("", true);
        }
        m_isStreaming = false;
    });
}

void MockAIProvider::streamChat(
    const std::vector<ChatMessage>& history,
    TokenCallback onToken,
    [[maybe_unused]] ErrorCallback onError,
    CompleteCallback onComplete
) {
    std::string lastPrompt = "Hello";
    for (auto it = history.rbegin(); it != history.rend(); ++it) {
        if (it->role == MessageRole::User) {
            lastPrompt = it->content;
            break;
        }
    }

    streamQuery(lastPrompt, "", [onToken, onComplete](const std::string& token, bool isFinished) {
        if (!token.empty()) {
            onToken(token, isFinished);
        }
        if (isFinished) {
            onComplete();
        }
    });
}

} // namespace sritec::ai
