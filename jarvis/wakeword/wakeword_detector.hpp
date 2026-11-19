#pragma once

#include <QObject>
#include <QString>
#include <QTimer>

namespace sritec::jarvis {

class WakeWordDetector : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isEnabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(double sensitivity READ sensitivity WRITE setSensitivity NOTIFY sensitivityChanged)
    Q_PROPERTY(bool isLowResourceMode READ isLowResourceMode WRITE setLowResourceMode NOTIFY lowResourceModeChanged)
    Q_PROPERTY(bool isListeningForWakeWord READ isListeningForWakeWord NOTIFY listeningStateChanged)

public:
    explicit WakeWordDetector(QObject* parent = nullptr);
    ~WakeWordDetector() override = default;

    bool isEnabled() const { return m_enabled; }
    void setEnabled(bool enabled);

    double sensitivity() const { return m_sensitivity; }
    void setSensitivity(double sensitivity);

    bool isLowResourceMode() const { return m_lowResourceMode; }
    void setLowResourceMode(bool lowResource);

    bool isListeningForWakeWord() const { return m_isListening; }

    void startListening();
    void stopListening();

    // Ingest text/speech stream to check for wake words
    bool testWakeWordInText(const QString& text, QString& matchedPhrase, double& confidence);

    // Feed raw audio energy level (for VAD & low-resource detection)
    void processAudioLevel(double level);

signals:
    void enabledChanged(bool enabled);
    void sensitivityChanged(double sensitivity);
    void lowResourceModeChanged(bool lowResource);
    void listeningStateChanged(bool listening);
    void wakeWordDetected(const QString& phrase, double confidence);
    void voiceActivityChanged(bool active);

private:
    bool m_enabled{true};
    double m_sensitivity{0.85};
    bool m_lowResourceMode{false};
    bool m_isListening{false};
    bool m_voiceActive{false};
};

} // namespace sritec::jarvis
