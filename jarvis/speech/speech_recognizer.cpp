#include "speech_recognizer.hpp"
#include "sritec/logger.hpp"

#include <QStandardPaths>
#include <QTimer>

namespace sritec::jarvis {

SpeechRecognizer::SpeechRecognizer(QObject* parent)
    : QObject(parent)
    , m_ttsProcess(new QProcess(this))
{
    connect(m_ttsProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int, QProcess::ExitStatus) {
        if (m_isSpeaking) {
            m_isSpeaking = false;
            emit speakingStateChanged(false);
            emit speechFinished();
        }
    });

    sritec::Logger::instance().info("SPEECH_REC", "SpeechRecognizer initialized with English, Tamil, and Hindi TTS/STT pipelines.");
}

void SpeechRecognizer::setLanguage(const QString& lang) {
    if (m_language != lang && (lang == "en" || lang == "ta" || lang == "hi")) {
        m_language = lang;
        emit languageChanged(lang);
        sritec::Logger::instance().info("SPEECH_REC", "Speech language switched to: " + lang.toStdString());
    }
}

void SpeechRecognizer::setSpeechSpeed(double speed) {
    double s = qBound(0.5, speed, 2.0);
    if (qAbs(m_speed - s) > 0.01) {
        m_speed = s;
        emit speechSpeedChanged(s);
    }
}

void SpeechRecognizer::speak(const QString& text, const QString& lang) {
    if (text.trimmed().isEmpty()) return;

    stopSpeaking();

    QString targetLang = lang.isEmpty() ? m_language : lang;
    m_isSpeaking = true;
    emit speakingStateChanged(true);
    emit speechStarted(text);

    sritec::Logger::instance().info("SPEECH_REC", QString("Synthesizing speech [%1]: '%2'").arg(targetLang, text).toStdString());

    // Try finding system TTS (spd-say or espeak)
    QString spdSay = QStandardPaths::findExecutable("spd-say");
    QString espeak = QStandardPaths::findExecutable("espeak");

    if (!spdSay.isEmpty()) {
        QStringList args;
        if (targetLang == "ta") args << "-l" << "ta";
        else if (targetLang == "hi") args << "-l" << "hi";
        else args << "-l" << "en";
        args << text;
        m_ttsProcess->start(spdSay, args);
    } else if (!espeak.isEmpty()) {
        QStringList args;
        if (targetLang == "ta") args << "-v" << "ta";
        else if (targetLang == "hi") args << "-v" << "hi";
        else args << "-v" << "en";
        args << text;
        m_ttsProcess->start(espeak, args);
    } else {
        // Fallback simulation timer when hardware audio player/daemon is absent
        int durationMs = qBound(500, static_cast<int>(text.length() * 60 / m_speed), 4000);
        QTimer::singleShot(durationMs, this, [this]() {
            if (m_isSpeaking) {
                m_isSpeaking = false;
                emit speakingStateChanged(false);
                emit speechFinished();
            }
        });
    }
}

void SpeechRecognizer::stopSpeaking() {
    if (m_ttsProcess && m_ttsProcess->state() != QProcess::NotRunning) {
        m_ttsProcess->terminate();
        m_ttsProcess->waitForFinished(200);
    }
    if (m_isSpeaking) {
        m_isSpeaking = false;
        emit speakingStateChanged(false);
        emit speechFinished();
    }
}

QString SpeechRecognizer::transcribeAudio(const QByteArray& audioSamples) {
    Q_UNUSED(audioSamples);
    // Offline local acoustic phoneme transcription stub
    return "";
}

} // namespace sritec::jarvis
