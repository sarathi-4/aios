#include "jarvis_settings.hpp"
#include "sritec/logger.hpp"

namespace sritec::jarvis {

JarvisSettings::JarvisSettings(QObject* parent)
    : QObject(parent)
{
    load();
    sritec::Logger::instance().info("JARVIS_SET", "JarvisSettings initialized from persistent storage.");
}

void JarvisSettings::load() {
    QSettings settings("SRITEC", "NEBULA_JARVIS");

    m_wakeWordEnabled = settings.value("voice/wakeWordEnabled", true).toBool();
    m_wakeWordSensitivity = settings.value("voice/wakeWordSensitivity", 0.85).toDouble();
    m_preferredLanguage = settings.value("voice/preferredLanguage", "en").toString();
    m_speechSpeed = settings.value("voice/speechSpeed", 1.0).toDouble();

    m_gestureControlEnabled = settings.value("vision/gestureControlEnabled", true).toBool();
    m_gestureSensitivity = settings.value("vision/gestureSensitivity", 0.80).toDouble();
    m_leftHandMode = settings.value("vision/leftHandMode", false).toBool();
    m_lowResourceMode = settings.value("system/lowResourceMode", false).toBool();
}

void JarvisSettings::save() {
    QSettings settings("SRITEC", "NEBULA_JARVIS");

    settings.setValue("voice/wakeWordEnabled", m_wakeWordEnabled);
    settings.setValue("voice/wakeWordSensitivity", m_wakeWordSensitivity);
    settings.setValue("voice/preferredLanguage", m_preferredLanguage);
    settings.setValue("voice/speechSpeed", m_speechSpeed);

    settings.setValue("vision/gestureControlEnabled", m_gestureControlEnabled);
    settings.setValue("vision/gestureSensitivity", m_gestureSensitivity);
    settings.setValue("vision/leftHandMode", m_leftHandMode);
    settings.setValue("system/lowResourceMode", m_lowResourceMode);

    settings.sync();
}

void JarvisSettings::setWakeWordEnabled(bool enabled) {
    if (m_wakeWordEnabled != enabled) {
        m_wakeWordEnabled = enabled;
        emit wakeWordEnabledChanged(enabled);
        save();
    }
}

void JarvisSettings::setWakeWordSensitivity(double sensitivity) {
    double s = qBound(0.1, sensitivity, 1.0);
    if (qAbs(m_wakeWordSensitivity - s) > 0.01) {
        m_wakeWordSensitivity = s;
        emit wakeWordSensitivityChanged(s);
        save();
    }
}

void JarvisSettings::setPreferredLanguage(const QString& lang) {
    if (m_preferredLanguage != lang) {
        m_preferredLanguage = lang;
        emit preferredLanguageChanged(lang);
        save();
    }
}

void JarvisSettings::setSpeechSpeed(double speed) {
    double s = qBound(0.5, speed, 2.0);
    if (qAbs(m_speechSpeed - s) > 0.01) {
        m_speechSpeed = s;
        emit speechSpeedChanged(s);
        save();
    }
}

void JarvisSettings::setGestureControlEnabled(bool enabled) {
    if (m_gestureControlEnabled != enabled) {
        m_gestureControlEnabled = enabled;
        emit gestureControlEnabledChanged(enabled);
        save();
    }
}

void JarvisSettings::setGestureSensitivity(double sensitivity) {
    double s = qBound(0.1, sensitivity, 1.0);
    if (qAbs(m_gestureSensitivity - s) > 0.01) {
        m_gestureSensitivity = s;
        emit gestureSensitivityChanged(s);
        save();
    }
}

void JarvisSettings::setLeftHandMode(bool leftHand) {
    if (m_leftHandMode != leftHand) {
        m_leftHandMode = leftHand;
        emit leftHandModeChanged(leftHand);
        save();
    }
}

void JarvisSettings::setLowResourceMode(bool lowResource) {
    if (m_lowResourceMode != lowResource) {
        m_lowResourceMode = lowResource;
        emit lowResourceModeChanged(lowResource);
        save();
    }
}

} // namespace sritec::jarvis
