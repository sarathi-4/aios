#include "wakeword_detector.hpp"
#include "sritec/logger.hpp"

#include <QStringList>

namespace sritec::jarvis {

WakeWordDetector::WakeWordDetector(QObject* parent)
    : QObject(parent)
{
    sritec::Logger::instance().info("WAKE_WORD", "WakeWordDetector initialized (Keywords: 'Hey Jarvis', 'Jarvis', Tamil/Hindi phonetics).");
}

void WakeWordDetector::setEnabled(bool enabled) {
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged(enabled);
        if (!enabled) {
            stopListening();
        }
        sritec::Logger::instance().info("WAKE_WORD", QString("Wake-word detection set to: %1").arg(enabled ? "ENABLED" : "DISABLED").toStdString());
    }
}

void WakeWordDetector::setSensitivity(double sensitivity) {
    double s = qBound(0.1, sensitivity, 1.0);
    if (qAbs(m_sensitivity - s) > 0.001) {
        m_sensitivity = s;
        emit sensitivityChanged(s);
    }
}

void WakeWordDetector::setLowResourceMode(bool lowResource) {
    if (m_lowResourceMode != lowResource) {
        m_lowResourceMode = lowResource;
        emit lowResourceModeChanged(lowResource);
        sritec::Logger::instance().info("WAKE_WORD", QString("Low-resource listening mode: %1").arg(lowResource ? "ON (Conserving CPU)" : "OFF").toStdString());
    }
}

void WakeWordDetector::startListening() {
    if (!m_enabled) return;
    if (!m_isListening) {
        m_isListening = true;
        emit listeningStateChanged(true);
        sritec::Logger::instance().info("WAKE_WORD", "Wake-word listening active (Local-first VAD).");
    }
}

void WakeWordDetector::stopListening() {
    if (m_isListening) {
        m_isListening = false;
        m_voiceActive = false;
        emit listeningStateChanged(false);
        emit voiceActivityChanged(false);
        sritec::Logger::instance().info("WAKE_WORD", "Wake-word listening suspended.");
    }
}

bool WakeWordDetector::testWakeWordInText(const QString& text, QString& matchedPhrase, double& confidence) {
    if (!m_enabled) return false;

    QString lower = text.trimmed().toLower();

    // Multi-lingual keyword variants (English, Tamil, Hindi)
    static const QStringList wakePhrases = {
        "hey jarvis", "jarvis", "hi jarvis", "hello jarvis", "ok jarvis",
        "ஹே ஜார்விஸ்", "ஜார்விஸ்", "ஹலோ ஜார்விஸ்",
        "हे जार्विस", "जार्विस", "नमस्ते जार्विस"
    };

    for (const auto& phrase : wakePhrases) {
        if (lower.startsWith(phrase) || lower.contains(phrase)) {
            matchedPhrase = phrase;
            // High confidence for exact match, scaled by sensitivity
            confidence = qBound(0.70, 0.95 * m_sensitivity, 0.99);
            sritec::Logger::instance().info("WAKE_WORD", QString("Wake-word detected: '%1' (Confidence: %2)").arg(phrase).arg(confidence).toStdString());
            emit wakeWordDetected(phrase, confidence);
            return true;
        }
    }

    return false;
}

void WakeWordDetector::processAudioLevel(double level) {
    if (!m_isListening) return;

    double threshold = m_lowResourceMode ? 0.35 : 0.20;
    bool active = (level >= threshold);

    if (m_voiceActive != active) {
        m_voiceActive = active;
        emit voiceActivityChanged(active);
    }
}

} // namespace sritec::jarvis
