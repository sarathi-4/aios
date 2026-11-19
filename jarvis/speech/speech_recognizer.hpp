#pragma once

#include <QObject>
#include <QString>
#include <QProcess>

namespace sritec::jarvis {

class SpeechRecognizer : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isSpeaking READ isSpeaking NOTIFY speakingStateChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(double speechSpeed READ speechSpeed WRITE setSpeechSpeed NOTIFY speechSpeedChanged)

public:
    explicit SpeechRecognizer(QObject* parent = nullptr);
    ~SpeechRecognizer() override = default;

    bool isSpeaking() const { return m_isSpeaking; }
    QString language() const { return m_language; }
    void setLanguage(const QString& lang);

    double speechSpeed() const { return m_speed; }
    void setSpeechSpeed(double speed);

    // Text-to-Speech execution
    Q_INVOKABLE void speak(const QString& text, const QString& lang = "");
    Q_INVOKABLE void stopSpeaking();

    // Speech-to-Text translation & normalization
    QString transcribeAudio(const QByteArray& audioSamples);

signals:
    void speakingStateChanged(bool speaking);
    void languageChanged(const QString& lang);
    void speechSpeedChanged(double speed);
    void speechStarted(const QString& text);
    void speechFinished();

private:
    bool m_isSpeaking{false};
    QString m_language{"en"}; // "en", "ta", "hi"
    double m_speed{1.0};
    QProcess* m_ttsProcess{nullptr};
};

} // namespace sritec::jarvis
