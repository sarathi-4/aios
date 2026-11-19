#pragma once

#include <string>
#include <vector>
#include <functional>
#include <memory>
#include <utility>

namespace sritec::ai {

using ChunkCallback = std::function<void(const std::string& chunk)>;
using ErrorCallback = std::function<void(int statusCode, const std::string& errorMessage)>;
using DoneCallback = std::function<void()>;

class ITransport {
public:
    virtual ~ITransport() = default;

    virtual void post(
        const std::string& url,
        const std::vector<std::pair<std::string, std::string>>& headers,
        const std::string& body,
        ChunkCallback onChunk,
        ErrorCallback onError,
        DoneCallback onDone
    ) = 0;

    virtual void cancel() = 0;
    virtual bool isBusy() const = 0;
};

// Mock Transport for Unit Tests (Offline Simulation of SSE, 401, 429, 504, Timeout)
class MockHttpTransport : public ITransport {
public:
    MockHttpTransport();
    ~MockHttpTransport() override;

    void setSimulatedResponse(int statusCode, const std::vector<std::string>& sseChunks, const std::string& errorMessage = "");
    void setSimulatedLatencyMs(int ms) { m_latencyMs = ms; }

    void post(
        const std::string& url,
        const std::vector<std::pair<std::string, std::string>>& headers,
        const std::string& body,
        ChunkCallback onChunk,
        ErrorCallback onError,
        DoneCallback onDone
    ) override;

    void cancel() override;
    bool isBusy() const override;

    // Test inspection getters
    std::string lastUrl() const { return m_lastUrl; }
    std::string lastBody() const { return m_lastBody; }
    std::vector<std::pair<std::string, std::string>> lastHeaders() const { return m_lastHeaders; }

private:
    int m_simulatedStatusCode{200};
    std::vector<std::string> m_simulatedChunks;
    std::string m_simulatedError;
    int m_latencyMs{10};

    std::string m_lastUrl;
    std::string m_lastBody;
    std::vector<std::pair<std::string, std::string>> m_lastHeaders;

    struct Impl;
    std::unique_ptr<Impl> m_impl;
};

// Production Qt6 Network Transport (Asynchronous QNetworkAccessManager)
class QtNetworkTransport : public ITransport {
public:
    QtNetworkTransport();
    ~QtNetworkTransport() override;

    void post(
        const std::string& url,
        const std::vector<std::pair<std::string, std::string>>& headers,
        const std::string& body,
        ChunkCallback onChunk,
        ErrorCallback onError,
        DoneCallback onDone
    ) override;

    void cancel() override;
    bool isBusy() const override;

private:
    struct Impl;
    std::unique_ptr<Impl> m_impl;
};

} // namespace sritec::ai
