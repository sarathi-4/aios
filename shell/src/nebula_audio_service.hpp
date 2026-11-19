#pragma once

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QDir>
#include <cstdint>

namespace sritec::shell {

/**
 * @brief NebulaAudioService provides procedural cybernetic sound effects and audio controls.
 * 
 * Synthesizes high-fidelity 16-bit PCM WAV audio waveforms in memory with zero external dependencies:
 * - Click Sound: Sharp 45ms cybernetic micro-chirp (1800Hz -> 600Hz exponential decay).
 * - Swipe Sound: Smooth 180ms frequency sweep (400Hz -> 1200Hz -> 350Hz with Gaussian envelope).
 * - Screenshot Sound: Crisp 160ms double-pulse camera shutter with mechanical reverb.
 * - Chime Sound: Rich 600ms rising harmonic triad chord (440Hz + 880Hz + 1320Hz).
 * - Notification Sound: Dual-tone 120ms pleasant alert (880Hz -> 1175Hz).
 * 
 * Audio output utilizes low-latency asynchronous PipeWire (pw-play) or ALSA (aplay) subprocesses.
 */
class NebulaAudioService : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool soundEffectsEnabled READ soundEffectsEnabled WRITE setSoundEffectsEnabled NOTIFY soundEffectsEnabledChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(bool isMuted READ isMuted WRITE setIsMuted NOTIFY isMutedChanged)
    Q_PROPERTY(QString lastPlayedSound READ lastPlayedSound NOTIFY lastPlayedSoundChanged)

public:
    explicit NebulaAudioService(QObject* parent = nullptr);
    ~NebulaAudioService() override = default;

    bool soundEffectsEnabled() const { return m_soundEffectsEnabled; }
    void setSoundEffectsEnabled(bool enabled);

    int volume() const { return m_volume; }
    void setVolume(int vol);

    bool isMuted() const { return m_isMuted; }
    void setIsMuted(bool muted);

    QString lastPlayedSound() const { return m_lastPlayedSound; }

    // Direct invocation methods callable from QML or C++
    Q_INVOKABLE void playClick();
    Q_INVOKABLE void playSwipe();
    Q_INVOKABLE void playScreenshot();
    Q_INVOKABLE void playChime();
    Q_INVOKABLE void playNotification();
    Q_INVOKABLE void playSound(const QString& soundType);

    // Path queries for generated sound assets
    Q_INVOKABLE QString soundFilePath(const QString& soundType) const;

signals:
    void soundEffectsEnabledChanged(bool enabled);
    void volumeChanged(int volume);
    void isMutedChanged(bool muted);
    void lastPlayedSoundChanged(const QString& sound);
    void soundPlayed(const QString& soundType);

private:
    void initializeAudioAssets();
    bool writeWavFile(const QString& filePath, const std::vector<int16_t>& samples, uint32_t sampleRate);
    void playAudioFile(const QString& filePath);

    std::vector<int16_t> generateClickSamples(uint32_t sampleRate);
    std::vector<int16_t> generateSwipeSamples(uint32_t sampleRate);
    std::vector<int16_t> generateScreenshotSamples(uint32_t sampleRate);
    std::vector<int16_t> generateChimeSamples(uint32_t sampleRate);
    std::vector<int16_t> generateNotificationSamples(uint32_t sampleRate);

    bool m_soundEffectsEnabled{true};
    int m_volume{75}; // 0 - 100
    bool m_isMuted{false};
    QString m_lastPlayedSound;
    QString m_audioCacheDir;
    qint64 m_lastClickTimeMs{0};
    QString m_playerBinary;
};

} // namespace sritec::shell
