#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QProcess>
#include <QMap>
#include <QDateTime>

namespace sritec::shell {

struct ProposedChange {
    QString id;
    QString filePath;
    QString originalContent;
    QString proposedContent;
    QString explanation;
    QVariantList diffLines;
    QString status{"pending"}; // "pending", "approved", "rejected"
    QDateTime timestamp;
};

class NebulaDevWorkstation : public QObject {
    Q_OBJECT

    // Workspace Mode: "vscode", "antigravity", "android_studio", "overview"
    Q_PROPERTY(QString activeMode READ activeMode WRITE setActiveMode NOTIFY activeModeChanged)

    // IDE Availability Statuses
    Q_PROPERTY(bool isVSCodeInstalled READ isVSCodeInstalled NOTIFY idesAudited)
    Q_PROPERTY(QString vsCodePath READ vsCodePath NOTIFY idesAudited)
    Q_PROPERTY(bool isAntigravityActive READ isAntigravityActive NOTIFY idesAudited)
    Q_PROPERTY(QString antigravityHome READ antigravityHome NOTIFY idesAudited)
    Q_PROPERTY(bool isAndroidStudioInstalled READ isAndroidStudioInstalled NOTIFY idesAudited)
    Q_PROPERTY(QString androidStudioPath READ androidStudioPath NOTIFY idesAudited)
    Q_PROPERTY(bool isAndroidSdkAvailable READ isAndroidSdkAvailable NOTIFY idesAudited)
    Q_PROPERTY(QString androidSdkPath READ androidSdkPath NOTIFY idesAudited)
    Q_PROPERTY(QVariantList androidSdkComponents READ androidSdkComponents NOTIFY idesAudited)
    Q_PROPERTY(QVariantList installedJdks READ installedJdks NOTIFY idesAudited)

    // Tool & CLI Availability
    Q_PROPERTY(bool isDockerAvailable READ isDockerAvailable NOTIFY toolsAudited)
    Q_PROPERTY(bool isAwsAvailable READ isAwsAvailable NOTIFY toolsAudited)
    Q_PROPERTY(bool isClaudeCodeAvailable READ isClaudeCodeAvailable NOTIFY toolsAudited)
    Q_PROPERTY(bool isCodexAvailable READ isCodexAvailable NOTIFY toolsAudited)
    Q_PROPERTY(bool isGitAvailable READ isGitAvailable NOTIFY toolsAudited)

    // Active Build & Console Stream
    Q_PROPERTY(bool isBuilding READ isBuilding NOTIFY isBuildingChanged)
    Q_PROPERTY(QString buildOutput READ buildOutput NOTIFY buildOutputChanged)
    Q_PROPERTY(QString activeBranch READ activeBranch NOTIFY gitStatusChanged)

    // Proposed Changes for Approval
    Q_PROPERTY(QVariantList pendingChanges READ pendingChanges NOTIFY pendingChangesChanged)
    Q_PROPERTY(int pendingChangeCount READ pendingChangeCount NOTIFY pendingChangesChanged)

public:
    explicit NebulaDevWorkstation(QObject* parent = nullptr);
    ~NebulaDevWorkstation() override = default;

    QString activeMode() const { return m_activeMode; }
    void setActiveMode(const QString& mode);

    bool isVSCodeInstalled() const { return m_isVSCodeInstalled; }
    QString vsCodePath() const { return m_vsCodePath; }

    bool isAntigravityActive() const { return m_isAntigravityActive; }
    QString antigravityHome() const { return m_antigravityHome; }

    bool isAndroidStudioInstalled() const { return m_isAndroidStudioInstalled; }
    QString androidStudioPath() const { return m_androidStudioPath; }

    bool isAndroidSdkAvailable() const { return m_isAndroidSdkAvailable; }
    QString androidSdkPath() const { return m_androidSdkPath; }
    QVariantList androidSdkComponents() const { return m_androidSdkComponents; }
    QVariantList installedJdks() const { return m_installedJdks; }

    bool isDockerAvailable() const { return m_isDockerAvailable; }
    bool isAwsAvailable() const { return m_isAwsAvailable; }
    bool isClaudeCodeAvailable() const { return m_isClaudeCodeAvailable; }
    bool isCodexAvailable() const { return m_isCodexAvailable; }
    bool isGitAvailable() const { return m_isGitAvailable; }

    bool isBuilding() const { return m_isBuilding; }
    QString buildOutput() const { return m_buildOutput; }
    QString activeBranch() const { return m_activeBranch; }

    QVariantList pendingChanges() const;
    int pendingChangeCount() const;

    // IDE Launch & External Bridge Invokables
    Q_INVOKABLE bool launchVSCode(const QString& projectPath = QString());
    Q_INVOKABLE bool launchAntigravity();
    Q_INVOKABLE bool launchAndroidStudio(const QString& projectPath = QString());

    // Toolbar Operations
    Q_INVOKABLE void buildProject(const QString& target = "all");
    Q_INVOKABLE void runProject();
    Q_INVOKABLE void debugProject();
    Q_INVOKABLE QVariantMap checkToolStatus(const QString& toolName);

    // AI Code Proposal & Human Approval Flow
    Q_INVOKABLE QString proposeCodeChange(const QString& filePath, const QString& newContent, const QString& explanation);
    Q_INVOKABLE bool approveChange(const QString& changeId);
    Q_INVOKABLE bool rejectChange(const QString& changeId);
    Q_INVOKABLE QVariantMap getChangeDetails(const QString& changeId) const;

    // Audit and Refresh
    Q_INVOKABLE void auditEnvironment();
    Q_INVOKABLE void refreshGitStatus();

signals:
    void activeModeChanged();
    void idesAudited();
    void toolsAudited();
    void isBuildingChanged();
    void buildOutputChanged();
    void gitStatusChanged();
    void pendingChangesChanged();
    void changeProposed(const QString& changeId, const QString& filePath);
    void changeApproved(const QString& changeId, const QString& filePath);
    void changeRejected(const QString& changeId, const QString& filePath);
    void toolCheckResult(const QString& tool, bool available, const QString& message);

private:
    void inspectIDEs();
    void inspectAndroidEnvironment();
    void inspectTools();
    QVariantList generateDiff(const QString& oldText, const QString& newText) const;

    QString m_activeMode{"overview"}; // "overview", "vscode", "antigravity", "android_studio"

    // IDE details
    bool m_isVSCodeInstalled{false};
    QString m_vsCodePath;

    bool m_isAntigravityActive{true};
    QString m_antigravityHome{"/home/sarathi/.gemini/antigravity"};

    bool m_isAndroidStudioInstalled{false};
    QString m_androidStudioPath;

    bool m_isAndroidSdkAvailable{true};
    QString m_androidSdkPath{"/home/sarathi/Android/Sdk"};
    QVariantList m_androidSdkComponents;
    QVariantList m_installedJdks;

    // Tools
    bool m_isDockerAvailable{false};
    bool m_isAwsAvailable{false};
    bool m_isClaudeCodeAvailable{false};
    bool m_isCodexAvailable{true}; // Enabled via OpenAI gateway
    bool m_isGitAvailable{true};

    bool m_isBuilding{false};
    QString m_buildOutput;
    QString m_activeBranch{"main"};

    QMap<QString, ProposedChange> m_changes;
    int m_changeCounter{1};
};

} // namespace sritec::shell
