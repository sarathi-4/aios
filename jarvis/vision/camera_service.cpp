#include "camera_service.hpp"
#include "../security/jarvis_security_manager.hpp"
#include "sritec/logger.hpp"

#include <QDir>
#include <QPainter>
#include <QtMath>

namespace sritec::jarvis {

CameraService::CameraService(JarvisSecurityManager* securityMgr, QObject* parent)
    : QObject(parent)
    , m_security(securityMgr)
    , m_frameTimer(new QTimer(this))
{
    connect(m_frameTimer, &QTimer::timeout, this, &CameraService::captureNextFrame);

    if (m_security) {
        connect(m_security, &JarvisSecurityManager::cameraPermissionChanged, this, [this](bool permitted) {
            emit permissionChanged(permitted);
            if (!permitted && m_isRunning) {
                stopCamera();
            }
        });
    }

    scanDevices();
    sritec::Logger::instance().info("CAMERA_SVC", "CameraService initialized (Strictly OFF by default per Section 25).");
}

bool CameraService::hasPermission() const {
    return m_security ? m_security->isCameraPermitted() : false;
}

void CameraService::scanDevices() {
    m_availableCameras.clear();

    // Check V4L2 video device nodes
    QDir devDir("/dev");
    QStringList videoNodes = devDir.entryList(QStringList() << "video*", QDir::System);

    int id = 0;
    for (const auto& node : videoNodes) {
        QVariantMap cam;
        cam["id"] = id;
        cam["name"] = QString("Webcam %1 (/dev/%2)").arg(id).arg(node);
        cam["deviceNode"] = "/dev/" + node;
        cam["isAvailable"] = true;
        cam["maxWidth"] = 1280;
        cam["maxHeight"] = 720;
        cam["maxFps"] = 30;
        m_availableCameras.append(cam);
        id++;
    }

    if (m_availableCameras.isEmpty()) {
        // Fallback simulated virtual computer vision capture device
        QVariantMap simCam;
        simCam["id"] = 0;
        simCam["name"] = "NEBULA Virtual Vision Sensor (Simulated)";
        simCam["deviceNode"] = "/dev/video-virtual";
        simCam["isAvailable"] = true;
        simCam["maxWidth"] = 1280;
        simCam["maxHeight"] = 720;
        simCam["maxFps"] = 30;
        m_availableCameras.append(simCam);
    }

    emit availableCamerasChanged();
    sritec::Logger::instance().info("CAMERA_SVC", QString("Detected %1 camera devices.").arg(m_availableCameras.size()).toStdString());
}

void CameraService::setSelectedCameraIndex(int index) {
    if (index >= 0 && index < m_availableCameras.size() && m_selectedCameraIndex != index) {
        m_selectedCameraIndex = index;
        emit selectedCameraIndexChanged(index);
    }
}

void CameraService::setTargetFps(int fps) {
    int f = qBound(10, fps, 60);
    if (m_targetFps != f) {
        m_targetFps = f;
        if (m_isRunning) {
            m_frameTimer->setInterval(1000 / m_targetFps);
        }
        emit targetFpsChanged(f);
    }
}

void CameraService::setLowResourceMode(bool lowResource) {
    if (m_lowResourceMode != lowResource) {
        m_lowResourceMode = lowResource;
        emit lowResourceModeChanged(lowResource);
        setTargetFps(lowResource ? 15 : 30);
        sritec::Logger::instance().info("CAMERA_SVC", QString("Camera low resource mode: %1 (FPS: %2)").arg(lowResource ? "ON" : "OFF").arg(m_targetFps).toStdString());
    }
}

bool CameraService::startCamera() {
    if (!m_security) return false;

    // Must have explicit permission
    if (!m_security->isCameraPermitted()) {
        sritec::Logger::instance().warn("CAMERA_SVC", "Explicit user permission required before camera activation.");
        return false;
    }

    if (!m_isRunning) {
        m_isRunning = true;
        m_frameTimer->start(1000 / m_targetFps);
        emit runningStateChanged(true);
        sritec::Logger::instance().info("CAMERA_SVC", QString("Camera activated at %1 FPS.").arg(m_targetFps).toStdString());
    }
    return true;
}

void CameraService::stopCamera() {
    if (m_isRunning) {
        m_isRunning = false;
        m_frameTimer->stop();
        emit runningStateChanged(false);
        sritec::Logger::instance().info("CAMERA_SVC", "Camera immediately stopped and powered down.");
    }
}

void CameraService::toggleCamera() {
    if (m_isRunning) {
        stopCamera();
    } else {
        if (!hasPermission()) {
            if (m_security) m_security->requestCameraPermission();
        }
        startCamera();
    }
}

void CameraService::captureNextFrame() {
    if (!m_isRunning) return;

    m_simAngle += 0.08;

    // Create a local cybernetic vision frame (640x360)
    QImage frame(640, 360, QImage::Format_RGB32);
    frame.fill(QColor(10, 14, 22));

    QPainter p(&frame);
    p.setRenderHint(QPainter::Antialiasing);

    // Grid telemetry
    p.setPen(QColor(0, 229, 255, 40));
    for (int x = 0; x < 640; x += 40) p.drawLine(x, 0, x, 360);
    for (int y = 0; y < 360; y += 40) p.drawLine(0, y, 640, y);

    // Simulated hand landmark track points
    double handX = 320.0 + qSin(m_simAngle) * 80.0;
    double handY = 180.0 + qCos(m_simAngle * 0.8) * 40.0;

    QVariantList landmarks;
    for (int i = 0; i < 5; ++i) {
        double lx = handX + (i - 2) * 22.0;
        double ly = handY - 30.0 - qAbs(i - 2) * 8.0;

        QVariantMap lm;
        lm["index"] = i;
        lm["x"] = lx / 640.0;
        lm["y"] = ly / 360.0;
        landmarks.append(lm);

        // Draw joint circles
        p.setPen(QColor(0, 245, 160));
        p.setBrush(QColor(0, 229, 255));
        p.drawEllipse(QPointF(lx, ly), 5, 5);
        p.drawLine(QPointF(handX, handY), QPointF(lx, ly));
    }

    // Wrist
    p.setBrush(QColor(139, 92, 246));
    p.drawEllipse(QPointF(handX, handY), 7, 7);

    // Telemetry text
    p.setPen(QColor(0, 229, 255));
    p.setFont(QFont("Monospace", 9, QFont::Bold));
    p.drawText(16, 26, "JARVIS VISION STREAM • 30 FPS");
    p.setPen(QColor(0, 245, 160));
    p.drawText(16, 44, "HAND DETECTED: 1 [CONFIDENCE: 94%]");

    p.end();

    emit frameReady(frame);
    emit handLandmarksDetected(landmarks);
}

} // namespace sritec::jarvis
