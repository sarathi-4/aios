#pragma once

#include <QObject>
#include <QString>
#include <QQuickWindow>
#include <QTimer>
#include <QProcess>
#include <memory>

namespace sritec::shell {

class NebulaAudioService;

/**
 * @brief NebulaScreenCaptureService manages screenshot grabs, thumbnail generation,
 * and video screen recording within the NEBULA environment.
 */
class NebulaScreenCaptureService : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isRecording READ isRecording NOTIFY isRecordingChanged)
    Q_PROPERTY(int recordingDurationSeconds READ recordingDurationSeconds NOTIFY recordingDurationSecondsChanged)
    Q_PROPERTY(QString lastScreenshotPath READ lastScreenshotPath NOTIFY lastScreenshotPathChanged)
    Q_PROPERTY(QString lastRecordingPath READ lastRecordingPath NOTIFY lastRecordingPathChanged)
    Q_PROPERTY(bool isProcessing READ isProcessing NOTIFY isProcessingChanged)

public:
    explicit NebulaScreenCaptureService(NebulaAudioService* audioService = nullptr, QObject* parent = nullptr);
    ~NebulaScreenCaptureService() override;

    bool isRecording() const { return m_isRecording; }
    int recordingDurationSeconds() const { return m_recordingDurationSeconds; }
    QString lastScreenshotPath() const { return m_lastScreenshotPath; }
    QString lastRecordingPath() const { return m_lastRecordingPath; }
    bool isProcessing() const { return m_isProcessing; }

    // Invokables for QML
    Q_INVOKABLE bool captureScreen(QQuickWindow* window);
    Q_INVOKABLE bool startRecording(QQuickWindow* window = nullptr);
    Q_INVOKABLE bool stopRecording();
    Q_INVOKABLE void openFile(const QString& filePath);
    Q_INVOKABLE void openRecordingDirectory();

signals:
    void isRecordingChanged(bool recording);
    void recordingDurationSecondsChanged(int seconds);
    void lastScreenshotPathChanged(const QString& path);
    void lastRecordingPathChanged(const QString& path);
    void isProcessingChanged(bool processing);
    void screenshotCaptured(const QString& filePath, const QString& thumbnailBase64);
    void recordingStarted();
    void recordingStopped(const QString& filePath);
    void errorOccurred(const QString& error);

private slots:
    void onRecordingTimerTick();

private:
    QString getScreenshotDirectory() const;
    QString getRecordingDirectory() const;

    NebulaAudioService* m_audioService{nullptr};
    bool m_isRecording{false};
    int m_recordingDurationSeconds{0};
    QString m_lastScreenshotPath;
    QString m_lastRecordingPath;
    bool m_isProcessing{false};

    QTimer* m_durationTimer{nullptr};
    std::unique_ptr<QProcess> m_recorderProcess;
    QQuickWindow* m_activeWindow{nullptr};
};

} // namespace sritec::shell
