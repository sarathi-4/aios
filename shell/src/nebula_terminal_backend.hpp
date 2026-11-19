#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QProcess>
#include <QMap>
#include <memory>

namespace sritec::shell {

struct TerminalSession {
    QString id;
    QString title;
    QString workingDir;
    QVariantList history;
    QStringList commandHistory;
    int historyIndex{-1};
    std::unique_ptr<QProcess> process;
    bool isRunning{false};
};

class NebulaTerminalBackend : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantList sessions READ sessions NOTIFY sessionsChanged)
    Q_PROPERTY(QString activeSessionId READ activeSessionId WRITE setActiveSessionId NOTIFY activeSessionIdChanged)
    Q_PROPERTY(QVariantList activeOutput READ activeOutput NOTIFY activeOutputChanged)
    Q_PROPERTY(QString activeWorkingDir READ activeWorkingDir NOTIFY activeWorkingDirChanged)
    Q_PROPERTY(bool isProcessing READ isProcessing NOTIFY isProcessingChanged)
    Q_PROPERTY(int sessionCount READ sessionCount NOTIFY sessionsChanged)

public:
    explicit NebulaTerminalBackend(QObject* parent = nullptr);
    ~NebulaTerminalBackend() override;

    QVariantList sessions() const;
    QString activeSessionId() const { return m_activeSessionId; }
    void setActiveSessionId(const QString& id);

    QVariantList activeOutput() const;
    QString activeWorkingDir() const;
    bool isProcessing() const;
    int sessionCount() const { return m_sessions.size(); }

    // Session Management
    Q_INVOKABLE QString createSession(const QString& title = QString());
    Q_INVOKABLE bool closeSession(const QString& sessionId);
    Q_INVOKABLE void clearActiveSession();

    // Command Execution & Input
    Q_INVOKABLE void executeCommand(const QString& command);
    Q_INVOKABLE QString getPreviousHistoryCommand();
    Q_INVOKABLE QString getNextHistoryCommand();
    Q_INVOKABLE void killActiveProcess();

signals:
    void sessionsChanged();
    void activeSessionIdChanged();
    void activeOutputChanged();
    void activeWorkingDirChanged();
    void isProcessingChanged();

    void commandExecuted(const QString& sessionId, const QString& command);
    void outputReceived(const QString& sessionId, const QString& text, const QString& type);
    void safetyAlertTriggered(const QString& command, const QString& reason);

private:
    void initDefaultSession();
    void appendOutput(TerminalSession* session, const QString& text, const QString& type);
    bool checkSafetyGuardrails(const QString& command, QString& outReason) const;
    TerminalSession* getSession(const QString& id);
    const TerminalSession* getSession(const QString& id) const;

    QMap<QString, std::shared_ptr<TerminalSession>> m_sessions;
    QString m_activeSessionId;
    int m_sessionCounter{1};
};

} // namespace sritec::shell
