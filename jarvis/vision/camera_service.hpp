#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QTimer>
#include <QImage>
#include "jarvis_types.hpp"

namespace sritec::jarvis {

class JarvisSecurityManager;

class CameraService : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isRunning READ isRunning NOTIFY runningStateChanged)
    Q_PROPERTY(bool hasPermission READ hasPermission NOTIFY permissionChanged)
    Q_PROPERTY(QVariantList availableCameras READ availableCameras NOTIFY availableCamerasChanged)
    Q_PROPERTY(int selectedCameraIndex READ selectedCameraIndex WRITE setSelectedCameraIndex NOTIFY selectedCameraIndexChanged)
    Q_PROPERTY(int targetFps READ targetFps WRITE setTargetFps NOTIFY targetFpsChanged)
    Q_PROPERTY(bool isLowResourceMode READ isLowResourceMode WRITE setLowResourceMode NOTIFY lowResourceModeChanged)

public:
    explicit CameraService(JarvisSecurityManager* securityMgr, QObject* parent = nullptr);
    ~CameraService() override = default;

    bool isRunning() const { return m_isRunning; }
    bool hasPermission() const;

    QVariantList availableCameras() const { return m_availableCameras; }
    int selectedCameraIndex() const { return m_selectedCameraIndex; }
    void setSelectedCameraIndex(int index);

    int targetFps() const { return m_targetFps; }
    void setTargetFps(int fps);

    bool isLowResourceMode() const { return m_lowResourceMode; }
    void setLowResourceMode(bool lowResource);

    Q_INVOKABLE bool startCamera();
    Q_INVOKABLE void stopCamera();
    Q_INVOKABLE void toggleCamera();
    Q_INVOKABLE void scanDevices();

signals:
    void runningStateChanged(bool running);
    void permissionChanged(bool hasPerm);
    void availableCamerasChanged();
    void selectedCameraIndexChanged(int index);
    void targetFpsChanged(int fps);
    void lowResourceModeChanged(bool lowResource);
    void frameReady(const QImage& frame);
    void handLandmarksDetected(const QVariantList& landmarks);

private slots:
    void captureNextFrame();

private:
    JarvisSecurityManager* m_security;
    bool m_isRunning{false};
    QVariantList m_availableCameras;
    int m_selectedCameraIndex{0};
    int m_targetFps{30};
    bool m_lowResourceMode{false};
    QTimer* m_frameTimer{nullptr};
    double m_simAngle{0.0};
};

} // namespace sritec::jarvis
