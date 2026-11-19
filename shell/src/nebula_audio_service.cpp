#include "nebula_audio_service.hpp"
#include "sritec/logger.hpp"

#include <QStandardPaths>
#include <QFile>
#include <QDataStream>
#include <QDateTime>
#include <QProcess>
#include <cmath>
#include <numbers>

namespace sritec::shell {

namespace {
constexpr uint32_t SAMPLE_RATE = 44100;
constexpr double PI = std::numbers::pi;

// Clamp 16-bit audio sample
inline int16_t clampSample(double val) {
    if (val > 32767.0) return 32767;
    if (val < -32768.0) return -32768;
    return static_cast<int16_t>(val);
}
}

NebulaAudioService::NebulaAudioService(QObject* parent)
    : QObject(parent)
{
    // Determine user cache location for procedural audio assets
    QString cacheRoot = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    if (cacheRoot.isEmpty()) {
        cacheRoot = "/tmp/sritec_cache";
    }
    m_audioCacheDir = cacheRoot + "/audio";
    QDir().mkpath(m_audioCacheDir);

    // Locate system audio player binary (prefer PipeWire pw-play if daemon socket is active, otherwise ALSA aplay)
    QString runtimeDir = qEnvironmentVariable("XDG_RUNTIME_DIR", "/run/user/1000");
    bool pipewireActive = QFile::exists(runtimeDir + "/pipewire-0");

    if (pipewireActive && QFile::exists("/usr/bin/pw-play")) {
        m_playerBinary = "/usr/bin/pw-play";
    } else if (QFile::exists("/usr/bin/aplay")) {
        m_playerBinary = "/usr/bin/aplay";
    } else if (QFile::exists("/usr/bin/pw-play")) {
        m_playerBinary = "/usr/bin/pw-play";
    } else {
        m_playerBinary = "aplay";
    }

    sritec::Logger::instance().info("AUDIO", 
        QString("NebulaAudioService initialized. Cache: %1, Player: %2")
        .arg(m_audioCacheDir, m_playerBinary).toStdString());

    initializeAudioAssets();
}

void NebulaAudioService::setSoundEffectsEnabled(bool enabled) {
    if (m_soundEffectsEnabled != enabled) {
        m_soundEffectsEnabled = enabled;
        emit soundEffectsEnabledChanged(enabled);
        sritec::Logger::instance().info("AUDIO", QString("Sound effects %1")
            .arg(enabled ? "enabled" : "disabled").toStdString());
    }
}

void NebulaAudioService::setVolume(int vol) {
    int clamped = std::clamp(vol, 0, 100);
    if (m_volume != clamped) {
        m_volume = clamped;
        emit volumeChanged(clamped);
    }
}

void NebulaAudioService::setIsMuted(bool muted) {
    if (m_isMuted != muted) {
        m_isMuted = muted;
        emit isMutedChanged(muted);
        sritec::Logger::instance().info("AUDIO", QString("Audio mute state: %1")
            .arg(muted ? "MUTED" : "UNMUTED").toStdString());
    }
}

QString NebulaAudioService::soundFilePath(const QString& soundType) const {
    return QString("%1/%2.wav").arg(m_audioCacheDir, soundType.toLower());
}

void NebulaAudioService::playClick() {
    // 25ms debounce to avoid audio stutter on rapid clicks
    qint64 now = QDateTime::currentMSecsSinceEpoch();
    if (now - m_lastClickTimeMs < 25) {
        return;
    }
    m_lastClickTimeMs = now;
    playSound("click");
}

void NebulaAudioService::playSwipe() {
    playSound("swipe");
}

void NebulaAudioService::playScreenshot() {
    playSound("screenshot");
}

void NebulaAudioService::playChime() {
    playSound("chime");
}

void NebulaAudioService::playNotification() {
    playSound("notification");
}

void NebulaAudioService::playSound(const QString& soundType) {
    if (!m_soundEffectsEnabled || m_isMuted || m_volume <= 0) {
        return;
    }

    QString file = soundFilePath(soundType);
    if (!QFile::exists(file)) {
        initializeAudioAssets();
    }

    playAudioFile(file);

    m_lastPlayedSound = soundType;
    emit lastPlayedSoundChanged(soundType);
    emit soundPlayed(soundType);
}

void NebulaAudioService::playAudioFile(const QString& filePath) {
    if (m_playerBinary.isEmpty() || !QFile::exists(filePath)) {
        return;
    }

    QStringList args;
    if (m_playerBinary.contains("pw-play")) {
        // pw-play supports volume as float e.g. 0.75
        double volFloat = static_cast<double>(m_volume) / 100.0;
        args << QString("--volume=%1").arg(volFloat) << filePath;
    } else {
        // aplay standard args
        args << "-q" << filePath;
    }

    // Launch non-blocking background audio playback process with suppressed stderr
    auto* proc = new QProcess();
    proc->setStandardOutputFile(QProcess::nullDevice());
    proc->setStandardErrorFile(QProcess::nullDevice());
    QObject::connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), 
                     proc, &QObject::deleteLater);
    proc->start(m_playerBinary, args);
}

bool NebulaAudioService::writeWavFile(const QString& filePath, const std::vector<int16_t>& samples, uint32_t sampleRate) {
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        sritec::Logger::instance().error("AUDIO", QString("Failed to write WAV file: %1").arg(filePath).toStdString());
        return false;
    }

    QDataStream out(&file);
    out.setByteOrder(QDataStream::LittleEndian);

    uint32_t numSamples = static_cast<uint32_t>(samples.size());
    uint32_t subchunk2Size = numSamples * sizeof(int16_t);
    uint32_t chunkSize = 36 + subchunk2Size;
    uint16_t numChannels = 1; // Mono
    uint16_t bitsPerSample = 16;
    uint32_t byteRate = sampleRate * numChannels * (bitsPerSample / 8);
    uint16_t blockAlign = numChannels * (bitsPerSample / 8);

    // RIFF Header
    file.write("RIFF", 4);
    out << chunkSize;
    file.write("WAVE", 4);

    // "fmt " Subchunk
    file.write("fmt ", 4);
    uint32_t subchunk1Size = 16; // PCM
    uint16_t audioFormat = 1;    // PCM
    out << subchunk1Size;
    out << audioFormat;
    out << numChannels;
    out << sampleRate;
    out << byteRate;
    out << blockAlign;
    out << bitsPerSample;

    // "data" Subchunk
    file.write("data", 4);
    out << subchunk2Size;

    // Write PCM samples
    for (int16_t sample : samples) {
        out << sample;
    }

    file.close();
    return true;
}

std::vector<int16_t> NebulaAudioService::generateClickSamples(uint32_t sampleRate) {
    // 45ms duration cybernetic click: rapid chirped sine with exponential envelope
    double durationSec = 0.045;
    size_t count = static_cast<size_t>(sampleRate * durationSec);
    std::vector<int16_t> samples;
    samples.reserve(count);

    double startFreq = 1800.0;
    double endFreq = 650.0;

    for (size_t i = 0; i < count; ++i) {
        double t = static_cast<double>(i) / sampleRate;
        double progress = t / durationSec;
        double currentFreq = startFreq + (endFreq - startFreq) * std::pow(progress, 0.7);
        double phase = 2.0 * PI * currentFreq * t;

        // Exponential decay envelope
        double envelope = std::exp(-t * 90.0);
        // Soft click pop filter
        double value = std::sin(phase) * envelope * 24000.0;
        samples.push_back(clampSample(value));
    }
    return samples;
}

std::vector<int16_t> NebulaAudioService::generateSwipeSamples(uint32_t sampleRate) {
    // 160ms duration smooth swipe: sweeping sine with Gaussian bell envelope
    double durationSec = 0.16;
    size_t count = static_cast<size_t>(sampleRate * durationSec);
    std::vector<int16_t> samples;
    samples.reserve(count);

    for (size_t i = 0; i < count; ++i) {
        double t = static_cast<double>(i) / sampleRate;
        double progress = t / durationSec;

        // Pitch curves: up to 950Hz then down to 420Hz
        double freq = 380.0 + 570.0 * std::sin(progress * PI);
        double phase = 2.0 * PI * freq * t;

        // Gaussian bell curve amplitude envelope
        double bell = std::exp(-std::pow((progress - 0.45) * 4.0, 2.0));
        double value = (0.85 * std::sin(phase) + 0.15 * std::sin(phase * 2.0)) * bell * 20000.0;
        samples.push_back(clampSample(value));
    }
    return samples;
}

std::vector<int16_t> NebulaAudioService::generateScreenshotSamples(uint32_t sampleRate) {
    // 170ms cyber camera shutter: double pulse click + resonant decay
    double durationSec = 0.17;
    size_t count = static_cast<size_t>(sampleRate * durationSec);
    std::vector<int16_t> samples;
    samples.reserve(count);

    for (size_t i = 0; i < count; ++i) {
        double t = static_cast<double>(i) / sampleRate;

        // Pulse 1 at t=0ms, Pulse 2 at t=45ms
        double p1 = (t < 0.04) ? (std::sin(2.0 * PI * 1600.0 * t) * std::exp(-t * 110.0)) : 0.0;
        double t2 = t - 0.045;
        double p2 = (t2 >= 0.0) ? (std::sin(2.0 * PI * 920.0 * t2) * std::exp(-t2 * 65.0)) : 0.0;

        double combined = (p1 * 0.7 + p2 * 0.9) * 26000.0;
        samples.push_back(clampSample(combined));
    }
    return samples;
}

std::vector<int16_t> NebulaAudioService::generateChimeSamples(uint32_t sampleRate) {
    // 600ms rich futuristic harmonic chord (440Hz + 880Hz + 1320Hz + 1760Hz)
    double durationSec = 0.60;
    size_t count = static_cast<size_t>(sampleRate * durationSec);
    std::vector<int16_t> samples;
    samples.reserve(count);

    for (size_t i = 0; i < count; ++i) {
        double t = static_cast<double>(i) / sampleRate;

        // Attack ramp (first 30ms)
        double attack = (t < 0.03) ? (t / 0.03) : 1.0;
        // Exponential decay
        double decay = std::exp(-t * 5.0);
        double envelope = attack * decay;

        double tone1 = std::sin(2.0 * PI * 440.0 * t);
        double tone2 = 0.6 * std::sin(2.0 * PI * 880.0 * t);
        double tone3 = 0.35 * std::sin(2.0 * PI * 1320.0 * t);
        double tone4 = 0.15 * std::sin(2.0 * PI * 1760.0 * t);

        double combined = (tone1 + tone2 + tone3 + tone4) * envelope * 18000.0;
        samples.push_back(clampSample(combined));
    }
    return samples;
}

std::vector<int16_t> NebulaAudioService::generateNotificationSamples(uint32_t sampleRate) {
    // 140ms dual-tone chime: 880Hz for 60ms, then 1175Hz for 80ms
    double durationSec = 0.14;
    size_t count = static_cast<size_t>(sampleRate * durationSec);
    std::vector<int16_t> samples;
    samples.reserve(count);

    for (size_t i = 0; i < count; ++i) {
        double t = static_cast<double>(i) / sampleRate;
        double freq = (t < 0.06) ? 880.0 : 1174.66;
        double subT = (t < 0.06) ? t : (t - 0.06);

        double env = std::exp(-subT * 40.0);
        double value = std::sin(2.0 * PI * freq * t) * env * 22000.0;
        samples.push_back(clampSample(value));
    }
    return samples;
}

void NebulaAudioService::initializeAudioAssets() {
    QString clickPath = soundFilePath("click");
    QString swipePath = soundFilePath("swipe");
    QString screenshotPath = soundFilePath("screenshot");
    QString chimePath = soundFilePath("chime");
    QString notifPath = soundFilePath("notification");

    if (!QFile::exists(clickPath)) {
        writeWavFile(clickPath, generateClickSamples(SAMPLE_RATE), SAMPLE_RATE);
    }
    if (!QFile::exists(swipePath)) {
        writeWavFile(swipePath, generateSwipeSamples(SAMPLE_RATE), SAMPLE_RATE);
    }
    if (!QFile::exists(screenshotPath)) {
        writeWavFile(screenshotPath, generateScreenshotSamples(SAMPLE_RATE), SAMPLE_RATE);
    }
    if (!QFile::exists(chimePath)) {
        writeWavFile(chimePath, generateChimeSamples(SAMPLE_RATE), SAMPLE_RATE);
    }
    if (!QFile::exists(notifPath)) {
        writeWavFile(notifPath, generateNotificationSamples(SAMPLE_RATE), SAMPLE_RATE);
    }
}

} // namespace sritec::shell
