#pragma once

#include <QObject>
#include <QString>
#include <QDateTime>

namespace sritec::jarvis {

class JarvisSecurityManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isMicrophonePermitted READ isMicrophonePermitted NOTIFY microphonePermissionChanged)
    Q_PROPERTY(bool isCameraPermitted READ isCameraPermitted NOTIFY cameraPermissionChanged)
    Q_PROPERTY(bool isMicrophoneMuted READ isMicrophoneMuted WRITE setMicrophoneMuted NOTIFY microphoneMutedChanged)
    Q_PROPERTY(bool isCameraHardwareBlocked READ isCameraHardwareBlocked NOTIFY cameraBlockedChanged)
    Q_PROPERTY(QString privacyStatusReport READ privacyStatusReport NOTIFY privacyReportChanged)

public:
    explicit JarvisSecurityManager(QObject* parent = nullptr);
    ~JarvisSecurityManager() override = default;

    bool isMicrophonePermitted() const { return m_microphonePermitted; }
    bool isCameraPermitted() const { return m_cameraPermitted; }
    bool isMicrophoneMuted() const { return m_microphoneMuted; }
    bool isCameraHardwareBlocked() const { return m_cameraBlocked; }
    QString privacyStatusReport() const;

    Q_INVOKABLE bool requestMicrophonePermission();
    Q_INVOKABLE void revokeMicrophonePermission();

    Q_INVOKABLE bool requestCameraPermission();
    Q_INVOKABLE void revokeCameraPermission();

    Q_INVOKABLE void setMicrophoneMuted(bool muted);
    Q_INVOKABLE void emergencyShutdownAllSensors();

    // Security validation against raw shell commands
    bool isActionPermitted(const QString& actionType, const QString& target) const;
    bool isDestructiveAction(const QString& actionType, const QString& target) const;

signals:
    void microphonePermissionChanged(bool permitted);
    void cameraPermissionChanged(bool permitted);
    void microphoneMutedChanged(bool muted);
    void cameraBlockedChanged(bool blocked);
    void privacyReportChanged();
    void securityViolationBlocked(const QString& attemptedAction, const QString& reason);

private:
    bool m_microphonePermitted{true};   // Audio listening enabled with user notification
    bool m_cameraPermitted{false};      // Camera STRICTLY OFF by default per specs
    bool m_microphoneMuted{false};
    bool m_cameraBlocked{false};
};

} // namespace sritec::jarvis
