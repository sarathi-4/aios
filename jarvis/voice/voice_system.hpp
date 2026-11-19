#pragma once

#include <QObject>
#include <QString>
#include <QTimer>
#include "jarvis_types.hpp"

namespace sritec::jarvis {

class JarvisSecurityManager;

class VoiceSystem : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isListening READ isListening NOTIFY listeningStateChanged)
    Q_PROPERTY(bool isMuted READ isMuted NOTIFY muteStateChanged)
    Q_PROPERTY(double audioLevel READ audioLevel NOTIFY audioLevelChanged)
    Q_PROPERTY(bool isVoiceDetected READ isVoiceDetected NOTIFY voiceDetectedChanged)
    Q_PROPERTY(QString inputDevice READ inputDevice WRITE setInputDevice NOTIFY inputDeviceChanged)

public:
    explicit VoiceSystem(JarvisSecurityManager* securityMgr, QObject* parent = nullptr);
    ~VoiceSystem() override = default;

    bool isListening() const { return m_isListening; }
    bool isMuted() const;
    double audioLevel() const { return m_audioLevel; }
    bool isVoiceDetected() const { return m_voiceDetected; }
    QString inputDevice() const { return m_inputDevice; }
    void setInputDevice(const QString& device);

    Q_INVOKABLE void startListening();
    Q_INVOKABLE void stopListening();
    Q_INVOKABLE void toggleMute();

    // Ingest simulated or real audio buffer (for testing and audio level metering)
    void feedAudioSamples(const QByteArray& pcmData, double rmsLevel);

signals:
    void listeningStateChanged(bool listening);
    void muteStateChanged(bool muted);
    void audioLevelChanged(double level);
    void voiceDetectedChanged(bool detected);
    void inputDeviceChanged(const QString& device);
    void speechDetected(const QString& simulatedTranscript);

private slots:
    void updateSimulatedWaveform();

private:
    JarvisSecurityManager* m_security;
    bool m_isListening{false};
    double m_audioLevel{0.0};
    bool m_voiceDetected{false};
    QString m_inputDevice{"Default System Microphone"};
    QTimer* m_meterTimer{nullptr};
    double m_simStep{0.0};
};

} // namespace sritec::jarvis
