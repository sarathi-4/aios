#include "sritec/ai/transport.hpp"
#include "sritec/ai/key_store.hpp"
#include <thread>
#include <mutex>
#include <chrono>
#include <atomic>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QSslConfiguration>
#include <QSslError>
#include <QUrl>
#include <QByteArray>
#include <QPointer>

namespace sritec::ai {

// ==============================================================================
// MockHttpTransport Implementation
// ==============================================================================

struct MockHttpTransport::Impl {
    std::jthread workerThread;
    std::mutex mutex;
    std::atomic<bool> isBusy{false};
};

MockHttpTransport::MockHttpTransport()
    : m_impl(std::make_unique<Impl>()) {}

MockHttpTransport::~MockHttpTransport() {
    cancel();
}

void MockHttpTransport::setSimulatedResponse(int statusCode, const std::vector<std::string>& sseChunks, const std::string& errorMessage) {
    std::lock_guard<std::mutex> lock(m_impl->mutex);
    m_simulatedStatusCode = statusCode;
    m_simulatedChunks = sseChunks;
    m_simulatedError = errorMessage;
}

void MockHttpTransport::cancel() {
    std::lock_guard<std::mutex> lock(m_impl->mutex);
    if (m_impl->workerThread.joinable()) {
        m_impl->workerThread.request_stop();
        m_impl->workerThread.join();
    }
    m_impl->isBusy = false;
}

bool MockHttpTransport::isBusy() const {
    return m_impl->isBusy.load();
}

void MockHttpTransport::post(
    const std::string& url,
    const std::vector<std::pair<std::string, std::string>>& headers,
    const std::string& body,
    ChunkCallback onChunk,
    ErrorCallback onError,
    DoneCallback onDone
) {
    cancel();

    std::lock_guard<std::mutex> lock(m_impl->mutex);
    m_lastUrl = url;
    m_lastHeaders = headers;
    m_lastBody = body;
    m_impl->isBusy = true;

    int statusCode = m_simulatedStatusCode;
    auto chunks = m_simulatedChunks;
    auto errorMsg = m_simulatedError;
    int latency = m_latencyMs;

    m_impl->workerThread = std::jthread([this, statusCode, chunks, errorMsg, latency, onChunk, onError, onDone](std::stop_token stopToken) {
        if (latency > 0) {
            std::this_thread::sleep_for(std::chrono::milliseconds(latency));
        }

        if (stopToken.stop_requested()) {
            m_impl->isBusy = false;
            return;
        }

        // Simulate HTTP / TLS / Network Errors (401, 429, 495, 500, 503, 504)
        if (statusCode >= 400) {
            std::string finalMsg = errorMsg.empty() ? ("HTTP " + std::to_string(statusCode) + " Error") : errorMsg;
            onError(statusCode, KeyStore::instance().redact(finalMsg));
            m_impl->isBusy = false;
            return;
        }

        // Simulate 200 OK SSE Chunks
        for (const auto& chunk : chunks) {
            if (stopToken.stop_requested()) {
                m_impl->isBusy = false;
                return;
            }
            onChunk(chunk);
            std::this_thread::sleep_for(std::chrono::milliseconds(latency));
        }

        if (!stopToken.stop_requested()) {
            onDone();
        }
        m_impl->isBusy = false;
    });
}

// ==============================================================================
// QtNetworkTransport Implementation
// ==============================================================================

struct QtNetworkTransport::Impl {
    QNetworkAccessManager nam;
    QPointer<QNetworkReply> currentReply;
    std::atomic<bool> isBusy{false};
};

QtNetworkTransport::QtNetworkTransport()
    : m_impl(std::make_unique<Impl>()) {}

QtNetworkTransport::~QtNetworkTransport() {
    cancel();
}

void QtNetworkTransport::cancel() {
    if (m_impl->currentReply) {
        m_impl->currentReply->abort();
        m_impl->currentReply->deleteLater();
        m_impl->currentReply = nullptr;
    }
    m_impl->isBusy = false;
}

bool QtNetworkTransport::isBusy() const {
    return m_impl->isBusy.load();
}

void QtNetworkTransport::post(
    const std::string& url,
    const std::vector<std::pair<std::string, std::string>>& headers,
    const std::string& body,
    ChunkCallback onChunk,
    ErrorCallback onError,
    DoneCallback onDone
) {
    cancel();

    QNetworkRequest request(QUrl(QString::fromStdString(url)));

    // Enforce TLS 1.2+ / 1.3 certificate verification
    QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
    sslConfig.setProtocol(QSsl::SecureProtocols);
    request.setSslConfiguration(sslConfig);

    // Enforce 15-second transfer timeout
    request.setTransferTimeout(15000);

    for (const auto& [name, val] : headers) {
        request.setRawHeader(QByteArray::fromStdString(name), QByteArray::fromStdString(val));
    }

    QByteArray data = QByteArray::fromStdString(body);
    QNetworkReply* reply = m_impl->nam.post(request, data);
    m_impl->currentReply = reply;
    m_impl->isBusy = true;

    // Strict TLS certificate verification: handle sslErrors and reject untrusted certs
    QObject::connect(reply, &QNetworkReply::sslErrors, [reply, onError](const QList<QSslError>& errors) {
        // Deliberately DO NOT call reply->ignoreSslErrors()
        std::string sslErr = "TLS Verification Failed: ";
        for (const auto& err : errors) {
            sslErr += err.errorString().toStdString() + "; ";
        }
        onError(495, KeyStore::instance().redact(sslErr));
    });

    QObject::connect(reply, &QNetworkReply::readyRead, [reply, onChunk]() {
        QByteArray chunk = reply->readAll();
        if (!chunk.isEmpty()) {
            onChunk(chunk.toStdString());
        }
    });

    QObject::connect(reply, &QNetworkReply::finished, [this, reply, onError, onDone]() {
        m_impl->isBusy = false;
        if (reply->error() != QNetworkReply::NoError && reply->error() != QNetworkReply::OperationCanceledError) {
            int code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            if (code == 0) {
                if (reply->error() == QNetworkReply::ConnectionRefusedError) {
                    code = 503; // Service Unavailable / Refused
                } else if (reply->error() == QNetworkReply::TimeoutError) {
                    code = 504; // Gateway Timeout
                } else if (reply->error() == QNetworkReply::SslHandshakeFailedError) {
                    code = 495; // SSL Certificate Error
                } else {
                    code = 502; // Bad Gateway / Network Error
                }
            }
            std::string errStr = reply->errorString().toStdString();
            onError(code, KeyStore::instance().redact(errStr));
        } else if (reply->error() == QNetworkReply::NoError) {
            onDone();
        }
        reply->deleteLater();
    });
}

} // namespace sritec::ai
