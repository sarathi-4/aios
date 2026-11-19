#include "action_dispatcher.hpp"
#include "../security/jarvis_security_manager.hpp"
#include "../vision/camera_service.hpp"
#include "app_launch_manager.hpp"
#include "app_launcher.hpp"
#include "desktop_manager.hpp"
#include "sritec/ai/ai_bridge.hpp"
#include "sritec/logger.hpp"

namespace sritec::jarvis {

ActionDispatcher::ActionDispatcher(
    JarvisSecurityManager* security,
    sritec::shell::AppLaunchManager* appLaunchMgr,
    sritec::shell::AppLauncher* launcher,
    sritec::shell::DesktopManager* desktopMgr,
    sritec::ai::AIBridge* aiBridge,
    CameraService* cameraSvc,
    QObject* parent)
    : QObject(parent)
    , m_security(security)
    , m_appLaunchMgr(appLaunchMgr)
    , m_launcher(launcher)
    , m_desktopMgr(desktopMgr)
    , m_aiBridge(aiBridge)
    , m_cameraSvc(cameraSvc)
{
    sritec::Logger::instance().info("ACTION_DISP", "ActionDispatcher initialized with approved system API bridges.");
}

bool ActionDispatcher::executeIntent(const IntentResult& intent, QString& feedbackText, QString& spokenResponse) {
    if (m_security && !m_security->isActionPermitted(intent.action, intent.target)) {
        feedbackText = "Action blocked by JARVIS security policy: unauthorized system command.";
        spokenResponse = "I cannot execute that command due to security restrictions.";
        emit actionExecuted(intent.action, intent.target, false);
        return false;
    }

    switch (intent.type) {
        case IntentType::AppLaunch: {
            QString appId = intent.target;
            QString appName = (m_launcher) ? m_launcher->getAppName(appId) : appId;

            sritec::Logger::instance().info("ACTION_DISP", QString("Executing AppLaunch: %1").arg(appId).toStdString());

            if (m_appLaunchMgr) {
                m_appLaunchMgr->requestAppLaunch(appId);
                feedbackText = QString("Launching %1...").arg(appName);
                if (intent.detectedLanguage == "ta") {
                    spokenResponse = QString("%1 திறக்கிறேன்.").arg(appName);
                } else if (intent.detectedLanguage == "hi") {
                    spokenResponse = QString("%1 खोल रहा हूँ.").arg(appName);
                } else {
                    spokenResponse = QString("Opening %1 for you, sir.").arg(appName);
                }
                emit actionExecuted("app_launch", appId, true);
                return true;
            }
            break;
        }

        case IntentType::CameraControl: {
            if (intent.action == "turn_on") {
                if (m_cameraSvc) {
                    bool ok = m_cameraSvc->startCamera();
                    if (ok) {
                        feedbackText = "Camera stream activated.";
                        spokenResponse = (intent.detectedLanguage == "ta") ? "கேமரா ஆன் செய்யப்பட்டது." : "Vision sensors online.";
                        emit actionExecuted("camera_control", "on", true);
                        return true;
                    } else {
                        feedbackText = "Camera permission required from user.";
                        spokenResponse = "Camera permission has not been granted.";
                        emit actionExecuted("camera_control", "on", false);
                        return false;
                    }
                }
            } else {
                if (m_cameraSvc) {
                    m_cameraSvc->stopCamera();
                    feedbackText = "Camera turned off.";
                    spokenResponse = (intent.detectedLanguage == "ta") ? "கேமரா மூடப்பட்டது." : "Vision sensors offline.";
                    emit actionExecuted("camera_control", "off", true);
                    return true;
                }
            }
            break;
        }

        case IntentType::WindowControl: {
            if (!m_appLaunchMgr) break;
            QString focusedWin = m_appLaunchMgr->focusedWindowId();
            if (focusedWin.isEmpty()) {
                feedbackText = "No active application window to control.";
                spokenResponse = "There are no active windows open.";
                return false;
            }

            if (intent.action == "close") {
                m_appLaunchMgr->closeWindow(focusedWin);
                feedbackText = "Window closed.";
                spokenResponse = (intent.detectedLanguage == "ta") ? "விண்டோ மூடப்பட்டது." : "Window closed, sir.";
                emit actionExecuted("window_control", "close", true);
                return true;
            } else if (intent.action == "minimize") {
                m_appLaunchMgr->minimizeWindow(focusedWin);
                feedbackText = "Window minimized.";
                spokenResponse = "Window minimized.";
                emit actionExecuted("window_control", "minimize", true);
                return true;
            } else if (intent.action == "maximize") {
                m_appLaunchMgr->toggleMaximizeWindow(focusedWin);
                feedbackText = "Window toggled maximize.";
                spokenResponse = "Window maximized.";
                emit actionExecuted("window_control", "maximize", true);
                return true;
            }
            break;
        }

        case IntentType::WorkspaceSwitch: {
            int wsIndex = intent.parameters.value("workspaceIndex", 0).toInt();
            emit workspaceSwitchRequested(wsIndex);
            feedbackText = QString("Switched to workspace %1.").arg(wsIndex);
            spokenResponse = QString("Switched workspace.");
            emit actionExecuted("workspace_switch", QString::number(wsIndex), true);
            return true;
        }

        case IntentType::SystemStatus: {
            if (m_appLaunchMgr) {
                m_appLaunchMgr->requestAppLaunch("monitor");
                feedbackText = "Displaying system telemetry and diagnostics...";
                spokenResponse = (intent.detectedLanguage == "ta") ? "சிஸ்டம் நிலை காட்டப்படுகிறது." : "All systems operating normally, sir.";
                emit actionExecuted("system_status", "monitor", true);
                return true;
            }
            break;
        }

        case IntentType::SearchFiles: {
            if (m_appLaunchMgr) {
                m_appLaunchMgr->requestAppLaunch("files");
                feedbackText = "Opening spatial files and project catalog...";
                spokenResponse = "Accessing your workspace files now.";
                emit actionExecuted("search_files", "files", true);
                return true;
            }
            break;
        }

        case IntentType::StopListening: {
            feedbackText = "JARVIS voice listening paused.";
            spokenResponse = "Standing by.";
            emit actionExecuted("stop_listening", "assistant", true);
            return true;
        }

        case IntentType::GeneralQuery: {
            if (m_aiBridge) {
                m_aiBridge->sendQuery(intent.rawQuery);
                feedbackText = "Synthesizing response through Neural Gateway...";
                spokenResponse = "Processing your query, sir.";
                emit actionExecuted("general_query", "ai_gateway", true);
                return true;
            }
            break;
        }

        default:
            break;
    }

    feedbackText = "Command recognized, but no matching system action could be executed.";
    spokenResponse = "I could not complete that request.";
    emit actionExecuted("unknown", intent.rawQuery, false);
    return false;
}

} // namespace sritec::jarvis
