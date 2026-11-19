#include "jarvis_security_manager.hpp"
#include "sritec/logger.hpp"

namespace sritec::jarvis {

JarvisSecurityManager::JarvisSecurityManager(QObject* parent)
    : QObject(parent)
{
    sritec::Logger::instance().info("JARVIS_SEC", "JarvisSecurityManager initialized. Camera default: OFF (Explicit Permission Enforced).");
}

QString JarvisSecurityManager::privacyStatusReport() const {
    QString micStr = m_microphonePermitted ? (m_microphoneMuted ? "MUTED" : "ACTIVE (Local VAD)") : "REVOKED";
    QString camStr = m_cameraPermitted ? "ACTIVE (Local Stream)" : "OFF (Privacy Secured)";
    return QString("MIC: %1 | CAM: %2 | Sandbox: STRICT").arg(micStr, camStr);
}

bool JarvisSecurityManager::requestMicrophonePermission() {
    m_microphonePermitted = true;
    m_microphoneMuted = false;
    emit microphonePermissionChanged(true);
    emit microphoneMutedChanged(false);
    emit privacyReportChanged();
    sritec::Logger::instance().info("JARVIS_SEC", "Microphone permission granted by user.");
    return true;
}

void JarvisSecurityManager::revokeMicrophonePermission() {
    m_microphonePermitted = false;
    m_microphoneMuted = true;
    emit microphonePermissionChanged(false);
    emit microphoneMutedChanged(true);
    emit privacyReportChanged();
    sritec::Logger::instance().warn("JARVIS_SEC", "Microphone permission revoked. Audio capture halted.");
}

bool JarvisSecurityManager::requestCameraPermission() {
    // Requires explicit user permission activation
    m_cameraPermitted = true;
    m_cameraBlocked = false;
    emit cameraPermissionChanged(true);
    emit cameraBlockedChanged(false);
    emit privacyReportChanged();
    sritec::Logger::instance().info("JARVIS_SEC", "Camera permission explicitly granted by user.");
    return true;
}

void JarvisSecurityManager::revokeCameraPermission() {
    m_cameraPermitted = false;
    emit cameraPermissionChanged(false);
    emit privacyReportChanged();
    sritec::Logger::instance().info("JARVIS_SEC", "Camera permission revoked. Camera stream terminated.");
}

void JarvisSecurityManager::setMicrophoneMuted(bool muted) {
    if (m_microphoneMuted != muted) {
        m_microphoneMuted = muted;
        emit microphoneMutedChanged(muted);
        emit privacyReportChanged();
        sritec::Logger::instance().info("JARVIS_SEC", QString("Microphone mute set to: %1").arg(muted ? "MUTED" : "UNMUTED").toStdString());
    }
}

void JarvisSecurityManager::emergencyShutdownAllSensors() {
    m_microphoneMuted = true;
    m_microphonePermitted = false;
    m_cameraPermitted = false;
    m_cameraBlocked = true;

    emit microphoneMutedChanged(true);
    emit microphonePermissionChanged(false);
    emit cameraPermissionChanged(false);
    emit cameraBlockedChanged(true);
    emit privacyReportChanged();

    sritec::Logger::instance().warn("JARVIS_SEC", "EMERGENCY SHUTDOWN ACTIVATED: All camera & microphone hardware sensors immediately terminated.");
}

bool JarvisSecurityManager::isActionPermitted(const QString& actionType, const QString& target) const {
    // Whitelisted allowed action types
    static const QStringList allowedActions = {
        "open", "app_launch", "app_close", "close", "minimize", "maximize",
        "window_minimize", "window_maximize", "window_move",
        "switch_workspace", "workspace_switch",
        "turn_on", "turn_off", "camera_toggle",
        "search", "search_files",
        "status_check", "stop_listening", "query", "general_query"
    };

    if (!allowedActions.contains(actionType)) {
        sritec::Logger::instance().warn("JARVIS_SEC", QString("Action '%1' rejected: not in approved action whitelist.").arg(actionType).toStdString());
        return false;
    }

    // Disallow raw shell / destructive command injection in target
    if (target.contains(";") || target.contains("&") || target.contains("|") ||
        target.contains("`") || target.contains("$") || target.contains(">") ||
        target.contains("<") || target.contains("rm -rf") || target.contains("sudo") ||
        target.contains("dd") || target.contains("mkfs")) {
        sritec::Logger::instance().error("JARVIS_SEC", QString("Security Alert: Dangerous characters or commands detected in target '%1'.").arg(target).toStdString());
        return false;
    }

    return true;
}

bool JarvisSecurityManager::isDestructiveAction(const QString& actionType, const QString& target) const {
    if (actionType == "system_shutdown" || actionType == "delete_file" || actionType == "format_disk" ||
        target.contains("delete") || target.contains("format") || target.contains("wipe")) {
        return true;
    }
    return false;
}

} // namespace sritec::jarvis
