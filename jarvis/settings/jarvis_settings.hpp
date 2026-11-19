#pragma once

#include <QObject>
#include <QString>
#include <QSettings>

namespace sritec::jarvis {

class JarvisSettings : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isWakeWordEnabled READ isWakeWordEnabled WRITE setWakeWordEnabled NOTIFY wakeWordEnabledChanged)
    Q_PROPERTY(double wakeWordSensitivity READ wakeWordSensitivity WRITE setWakeWordSensitivity NOTIFY wakeWordSensitivityChanged)
    Q_PROPERTY(QString preferredLanguage READ preferredLanguage WRITE setPreferredLanguage NOTIFY preferredLanguageChanged)
    Q_PROPERTY(double speechSpeed READ speechSpeed WRITE setSpeechSpeed NOTIFY speechSpeedChanged)
    Q_PROPERTY(bool isGestureControlEnabled READ isGestureControlEnabled WRITE setGestureControlEnabled NOTIFY gestureControlEnabledChanged)
    Q_PROPERTY(double gestureSensitivity READ gestureSensitivity WRITE setGestureSensitivity NOTIFY gestureSensitivityChanged)
    Q_PROPERTY(bool isLeftHandMode READ isLeftHandMode WRITE setLeftHandMode NOTIFY leftHandModeChanged)
    Q_PROPERTY(bool isLowResourceMode READ isLowResourceMode WRITE setLowResourceMode NOTIFY lowResourceModeChanged)

public:
    explicit JarvisSettings(QObject* parent = nullptr);
    ~JarvisSettings() override = default;

    bool isWakeWordEnabled() const { return m_wakeWordEnabled; }
    void setWakeWordEnabled(bool enabled);

    double wakeWordSensitivity() const { return m_wakeWordSensitivity; }
    void setWakeWordSensitivity(double sensitivity);

    QString preferredLanguage() const { return m_preferredLanguage; }
    void setPreferredLanguage(const QString& lang);

    double speechSpeed() const { return m_speechSpeed; }
    void setSpeechSpeed(double speed);

    bool isGestureControlEnabled() const { return m_gestureControlEnabled; }
    void setGestureControlEnabled(bool enabled);

    double gestureSensitivity() const { return m_gestureSensitivity; }
    void setGestureSensitivity(double sensitivity);

    bool isLeftHandMode() const { return m_leftHandMode; }
    void setLeftHandMode(bool leftHand);

    bool isLowResourceMode() const { return m_lowResourceMode; }
    void setLowResourceMode(bool lowResource);

    Q_INVOKABLE void save();
    Q_INVOKABLE void load();

signals:
    void wakeWordEnabledChanged(bool enabled);
    void wakeWordSensitivityChanged(double sensitivity);
    void preferredLanguageChanged(const QString& lang);
    void speechSpeedChanged(double speed);
    void gestureControlEnabledChanged(bool enabled);
    void gestureSensitivityChanged(double sensitivity);
    void leftHandModeChanged(bool leftHand);
    void lowResourceModeChanged(bool lowResource);

private:
    bool m_wakeWordEnabled{true};
    double m_wakeWordSensitivity{0.85};
    QString m_preferredLanguage{"en"}; // "en", "ta", "hi"
    double m_speechSpeed{1.0};
    bool m_gestureControlEnabled{true};
    double m_gestureSensitivity{0.80};
    bool m_leftHandMode{false};
    bool m_lowResourceMode{false};
};

} // namespace sritec::jarvis
