#include "sritec/ai/ollama_provider.hpp"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>

namespace sritec::ai {

OllamaProvider::OllamaProvider(std::shared_ptr<ITransport> transport)
    : m_transport(std::move(transport))
{
    if (!m_transport) {
        m_transport = std::make_shared<QtNetworkTransport>();
    }
}

OllamaProvider::~OllamaProvider() {
    cancel();
}

void OllamaProvider::cancel() {
    if (m_transport) {
        m_transport->cancel();
    }
}

ProviderHealth OllamaProvider::health() const {
    ProviderHealth h;
    h.hasKey = true; // Local Ollama does not require cloud API keys
    if (m_transport && m_transport->isBusy()) {
        h.state = ConnectionState::Streaming;
        h.statusMessage = "Streaming from Local Ollama daemon";
    } else {
        h.state = ConnectionState::Ready;
        h.statusMessage = "Ollama Local Daemon Configured";
    }
    h.latencyMs = 4;
    return h;
}

std::string OllamaProvider::buildPayload(const std::string& model, const std::vector<ChatMessage>& history) {
    QJsonObject root;
    root["model"] = QString::fromStdString(model);
    root["stream"] = true;

    QJsonArray messages;
    for (const auto& msg : history) {
        QJsonObject m;
        m["role"] = QString::fromStdString(std::string(ChatMessage::roleToString(msg.role)));
        m["content"] = QString::fromStdString(msg.content);
        messages.append(m);
    }

    root["messages"] = messages;
    QJsonDocument doc(root);
    return doc.toJson(QJsonDocument::Compact).toStdString();
}

std::string OllamaProvider::parseChunk(const std::string& chunk, bool* isDoneOut) {
    if (isDoneOut) *isDoneOut = false;

    QString data = QString::fromStdString(chunk).trimmed();
    QJsonDocument doc = QJsonDocument::fromJson(data.toUtf8());
    if (doc.isObject()) {
        QJsonObject obj = doc.object();
        if (obj.contains("done") && obj["done"].toBool()) {
            if (isDoneOut) *isDoneOut = true;
        }
        if (obj.contains("message")) {
            QJsonObject msg = obj["message"].toObject();
            if (msg.contains("content")) {
                return msg["content"].toString().toStdString();
            }
        }
    }
    return "";
}

void OllamaProvider::streamChat(
    const std::vector<ChatMessage>& history,
    TokenCallback onToken,
    ErrorCallback onError,
    CompleteCallback onComplete
) {
    std::vector<std::pair<std::string, std::string>> headers = {
        {"Content-Type", "application/json"}
    };

    std::string payload = buildPayload(m_currentModel, history);

    m_transport->post(
        m_endpoint,
        headers,
        payload,
        [onToken](const std::string& chunk) {
            bool isDone = false;
            std::string token = parseChunk(chunk, &isDone);
            if (!token.empty()) {
                onToken(token, false);
            }
            if (isDone) {
                onToken("", true);
            }
        },
        onError,
        onComplete
    );
}

} // namespace sritec::ai
