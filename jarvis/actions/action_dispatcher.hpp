#pragma once

#include <QObject>
#include <QString>
#include <functional>
#include "../core/jarvis_types.hpp"

namespace sritec::shell {
    class AppLaunchManager;
    class AppLauncher;
    class DesktopManager;
}

namespace sritec::ai {
    class AIBridge;
}

namespace sritec::jarvis {

class JarvisSecurityManager;
class CameraService;

class ActionDispatcher : public QObject {
    Q_OBJECT

public:
    explicit ActionDispatcher(
        JarvisSecurityManager* security,
        sritec::shell::AppLaunchManager* appLaunchMgr,
        sritec::shell::AppLauncher* launcher,
        sritec::shell::DesktopManager* desktopMgr,
        sritec::ai::AIBridge* aiBridge,
        CameraService* cameraSvc,
        QObject* parent = nullptr);

    ~ActionDispatcher() override = default;

    // Executes the parsed intent through validated APIs
    bool executeIntent(const IntentResult& intent, QString& feedbackText, QString& spokenResponse);

signals:
    void actionExecuted(const QString& action, const QString& target, bool success);
    void actionRequiresConfirmation(const QString& action, const QString& prompt);
    void workspaceSwitchRequested(int index);

private:
    JarvisSecurityManager* m_security;
    sritec::shell::AppLaunchManager* m_appLaunchMgr;
    sritec::shell::AppLauncher* m_launcher;
    sritec::shell::DesktopManager* m_desktopMgr;
    sritec::ai::AIBridge* m_aiBridge;
    CameraService* m_cameraSvc;
};

} // namespace sritec::jarvis
