#include "sritec/ai/openai_provider.hpp"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>

namespace sritec::ai {

OpenAIProvider::OpenAIProvider(std::shared_ptr<ITransport> transport)
    : m_transport(std::move(transport))
{
    if (!m_transport) {
        m_transport = std::make_shared<QtNetworkTransport>();
    }
}

OpenAIProvider::~OpenAIProvider() {
    cancel();
}

void OpenAIProvider::cancel() {
    if (m_transport) {
        m_transport->cancel();
    }
}

ProviderHealth OpenAIProvider::health() const {
    ProviderHealth h;
    h.hasKey = KeyStore::instance().hasKey(ProviderType::OpenAI);
    if (!h.hasKey) {
        h.state = ConnectionState::Disconnected;
        h.statusMessage = "OpenAI API Key Required";
    } else if (m_transport && m_transport->isBusy()) {
        h.state = ConnectionState::Streaming;
        h.statusMessage = "Streaming from OpenAI API";
    } else {
        h.state = ConnectionState::Ready;
        h.statusMessage = "OpenAI Gateway Ready";
    }
    h.latencyMs = 15;
    return h;
}

std::string OpenAIProvider::buildPayload(const std::string& model, const std::vector<ChatMessage>& history) {
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

std::string OpenAIProvider::parseSseChunk(const std::string& chunk, bool* isDoneOut) {
    if (isDoneOut) *isDoneOut = false;

    QString data = QString::fromStdString(chunk).trimmed();
    if (data.contains("[DONE]")) {
        if (isDoneOut) *isDoneOut = true;
        return "";
    }

    if (data.startsWith("data:")) {
        data = data.mid(5).trimmed();
    }

    QJsonDocument doc = QJsonDocument::fromJson(data.toUtf8());
    if (doc.isObject()) {
        QJsonObject obj = doc.object();
        QJsonArray choices = obj["choices"].toArray();
        if (!choices.isEmpty()) {
            QJsonObject firstChoice = choices[0].toObject();
            QJsonObject delta = firstChoice["delta"].toObject();
            if (delta.contains("content")) {
                return delta["content"].toString().toStdString();
            }
        }
    }
    return "";
}

void OpenAIProvider::streamChat(
    const std::vector<ChatMessage>& history,
    TokenCallback onToken,
    ErrorCallback onError,
    CompleteCallback onComplete
) {
    if (!KeyStore::instance().hasKey(ProviderType::OpenAI)) {
        onError(401, "OpenAI API key missing. Please configure an API key.");
        return;
    }

    std::string key = KeyStore::instance().getKey(ProviderType::OpenAI);
    std::string url = "https://api.openai.com/v1/chat/completions";

    std::vector<std::pair<std::string, std::string>> headers = {
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer " + key}
    };

    std::string payload = buildPayload(m_currentModel, history);

    m_transport->post(
        url,
        headers,
        payload,
        [onToken](const std::string& chunk) {
            bool isDone = false;
            std::string token = parseSseChunk(chunk, &isDone);
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
