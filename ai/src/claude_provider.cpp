#include "sritec/ai/claude_provider.hpp"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>

namespace sritec::ai {

ClaudeProvider::ClaudeProvider(std::shared_ptr<ITransport> transport)
    : m_transport(std::move(transport))
{
    if (!m_transport) {
        m_transport = std::make_shared<QtNetworkTransport>();
    }
}

ClaudeProvider::~ClaudeProvider() {
    cancel();
}

void ClaudeProvider::cancel() {
    if (m_transport) {
        m_transport->cancel();
    }
}

ProviderHealth ClaudeProvider::health() const {
    ProviderHealth h;
    h.hasKey = KeyStore::instance().hasKey(ProviderType::Claude);
    if (!h.hasKey) {
        h.state = ConnectionState::Disconnected;
        h.statusMessage = "Anthropic API Key Required";
    } else if (m_transport && m_transport->isBusy()) {
        h.state = ConnectionState::Streaming;
        h.statusMessage = "Streaming from Anthropic Claude API";
    } else {
        h.state = ConnectionState::Ready;
        h.statusMessage = "Anthropic Claude Gateway Ready";
    }
    h.latencyMs = 18;
    return h;
}

std::string ClaudeProvider::buildPayload(const std::string& model, const std::vector<ChatMessage>& history) {
    QJsonObject root;
    root["model"] = QString::fromStdString(model);
    root["max_tokens"] = 4096;
    root["stream"] = true;

    QJsonArray messages;
    for (const auto& msg : history) {
        if (msg.role == MessageRole::System) {
            root["system"] = QString::fromStdString(msg.content);
            continue;
        }
        QJsonObject m;
        m["role"] = (msg.role == MessageRole::Assistant) ? "assistant" : "user";
        m["content"] = QString::fromStdString(msg.content);
        messages.append(m);
    }

    root["messages"] = messages;
    QJsonDocument doc(root);
    return doc.toJson(QJsonDocument::Compact).toStdString();
}

std::string ClaudeProvider::parseSseChunk(const std::string& chunk) {
    QString data = QString::fromStdString(chunk).trimmed();

    // Anthropic sends "event: content_block_delta" then "data: {...}"
    QStringList lines = data.split('\n', Qt::SkipEmptyParts);
    for (const QString& line : lines) {
        QString l = line.trimmed();
        if (l.startsWith("data:")) {
            QString jsonPart = l.mid(5).trimmed();
            QJsonDocument doc = QJsonDocument::fromJson(jsonPart.toUtf8());
            if (doc.isObject()) {
                QJsonObject obj = doc.object();
                if (obj["type"].toString() == "content_block_delta") {
                    QJsonObject delta = obj["delta"].toObject();
                    if (delta["type"].toString() == "text_delta") {
                        return delta["text"].toString().toStdString();
                    }
                }
            }
        }
    }
    return "";
}

void ClaudeProvider::streamChat(
    const std::vector<ChatMessage>& history,
    TokenCallback onToken,
    ErrorCallback onError,
    CompleteCallback onComplete
) {
    if (!KeyStore::instance().hasKey(ProviderType::Claude)) {
        onError(401, "Anthropic Claude API key missing. Please configure an API key.");
        return;
    }

    std::string key = KeyStore::instance().getKey(ProviderType::Claude);
    std::string url = "https://api.anthropic.com/v1/messages";

    std::vector<std::pair<std::string, std::string>> headers = {
        {"Content-Type", "application/json"},
        {"x-api-key", key},
        {"anthropic-version", "2023-06-01"}
    };

    std::string payload = buildPayload(m_currentModel, history);

    m_transport->post(
        url,
        headers,
        payload,
        [onToken](const std::string& chunk) {
            std::string token = parseSseChunk(chunk);
            if (!token.empty()) {
                onToken(token, false);
            }
        },
        onError,
        onComplete
    );
}

} // namespace sritec::ai
