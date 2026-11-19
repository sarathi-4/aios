#include "voice_system.hpp"
#include "../security/jarvis_security_manager.hpp"
#include "sritec/logger.hpp"

#include <QtMath>

namespace sritec::jarvis {

VoiceSystem::VoiceSystem(JarvisSecurityManager* securityMgr, QObject* parent)
    : QObject(parent)
    , m_security(securityMgr)
    , m_meterTimer(new QTimer(this))
{
    connect(m_meterTimer, &QTimer::timeout, this, &VoiceSystem::updateSimulatedWaveform);
    m_meterTimer->setInterval(50); // 20 updates per second for waveform animation

    if (m_security) {
        connect(m_security, &JarvisSecurityManager::microphoneMutedChanged, this, &VoiceSystem::muteStateChanged);
        connect(m_security, &JarvisSecurityManager::microphonePermissionChanged, this, [this](bool permitted) {
            if (!permitted) {
                stopListening();
            }
        });
    }

    sritec::Logger::instance().info("VOICE_SYS", "VoiceSystem initialized with strict local-first privacy.");
}

bool VoiceSystem::isMuted() const {
    return m_security ? m_security->isMicrophoneMuted() : false;
}

void VoiceSystem::setInputDevice(const QString& device) {
    if (m_inputDevice != device) {
        m_inputDevice = device;
        emit inputDeviceChanged(device);
        sritec::Logger::instance().info("VOICE_SYS", "Input device changed to: " + device.toStdString());
    }
}

void VoiceSystem::startListening() {
    if (!m_security || !m_security->isMicrophonePermitted() || m_security->isMicrophoneMuted()) {
        sritec::Logger::instance().warn("VOICE_SYS", "Cannot start listening: Microphone permission missing or muted.");
        return;
    }

    if (!m_isListening) {
        m_isListening = true;
        m_meterTimer->start();
        emit listeningStateChanged(true);
        sritec::Logger::instance().info("VOICE_SYS", "Voice listening started.");
    }
}

void VoiceSystem::stopListening() {
    if (m_isListening) {
        m_isListening = false;
        m_meterTimer->stop();
        m_audioLevel = 0.0;
        m_voiceDetected = false;
        emit audioLevelChanged(0.0);
        emit voiceDetectedChanged(false);
        emit listeningStateChanged(false);
        sritec::Logger::instance().info("VOICE_SYS", "Voice listening stopped.");
    }
}

void VoiceSystem::toggleMute() {
    if (m_security) {
        m_security->setMicrophoneMuted(!m_security->isMicrophoneMuted());
    }
}

void VoiceSystem::feedAudioSamples(const QByteArray& pcmData, double rmsLevel) {
    Q_UNUSED(pcmData);
    if (!m_isListening || isMuted()) return;

    m_audioLevel = qBound(0.0, rmsLevel, 1.0);
    bool detected = (m_audioLevel >= 0.22);
    if (m_voiceDetected != detected) {
        m_voiceDetected = detected;
        emit voiceDetectedChanged(detected);
    }
    emit audioLevelChanged(m_audioLevel);
}

void VoiceSystem::updateSimulatedWaveform() {
    if (!m_isListening || isMuted()) {
        m_audioLevel = 0.0;
        emit audioLevelChanged(0.0);
        return;
    }

    m_simStep += 0.18;
    // Ambient rhythmic energy simulation when listening
    double val = qAbs(qSin(m_simStep)) * 0.45 + qAbs(qCos(m_simStep * 2.1)) * 0.25;
    m_audioLevel = qBound(0.05, val, 0.95);
    emit audioLevelChanged(m_audioLevel);
}

} // namespace sritec::jarvis
