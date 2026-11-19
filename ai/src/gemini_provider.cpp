#include "sritec/ai/gemini_provider.hpp"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>

namespace sritec::ai {

GeminiProvider::GeminiProvider(std::shared_ptr<ITransport> transport)
    : m_transport(std::move(transport))
{
    if (!m_transport) {
        m_transport = std::make_shared<QtNetworkTransport>();
    }
}

GeminiProvider::~GeminiProvider() {
    cancel();
}

void GeminiProvider::cancel() {
    if (m_transport) {
        m_transport->cancel();
    }
}

ProviderHealth GeminiProvider::health() const {
    ProviderHealth h;
    h.hasKey = KeyStore::instance().hasKey(ProviderType::Gemini);
    if (!h.hasKey) {
        h.state = ConnectionState::Disconnected;
        h.statusMessage = "API Key Required (Configure in Settings)";
    } else if (m_transport && m_transport->isBusy()) {
        h.state = ConnectionState::Streaming;
        h.statusMessage = "Streaming from Google Gemini API";
    } else {
        h.state = ConnectionState::Ready;
        h.statusMessage = "Google Gemini Gateway Ready";
    }
    h.latencyMs = 12;
    return h;
}

std::string GeminiProvider::buildPayload(const std::vector<ChatMessage>& history) {
    QJsonObject root;
    QJsonArray contents;

    for (const auto& msg : history) {
        QJsonObject contentObj;
        contentObj["role"] = (msg.role == MessageRole::Assistant) ? "model" : "user";

        QJsonArray parts;
        QJsonObject part;
        part["text"] = QString::fromStdString(msg.content);
        parts.append(part);

        contentObj["parts"] = parts;
        contents.append(contentObj);
    }

    root["contents"] = contents;
    QJsonDocument doc(root);
    return doc.toJson(QJsonDocument::Compact).toStdString();
}

std::string GeminiProvider::parseSseChunk(const std::string& chunk) {
    QString data = QString::fromStdString(chunk).trimmed();
    if (data.startsWith("data:")) {
        data = data.mid(5).trimmed();
    }

    QJsonDocument doc = QJsonDocument::fromJson(data.toUtf8());
    if (doc.isObject()) {
        QJsonObject obj = doc.object();
        QJsonArray candidates = obj["candidates"].toArray();
        if (!candidates.isEmpty()) {
            QJsonObject firstCandidate = candidates[0].toObject();
            QJsonObject content = firstCandidate["content"].toObject();
            QJsonArray parts = content["parts"].toArray();
            if (!parts.isEmpty()) {
                return parts[0].toObject()["text"].toString().toStdString();
            }
        }
    }
    return "";
}

void GeminiProvider::streamChat(
    const std::vector<ChatMessage>& history,
    TokenCallback onToken,
    ErrorCallback onError,
    CompleteCallback onComplete
) {
    if (!KeyStore::instance().hasKey(ProviderType::Gemini)) {
        onError(401, "Google Gemini API key missing. Please configure an API key.");
        return;
    }

    std::string key = KeyStore::instance().getKey(ProviderType::Gemini);
    std::string url = "https://generativelanguage.googleapis.com/v1beta/models/" + m_currentModel + ":streamGenerateContent?alt=sse";

    std::vector<std::pair<std::string, std::string>> headers = {
        {"Content-Type", "application/json"},
        {"x-goog-api-key", key}
    };

    std::string payload = buildPayload(history);

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
