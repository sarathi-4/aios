#include "sritec/ai/ai_bridge.hpp"
#include <QMetaObject>
#include <QStringList>

namespace sritec::ai {

AIBridge::AIBridge(QObject* parent, std::shared_ptr<ITransport> transport)
    : QObject(parent),
      m_manager(std::make_unique<ProviderManager>(std::move(transport)))
{
}

AIBridge::~AIBridge() {
    if (m_manager) {
        m_manager->cancel();
    }
}

QString AIBridge::modelName() const {
    if (m_manager) {
        return QString::fromStdString(m_manager->activeProviderName() + " (" + m_manager->activeModel() + ")");
    }
    return "SRITEC Neural Core";
}

QString AIBridge::selectedProvider() const {
    if (m_manager) {
        return QString::fromStdString(providerTypeToString(m_manager->activeProviderType()));
    }
    return "Mock";
}

void AIBridge::setSelectedProvider(const QString& name) {
    selectProvider(name);
}

QString AIBridge::selectedModel() const {
    if (m_manager) {
        return QString::fromStdString(m_manager->activeModel());
    }
    return "";
}

void AIBridge::setSelectedModel(const QString& model) {
    selectModel(model);
}

QStringList AIBridge::availableProviders() const {
    QStringList list;
    if (m_manager) {
        for (const auto& p : m_manager->providerNames()) {
            list.append(QString::fromStdString(p));
        }
    }
    return list;
}

QStringList AIBridge::availableModels() const {
    QStringList list;
    if (m_manager) {
        for (const auto& m : m_manager->availableModels()) {
            list.append(QString::fromStdString(m));
        }
    }
    return list;
}

QString AIBridge::connectionState() const {
    if (m_isGenerating) {
        return "Streaming";
    }
    if (m_manager) {
        return QString::fromStdString(connectionStateToString(m_manager->health().state));
    }
    return "Ready";
}

QString AIBridge::statusMessage() const {
    if (!m_lastError.isEmpty()) {
        return m_lastError;
    }
    if (m_manager) {
        return QString::fromStdString(m_manager->health().statusMessage);
    }
    return "Ready";
}

bool AIBridge::hasApiKey() const {
    if (m_manager) {
        return m_manager->hasKeyForActiveProvider();
    }
    return true;
}

void AIBridge::selectProvider(const QString& name) {
    if (m_manager && m_manager->selectProvider(name.toStdString())) {
        m_lastError.clear();
        emit selectedProviderChanged();
        emit selectedModelChanged();
        emit availableModelsChanged();
        emit modelNameChanged();
        emit connectionStateChanged();
        emit statusMessageChanged();
        emit hasApiKeyChanged();
    }
}

void AIBridge::selectModel(const QString& model) {
    if (m_manager && m_manager->selectModel(model.toStdString())) {
        emit selectedModelChanged();
        emit modelNameChanged();
    }
}

void AIBridge::setApiKey(const QString& provider, const QString& key) {
    if (m_manager) {
        ProviderType type = stringToProviderType(provider.toStdString());
        m_manager->setKeyForProvider(type, key.trimmed().toStdString());
        m_lastError.clear();
        emit hasApiKeyChanged();
        emit connectionStateChanged();
        emit statusMessageChanged();
    }
}

void AIBridge::clearHistory() {
    if (m_manager) {
        m_manager->clearHistory();
    }
    clear();
}

void AIBridge::retry() {
    if (!m_lastPrompt.isEmpty()) {
        sendQuery(m_lastPrompt);
    }
}

void AIBridge::sendQuery(const QString& prompt) {
    if (prompt.trimmed().isEmpty() || m_isGenerating) {
        return;
    }

    m_lastPrompt = prompt;
    m_lastError.clear();

    m_isGenerating = true;
    emit isGeneratingChanged();
    emit connectionStateChanged();
    emit statusMessageChanged();

    m_currentResponse.clear();
    emit currentResponseChanged();

    m_tokenCount = 0;
    emit tokenCountChanged();

    m_manager->appendUserMessage(prompt.toStdString());

    m_manager->stream(
        [this, guard = QPointer<AIBridge>(this)](const std::string& token, bool isFinished) {
            if (!guard) return;
            QString qToken = QString::fromStdString(token);
            QMetaObject::invokeMethod(
                guard.data(),
                [guard, qToken, isFinished]() {
                    if (guard) {
                        guard->handleToken(qToken, isFinished);
                    }
                },
                Qt::QueuedConnection
            );
        },
        [this, guard = QPointer<AIBridge>(this)](int code, const std::string& errorMsg) {
            if (!guard) return;
            QString qMsg = QString::fromStdString(errorMsg);
            QMetaObject::invokeMethod(
                guard.data(),
                [guard, code, qMsg]() {
                    if (guard) {
                        guard->handleError(code, qMsg);
                    }
                },
                Qt::QueuedConnection
            );
        },
        [this, guard = QPointer<AIBridge>(this)]() {
            if (!guard) return;
            QMetaObject::invokeMethod(
                guard.data(),
                [guard]() {
                    if (guard) {
                        guard->handleToken("", true);
                    }
                },
                Qt::QueuedConnection
            );
        }
    );
}

void AIBridge::cancel() {
    if (m_manager) {
        m_manager->cancel();
    }
    m_isGenerating = false;
    emit isGeneratingChanged();
    emit connectionStateChanged();
    emit statusMessageChanged();
}

void AIBridge::clear() {
    cancel();
    m_currentResponse.clear();
    m_tokenCount = 0;
    m_lastError.clear();
    emit currentResponseChanged();
    emit tokenCountChanged();
    emit statusMessageChanged();
}

void AIBridge::handleToken(const QString& token, bool finished) {
    if (!token.isEmpty()) {
        m_currentResponse += token;
        m_tokenCount++;
        emit currentResponseChanged();
        emit tokenCountChanged();
        emit tokenReceived(token);
    }

    if (finished) {
        m_isGenerating = false;
        if (m_manager && !m_currentResponse.isEmpty()) {
            m_manager->appendAssistantMessage(m_currentResponse.toStdString());
        }
        emit isGeneratingChanged();
        emit connectionStateChanged();
        emit statusMessageChanged();
        emit generationFinished(m_currentResponse);
    }
}

void AIBridge::handleError(int code, const QString& message) {
    m_isGenerating = false;
    QString safeMsg = QString::fromStdString(KeyStore::instance().redact(message.toStdString()));
    m_lastError = QString("API Error (%1): %2").arg(code).arg(safeMsg);
    m_currentResponse = QString("[NEURAL GATEWAY ERROR: %1]\n%2\n\nCheck API Key in Settings or switch to Local Mock Provider.").arg(code).arg(safeMsg);

    emit isGeneratingChanged();
    emit currentResponseChanged();
    emit connectionStateChanged();
    emit statusMessageChanged();
    emit errorOccurred(code, safeMsg);
}

CommandSafetyLevel AIBridge::evaluateCommand(const QString& command, QString* reasonOut) {
    QString trimmed = command.trimmed();

    if (trimmed.isEmpty()) {
        if (reasonOut) {
            *reasonOut = "INVALID: Empty command string. Command execution rejected.";
        }
        return CommandSafetyLevel::Invalid;
    }

    const QString dangerousChars = ";&|><$`\n\r\\(){}*?";
    for (const QChar& ch : dangerousChars) {
        if (trimmed.contains(ch)) {
            if (reasonOut) {
                *reasonOut = QString("DANGEROUS: Command contains shell metacharacter '%1'. Shell chaining, redirection, or expansion blocked.").arg(ch);
            }
            return CommandSafetyLevel::Dangerous;
        }
    }

    QStringList tokens = trimmed.split(QChar(' '), Qt::SkipEmptyParts);
    if (tokens.isEmpty()) {
        if (reasonOut) {
            *reasonOut = "INVALID: No executable tokens found.";
        }
        return CommandSafetyLevel::Invalid;
    }

    QString binary = tokens[0].toLower();
    int lastSlash = binary.lastIndexOf('/');
    if (lastSlash != -1) {
        binary = binary.mid(lastSlash + 1);
    }

    static const QStringList dangerousBinaries = {
        "rm", "rmdir", "dd", "mkfs", "fdisk", "parted", "gdisk", "sfdisk",
        "wipefs", "blkdiscard", "shred", "truncate", "format", "shutdown",
        "reboot", "poweroff", "init", "kill", "killall", "pkill", "chown",
        "chmod", "sudo", "su", "doas", "pkexec", "iptables", "nft",
        "systemctl", "journalctl", "mount", "umount", "losetup", "mkswap",
        "swapon", "swapoff", "mkfifo", "mknod", "sh", "bash", "zsh", "ksh",
        "csh", "dash", "python", "python3", "perl", "ruby", "lua", "node",
        "php", "eval", "exec", "env"
    };

    if (dangerousBinaries.contains(binary)) {
        if (reasonOut) {
            *reasonOut = QString("DANGEROUS: Destructive utility, partition tool, privilege escalation, or script interpreter ('%1') detected. Blocked.").arg(binary);
        }
        return CommandSafetyLevel::Dangerous;
    }

    for (int i = 1; i < tokens.size(); ++i) {
        QString arg = tokens[i].toLower();
        if (arg.contains("/dev/") || arg == "-rf" || arg == "-fr" ||
            arg == "--recursive" || arg == "--force" || arg == "-delete") {
            if (reasonOut) {
                *reasonOut = QString("DANGEROUS: Dangerous command argument '%1' detected. Blocked.").arg(arg);
            }
            return CommandSafetyLevel::Dangerous;
        }
    }

    if (binary == "pwd" || binary == "whoami" || binary == "uptime" || binary == "date") {
        if (tokens.size() == 1) {
            if (reasonOut) {
                *reasonOut = "SAFE: Verified read-only inspection command (Classification is not authorization to execute).";
            }
            return CommandSafetyLevel::Safe;
        }
    }

    if (binary == "uname") {
        bool allSafeFlags = true;
        for (int i = 1; i < tokens.size(); ++i) {
            QString arg = tokens[i];
            if (arg != "-a" && arg != "-r" && arg != "-m" && arg != "-s" && arg != "-v" && arg != "-n") {
                allSafeFlags = false;
                break;
            }
        }
        if (allSafeFlags) {
            if (reasonOut) {
                *reasonOut = "SAFE: Verified read-only system information command (Classification is not authorization to execute).";
            }
            return CommandSafetyLevel::Safe;
        }
    }

    if (binary == "git") {
        if (tokens.size() >= 2) {
            QString subCmd = tokens[1].toLower();
            if (subCmd == "status" || subCmd == "log" || subCmd == "diff" ||
                subCmd == "branch" || subCmd == "show" || (subCmd == "remote" && tokens.size() == 3 && tokens[2] == "-v")) {
                if (reasonOut) {
                    *reasonOut = "SAFE: Verified read-only git inspection command (Classification is not authorization to execute).";
                }
                return CommandSafetyLevel::Safe;
            }
        }
    }

    if (binary == "ls") {
        bool allSafeArgs = true;
        for (int i = 1; i < tokens.size(); ++i) {
            QString arg = tokens[i];
            if (arg.startsWith("-")) {
                if (arg != "-l" && arg != "-la" && arg != "-al" && arg != "-a" &&
                    arg != "-lh" && arg != "-h" && arg != "-1" && arg != "--color" && arg != "--color=auto") {
                    allSafeArgs = false;
                    break;
                }
            } else if (arg.startsWith("/") || arg.contains("..")) {
                allSafeArgs = false;
                break;
            }
        }
        if (allSafeArgs) {
            if (reasonOut) {
                *reasonOut = "SAFE: Verified read-only directory listing (Classification is not authorization to execute).";
            }
            return CommandSafetyLevel::Safe;
        }
    }

    if (reasonOut) {
        *reasonOut = QString("SENSITIVE: Unvetted or unknown command ('%1'). Not in safe read-only whitelist. Manual verification required.").arg(binary);
    }
    return CommandSafetyLevel::Sensitive;
}

QString AIBridge::checkCommandSafety(const QString& command) {
    QString reason;
    evaluateCommand(command, &reason);
    return reason;
}

} // namespace sritec::ai
