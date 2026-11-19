#include "nebula_screen_capture_service.hpp"
#include "nebula_audio_service.hpp"
#include "sritec/logger.hpp"

#include <QGuiApplication>
#include <QStandardPaths>
#include <QDir>
#include <QFileInfo>
#include <QDateTime>
#include <QBuffer>
#include <QDesktopServices>
#include <QUrl>

namespace sritec::shell {

NebulaScreenCaptureService::NebulaScreenCaptureService(NebulaAudioService* audioService, QObject* parent)
    : QObject(parent)
    , m_audioService(audioService)
    , m_durationTimer(new QTimer(this))
{
    m_durationTimer->setInterval(1000);
    connect(m_durationTimer, &QTimer::timeout, this, &NebulaScreenCaptureService::onRecordingTimerTick);

    // Ensure output directories exist
    QDir().mkpath(getScreenshotDirectory());
    QDir().mkpath(getRecordingDirectory());

    sritec::Logger::instance().info("SCREEN_CAPTURE", 
        QString("NebulaScreenCaptureService initialized. Screenshots: %1, Recordings: %2")
        .arg(getScreenshotDirectory(), getRecordingDirectory()).toStdString());
}

NebulaScreenCaptureService::~NebulaScreenCaptureService() {
    if (m_isRecording) {
        stopRecording();
    }
}

QString NebulaScreenCaptureService::getScreenshotDirectory() const {
    QString dir = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + "/Screenshots";
    if (dir.isEmpty() || !QDir(dir).exists()) {
        dir = "/run/media/sarathi/250-2.1/aios/docs/screenshots";
    }
    return dir;
}

QString NebulaScreenCaptureService::getRecordingDirectory() const {
    QString dir = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation) + "/Recordings";
    if (dir.isEmpty() || !QDir(dir).exists()) {
        dir = "/run/media/sarathi/250-2.1/aios/docs/screenshots";
    }
    return dir;
}

bool NebulaScreenCaptureService::captureScreen(QQuickWindow* window) {
    if (!window) {
        // Fallback to active window
        const auto windows = QGuiApplication::topLevelWindows();
        for (auto* w : windows) {
            auto* qw = qobject_cast<QQuickWindow*>(w);
            if (qw && qw->isVisible()) {
                window = qw;
                break;
            }
        }
    }

    if (!window) {
        sritec::Logger::instance().error("SCREEN_CAPTURE", "No active QQuickWindow available for capture.");
        emit errorOccurred("No window available to capture.");
        return false;
    }

    m_isProcessing = true;
    emit isProcessingChanged(true);

    QImage frame = window->grabWindow();
    if (frame.isNull()) {
        sritec::Logger::instance().error("SCREEN_CAPTURE", "Failed to grab window framebuffer.");
        m_isProcessing = false;
        emit isProcessingChanged(false);
        emit errorOccurred("Framebuffer grab returned null image.");
        return false;
    }

    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
    QString filename = QString("NEBULA_Screenshot_%1.png").arg(timestamp);
    QString dirPath = getScreenshotDirectory();
    QDir().mkpath(dirPath);
    QString filePath = dirPath + "/" + filename;

    bool saved = frame.save(filePath, "PNG");
    if (!saved) {
        sritec::Logger::instance().error("SCREEN_CAPTURE", QString("Failed to save image to %1").arg(filePath).toStdString());
        m_isProcessing = false;
        emit isProcessingChanged(false);
        emit errorOccurred("Failed to save screenshot file.");
        return false;
    }

    // Play cybernetic screenshot shutter sound
    if (m_audioService) {
        m_audioService->playScreenshot();
    }

    // Generate base64 thumbnail for toast preview (180x100 aspect ratio)
    QImage thumb = frame.scaled(180, 100, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    QByteArray ba;
    QBuffer buffer(&ba);
    buffer.open(QIODevice::WriteOnly);
    thumb.save(&buffer, "PNG");
    QString thumbBase64 = QString("data:image/png;base64,%1").arg(QString::fromLatin1(ba.toBase64()));

    m_lastScreenshotPath = filePath;
    emit lastScreenshotPathChanged(filePath);

    m_isProcessing = false;
    emit isProcessingChanged(false);

    emit screenshotCaptured(filePath, thumbBase64);

    sritec::Logger::instance().info("SCREEN_CAPTURE", 
        QString("Screenshot captured: %1 (%2x%3)").arg(filePath).arg(frame.width()).arg(frame.height()).toStdString());

    return true;
}

bool NebulaScreenCaptureService::startRecording(QQuickWindow* window) {
    if (m_isRecording) {
        return false;
    }

    m_activeWindow = window;
    m_isRecording = true;
    m_recordingDurationSeconds = 0;
    emit isRecordingChanged(true);
    emit recordingDurationSecondsChanged(0);

    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
    QString filename = QString("NEBULA_Recording_%1.webm").arg(timestamp);
    QString dirPath = getRecordingDirectory();
    QDir().mkpath(dirPath);
    m_lastRecordingPath = dirPath + "/" + filename;
    emit lastRecordingPathChanged(m_lastRecordingPath);

    // Audio click feedback
    if (m_audioService) {
        m_audioService->playClick();
    }

    // Start elapsed duration timer
    m_durationTimer->start();

    // Start background recorder process via GStreamer if available
    if (QFile::exists("/usr/bin/gst-launch-1.0")) {
        m_recorderProcess = std::make_unique<QProcess>();
        // GStreamer pipeline for recording screen to WebM
        QStringList args;
        args << "-e";
        // Check session type
        QString xdgSession = qEnvironmentVariable("XDG_SESSION_TYPE", "wayland");
        if (xdgSession == "x11") {
            args << "ximagesrc" << "use-damage=0"
                 << "!" << "videoconvert"
                 << "!" << "vp8enc" << "cpu-used=4" << "deadline=1"
                 << "!" << "webmmux"
                 << "!" << "filesink" << QString("location=%1").arg(m_lastRecordingPath);
        } else {
            // Wayland pipewire source
            args << "pipewiresrc" << "do-timestamp=true"
                 << "!" << "videoconvert"
                 << "!" << "vp8enc" << "cpu-used=4" << "deadline=1"
                 << "!" << "webmmux"
                 << "!" << "filesink" << QString("location=%1").arg(m_lastRecordingPath);
        }

        m_recorderProcess->start("/usr/bin/gst-launch-1.0", args);
    }

    emit recordingStarted();
    sritec::Logger::instance().info("SCREEN_CAPTURE", 
        QString("Screen recording started -> %1").arg(m_lastRecordingPath).toStdString());

    return true;
}

bool NebulaScreenCaptureService::stopRecording() {
    if (!m_isRecording) {
        return false;
    }

    m_durationTimer->stop();
    m_isRecording = false;
    emit isRecordingChanged(false);

    // Stop GStreamer process gracefully so WebM headers are finalized
    if (m_recorderProcess && m_recorderProcess->state() != QProcess::NotRunning) {
        m_recorderProcess->terminate();
        if (!m_recorderProcess->waitForFinished(3000)) {
            m_recorderProcess->kill();
        }
        m_recorderProcess.reset();
    }

    // Sound alert
    if (m_audioService) {
        m_audioService->playNotification();
    }

    emit recordingStopped(m_lastRecordingPath);
    sritec::Logger::instance().info("SCREEN_CAPTURE", 
        QString("Screen recording stopped. Duration: %1s, Saved: %2")
        .arg(m_recordingDurationSeconds).arg(m_lastRecordingPath).toStdString());

    return true;
}

void NebulaScreenCaptureService::onRecordingTimerTick() {
    if (m_isRecording) {
        m_recordingDurationSeconds++;
        emit recordingDurationSecondsChanged(m_recordingDurationSeconds);
    }
}

void NebulaScreenCaptureService::openFile(const QString& filePath) {
    if (!filePath.isEmpty() && QFile::exists(filePath)) {
        QDesktopServices::openUrl(QUrl::fromLocalFile(filePath));
    }
}

void NebulaScreenCaptureService::openRecordingDirectory() {
    QDesktopServices::openUrl(QUrl::fromLocalFile(getRecordingDirectory()));
}

} // namespace sritec::shell
