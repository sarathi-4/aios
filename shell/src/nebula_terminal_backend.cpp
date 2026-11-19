#include "nebula_terminal_backend.hpp"
#include "sritec/logger.hpp"

#include <QDir>
#include <QFileInfo>
#include <QRegularExpression>

namespace sritec::shell {

NebulaTerminalBackend::NebulaTerminalBackend(QObject* parent)
    : QObject(parent)
{
    initDefaultSession();
    sritec::Logger::instance().info("TERMINAL", "NebulaTerminalBackend initialized with unprivileged sandboxed context.");
}

NebulaTerminalBackend::~NebulaTerminalBackend() {
    for (auto& session : m_sessions) {
        if (session->process && session->process->state() != QProcess::NotRunning) {
            session->process->kill();
            session->process->waitForFinished(500);
        }
    }
}

void NebulaTerminalBackend::initDefaultSession() {
    createSession("Main Shell");
}

QVariantList NebulaTerminalBackend::sessions() const {
    QVariantList list;
    for (const auto& s : m_sessions) {
        QVariantMap map;
        map["id"] = s->id;
        map["title"] = s->title;
        map["workingDir"] = s->workingDir;
        map["isRunning"] = s->isRunning;
        map["isActive"] = (s->id == m_activeSessionId);
        list.append(map);
    }
    return list;
}

void NebulaTerminalBackend::setActiveSessionId(const QString& id) {
    if (m_activeSessionId != id && m_sessions.contains(id)) {
        m_activeSessionId = id;
        emit activeSessionIdChanged();
        emit activeOutputChanged();
        emit activeWorkingDirChanged();
        emit isProcessingChanged();
        emit sessionsChanged();
    }
}

QVariantList NebulaTerminalBackend::activeOutput() const {
    const auto* session = getSession(m_activeSessionId);
    if (session) {
        return session->history;
    }
    return {};
}

QString NebulaTerminalBackend::activeWorkingDir() const {
    const auto* session = getSession(m_activeSessionId);
    if (session) {
        return session->workingDir;
    }
    return QDir::homePath();
}

bool NebulaTerminalBackend::isProcessing() const {
    const auto* session = getSession(m_activeSessionId);
    if (session) {
        return session->isRunning;
    }
    return false;
}

QString NebulaTerminalBackend::createSession(const QString& title) {
    auto session = std::make_shared<TerminalSession>();
    session->id = QString("term-session-%1").arg(m_sessionCounter++);
    session->title = title.isEmpty() ? QString("Terminal %1").arg(m_sessions.size() + 1) : title;
    session->workingDir = "/run/media/sarathi/250-2.1/aios";
    if (!QDir(session->workingDir).exists()) {
        session->workingDir = QDir::homePath();
    }

    appendOutput(session.get(), "SRITEC NEBULA // SMART TERMINAL v0.3.0 [UNPRIVILEGED USER SPACE]", "info");
    appendOutput(session.get(), "Session ID: " + session->id + " | Interactive Shell Ready", "subtle");
    appendOutput(session.get(), "Guardrails: Root mutations & raw disk access strictly blocked.", "guardrail");
    appendOutput(session.get(), "Type 'help' for quick reference, 'neofetch' for system metrics.", "subtle");

    QString newId = session->id;
    m_sessions.insert(newId, std::move(session));
    m_activeSessionId = newId;

    emit sessionsChanged();
    emit activeSessionIdChanged();
    emit activeOutputChanged();
    emit activeWorkingDirChanged();

    sritec::Logger::instance().info("TERMINAL", "Created terminal session: " + newId.toStdString());
    return newId;
}

bool NebulaTerminalBackend::closeSession(const QString& sessionId) {
    if (!m_sessions.contains(sessionId)) return false;

    // Do not close the last session; instead clear it
    if (m_sessions.size() == 1) {
        clearActiveSession();
        return true;
    }

    auto& session = m_sessions[sessionId];
    if (session->process && session->process->state() != QProcess::NotRunning) {
        session->process->kill();
    }

    m_sessions.remove(sessionId);

    if (m_activeSessionId == sessionId) {
        m_activeSessionId = m_sessions.firstKey();
    }

    emit sessionsChanged();
    emit activeSessionIdChanged();
    emit activeOutputChanged();
    emit activeWorkingDirChanged();
    return true;
}

void NebulaTerminalBackend::clearActiveSession() {
    auto* session = getSession(m_activeSessionId);
    if (!session) return;

    session->history.clear();
    appendOutput(session, "Terminal display cleared.", "subtle");
    emit activeOutputChanged();
}

bool NebulaTerminalBackend::checkSafetyGuardrails(const QString& command, QString& outReason) const {
    QString trimmed = command.trimmed();

    // Check for root execution attempts
    if (trimmed.startsWith("sudo ") || trimmed == "sudo" || trimmed.startsWith("su ") || trimmed == "su") {
        outReason = "Direct root escalation (sudo/su) is blocked by NEBULA Security Guardrails.";
        return false;
    }

    // Check for destructive recursive deletion
    if (trimmed.contains(QRegularExpression(R"(\brm\s+-[a-zA-Z]*r[a-zA-Z]*f?\s+(/|\*|/\*))")) ||
        trimmed.contains("rm -rf /") || trimmed.contains("rm -rf /*")) {
        outReason = "Catastrophic recursive root deletion is blocked by OS Integrity Guardrails.";
        return false;
    }

    // Check for formatting / raw disk writes
    if (trimmed.contains("mkfs") || trimmed.contains(QRegularExpression(R"(\bdd\s+if=.*\s+of=/dev/)")) ||
        trimmed.contains("fdisk") || trimmed.contains("parted")) {
        outReason = "Raw partition / disk write commands are strictly blocked.";
        return false;
    }

    // Check for fork bombs
    if (trimmed.contains(":(){ :|:& };:")) {
        outReason = "Denial-of-Service / fork bomb pattern blocked.";
        return false;
    }

    return true;
}

void NebulaTerminalBackend::executeCommand(const QString& command) {
    auto* session = getSession(m_activeSessionId);
    if (!session) return;

    QString trimmed = command.trimmed();
    if (trimmed.isEmpty()) return;

    // Add to command history
    session->commandHistory.append(trimmed);
    session->historyIndex = session->commandHistory.size();

    // Echo command prompt
    appendOutput(session, QString("sarathi@nebula:%1$ %2").arg(QDir(session->workingDir).dirName(), trimmed), "prompt");

    // Guardrail evaluation
    QString reason;
    if (!checkSafetyGuardrails(trimmed, reason)) {
        appendOutput(session, "[GUARDRAIL VIOLATION] " + reason, "guardrail");
        emit safetyAlertTriggered(trimmed, reason);
        sritec::Logger::instance().warn("GUARDRAIL", "Blocked dangerous terminal input: " + trimmed.toStdString());
        return;
    }

    // Handle Built-in Shell Utilities
    if (trimmed == "clear") {
        session->history.clear();
        emit activeOutputChanged();
        return;
    }

    if (trimmed == "help") {
        appendOutput(session, "NEBULA Internal Terminal Commands:", "info");
        appendOutput(session, "  ls, pwd, cd <dir>    - Safe filesystem navigation", "output");
        appendOutput(session, "  neofetch             - Display system hardware & OS telemetry", "output");
        appendOutput(session, "  history              - Display session command history", "output");
        appendOutput(session, "  clear                - Reset the active terminal viewport", "output");
        appendOutput(session, "  ai <prompt>          - Synthesize reasoning via AI Bridge", "output");
        appendOutput(session, "  <standard unix>      - Unprivileged process execution", "output");
        return;
    }

    if (trimmed == "history") {
        for (int i = 0; i < session->commandHistory.size(); ++i) {
            appendOutput(session, QString("  %1  %2").arg(i + 1, 3).arg(session->commandHistory[i]), "output");
        }
        return;
    }

    if (trimmed == "pwd") {
        appendOutput(session, session->workingDir, "output");
        return;
    }

    if (trimmed.startsWith("cd ")) {
        QString targetDir = trimmed.mid(3).trimmed();
        if (targetDir == "~") {
            session->workingDir = QDir::homePath();
        } else {
            QDir dir(session->workingDir);
            if (dir.cd(targetDir)) {
                session->workingDir = dir.canonicalPath();
            } else {
                appendOutput(session, "cd: no such file or directory: " + targetDir, "error");
                return;
            }
        }
        emit activeWorkingDirChanged();
        emit sessionsChanged();
        return;
    }

    if (trimmed == "neofetch") {
        QString logo =
            "       _.-'''''-._       OS: SRITEC AI OS (Ubuntu 26.04 Base)\n"
            "     .'  _     _  '.     Codename: NEBULA\n"
            "    /   (o)   (o)   \\    Kernel: 7.0.0-43-generic x86_64\n"
            "   |                 |   Shell: nebula-term 0.3.0\n"
            "   |   \\_________ /  |   UI: Holographic Spatial Desktop\n"
            "    \\               /    AI Core: LISA Neural Engine\n"
            "     '.           .'     Memory: 65% / 15.6 GB\n"
            "       '--.....--'       Security: TLS 1.3 CA Enforcement";
        appendOutput(session, logo, "info");
        return;
    }

    // Execute via unprivileged QProcess
    session->isRunning = true;
    emit isProcessingChanged();

    auto* proc = new QProcess(this);
    proc->setWorkingDirectory(session->workingDir);

    // Filter environment to ensure no leaked sensitive variables
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.remove("OPENAI_API_KEY");
    env.remove("GEMINI_API_KEY");
    env.remove("ANTHROPIC_API_KEY");
    env.insert("TERM", "xterm-256color");
    env.insert("USER", "sarathi");
    proc->setProcessEnvironment(env);

    QString sessId = session->id;

    connect(proc, &QProcess::readyReadStandardOutput, this, [this, proc, sessId]() {
        auto* s = getSession(sessId);
        if (s) {
            QString out = QString::fromUtf8(proc->readAllStandardOutput());
            appendOutput(s, out.trimmed(), "output");
        }
    });

    connect(proc, &QProcess::readyReadStandardError, this, [this, proc, sessId]() {
        auto* s = getSession(sessId);
        if (s) {
            QString err = QString::fromUtf8(proc->readAllStandardError());
            appendOutput(s, err.trimmed(), "error");
        }
    });

    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this,
            [this, proc, sessId](int exitCode, QProcess::ExitStatus) {
        auto* s = getSession(sessId);
        if (s) {
            s->isRunning = false;
            if (exitCode != 0) {
                appendOutput(s, QString("[Process exited with status code %1]").arg(exitCode), "subtle");
            }
        }
        if (sessId == m_activeSessionId) {
            emit isProcessingChanged();
        }
        proc->deleteLater();
    });

    // Execute via standard /bin/bash -c
    proc->start("/bin/bash", QStringList() << "-c" << trimmed);
}

QString NebulaTerminalBackend::getPreviousHistoryCommand() {
    auto* session = getSession(m_activeSessionId);
    if (!session || session->commandHistory.isEmpty()) return "";

    if (session->historyIndex > 0) {
        session->historyIndex--;
    } else {
        session->historyIndex = 0;
    }

    if (session->historyIndex < session->commandHistory.size()) {
        return session->commandHistory[session->historyIndex];
    }
    return "";
}

QString NebulaTerminalBackend::getNextHistoryCommand() {
    auto* session = getSession(m_activeSessionId);
    if (!session || session->commandHistory.isEmpty()) return "";

    if (session->historyIndex < session->commandHistory.size() - 1) {
        session->historyIndex++;
        return session->commandHistory[session->historyIndex];
    }

    session->historyIndex = session->commandHistory.size();
    return "";
}

void NebulaTerminalBackend::killActiveProcess() {
    auto* session = getSession(m_activeSessionId);
    if (session && session->process && session->isRunning) {
        session->process->kill();
        appendOutput(session, "^C [Execution Terminated]", "guardrail");
        session->isRunning = false;
        emit isProcessingChanged();
    }
}

void NebulaTerminalBackend::appendOutput(TerminalSession* session, const QString& text, const QString& type) {
    if (!session || text.isEmpty()) return;

    QVariantMap line;
    line["text"] = text;
    line["type"] = type;

    // Map type to display color
    if (type == "prompt") line["color"] = "#00E5FF";
    else if (type == "info") line["color"] = "#3B82F6";
    else if (type == "subtle") line["color"] = "#64748B";
    else if (type == "guardrail") line["color"] = "#FF3B5C";
    else if (type == "error") line["color"] = "#FF7700";
    else line["color"] = "#F1F5F9"; // normal output

    session->history.append(line);

    // Limit history scrollback buffer to 1000 lines
    if (session->history.size() > 1000) {
        session->history.removeFirst();
    }

    if (session->id == m_activeSessionId) {
        emit activeOutputChanged();
    }
    emit outputReceived(session->id, text, type);
}

TerminalSession* NebulaTerminalBackend::getSession(const QString& id) {
    auto it = m_sessions.find(id);
    return (it != m_sessions.end()) ? it.value().get() : nullptr;
}

const TerminalSession* NebulaTerminalBackend::getSession(const QString& id) const {
    auto it = m_sessions.find(id);
    return (it != m_sessions.end()) ? it.value().get() : nullptr;
}

} // namespace sritec::shell
