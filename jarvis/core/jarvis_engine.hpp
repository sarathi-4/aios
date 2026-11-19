#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QDateTime>
#include <memory>

#include "jarvis_types.hpp"

namespace sritec::shell {
    class AppLaunchManager;
    class AppLauncher;
    class DesktopManager;
}

namespace sritec::ai {
    class AIBridge;
}

namespace sritec::jarvis {

class JarvisSecurityManager;
class WakeWordDetector;
class VoiceSystem;
class SpeechRecognizer;
class IntentRecognizer;
class CameraService;
class GestureRecognizer;
class ActionDispatcher;
class JarvisSettings;

class JarvisEngine : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString stateString READ stateString NOTIFY stateChanged)
    Q_PROPERTY(int stateEnum READ stateEnum NOTIFY stateChanged)
    Q_PROPERTY(bool isActive READ isActive WRITE setActive NOTIFY activeChanged)
    Q_PROPERTY(bool isWakeWordListening READ isWakeWordListening NOTIFY wakeWordStateChanged)
    Q_PROPERTY(bool isMicListening READ isMicListening NOTIFY micStateChanged)
    Q_PROPERTY(bool isMicMuted READ isMicMuted NOTIFY micMutedChanged)
    Q_PROPERTY(bool isCameraActive READ isCameraActive NOTIFY cameraActiveChanged)
    Q_PROPERTY(double audioLevel READ audioLevel NOTIFY audioLevelChanged)
    Q_PROPERTY(QString detectedGesture READ detectedGesture NOTIFY gestureChanged)
    Q_PROPERTY(double gestureConfidence READ gestureConfidence NOTIFY gestureConfidenceChanged)
    Q_PROPERTY(QString lastTranscript READ lastTranscript NOTIFY transcriptChanged)
    Q_PROPERTY(QString lastSpokenResponse READ lastSpokenResponse NOTIFY spokenResponseChanged)
    Q_PROPERTY(QString lastFeedback READ lastFeedback NOTIFY feedbackChanged)
    Q_PROPERTY(QVariantList conversationHistory READ conversationHistory NOTIFY historyChanged)
    Q_PROPERTY(QString activeLanguage READ activeLanguage WRITE setActiveLanguage NOTIFY languageChanged)

public:
    explicit JarvisEngine(
        sritec::shell::AppLaunchManager* appLaunchMgr,
        sritec::shell::AppLauncher* launcher,
        sritec::shell::DesktopManager* desktopMgr,
        sritec::ai::AIBridge* aiBridge,
        QObject* parent = nullptr);

    ~JarvisEngine() override;

    JarvisState state() const { return m_state; }
    QString stateString() const { return stateToString(m_state); }
    int stateEnum() const { return static_cast<int>(m_state); }

    bool isActive() const { return m_isActive; }
    void setActive(bool active);

    bool isWakeWordListening() const;
    bool isMicListening() const;
    bool isMicMuted() const;
    bool isCameraActive() const;
    double audioLevel() const;
    QString detectedGesture() const;
    double gestureConfidence() const;
    QString lastTranscript() const { return m_lastTranscript; }
    QString lastSpokenResponse() const { return m_lastSpokenResponse; }
    QString lastFeedback() const { return m_lastFeedback; }
    QVariantList conversationHistory() const { return m_history; }
    QString activeLanguage() const;
    void setActiveLanguage(const QString& lang);

    // Q_INVOKABLE User Controls
    Q_INVOKABLE void togglePower();
    Q_INVOKABLE void startListening();
    Q_INVOKABLE void stopListening();
    Q_INVOKABLE void toggleMicrophone();
    Q_INVOKABLE void toggleCamera();
    Q_INVOKABLE void requestCameraPermission();
    Q_INVOKABLE void processUserInput(const QString& rawInput);
    Q_INVOKABLE void simulateWakeWord(const QString& phrase = "hey jarvis");
    Q_INVOKABLE void simulateGesture(const QString& gestureName, double confidence = 0.95);
    Q_INVOKABLE void emergencyShutdown();
    Q_INVOKABLE void clearHistory();

    // Accessors for subsystems
    JarvisSecurityManager* securityManager() const { return m_security.get(); }
    WakeWordDetector* wakeWordDetector() const { return m_wakeWord.get(); }
    VoiceSystem* voiceSystem() const { return m_voice.get(); }
    SpeechRecognizer* speechRecognizer() const { return m_speech.get(); }
    IntentRecognizer* intentRecognizer() const { return m_intent.get(); }
    CameraService* cameraService() const { return m_camera.get(); }
    GestureRecognizer* gestureRecognizer() const { return m_gestures.get(); }
    ActionDispatcher* actionDispatcher() const { return m_dispatcher.get(); }
    JarvisSettings* settings() const { return m_settings.get(); }

signals:
    void stateChanged(JarvisState newState, const QString& stateStr);
    void activeChanged(bool active);
    void wakeWordStateChanged(bool listening);
    void micStateChanged(bool listening);
    void micMutedChanged(bool muted);
    void cameraActiveChanged(bool active);
    void audioLevelChanged(double level);
    void gestureChanged(const QString& gesture);
    void gestureConfidenceChanged(double confidence);
    void transcriptChanged(const QString& transcript);
    void spokenResponseChanged(const QString& response);
    void feedbackChanged(const QString& feedback);
    void historyChanged();
    void languageChanged(const QString& lang);
    void intentExecuted(const QString& intentType, const QString& target, bool success);

private:
    void setState(JarvisState newState);
    void addHistoryItem(const QString& role, const QString& content, const QString& lang = "en");

    JarvisState m_state{JarvisState::Idle};
    bool m_isActive{true};

    QString m_lastTranscript;
    QString m_lastSpokenResponse;
    QString m_lastFeedback;
    QVariantList m_history;

    std::unique_ptr<JarvisSecurityManager> m_security;
    std::unique_ptr<JarvisSettings> m_settings;
    std::unique_ptr<WakeWordDetector> m_wakeWord;
    std::unique_ptr<VoiceSystem> m_voice;
    std::unique_ptr<SpeechRecognizer> m_speech;
    std::unique_ptr<IntentRecognizer> m_intent;
    std::unique_ptr<CameraService> m_camera;
    std::unique_ptr<GestureRecognizer> m_gestures;
    std::unique_ptr<ActionDispatcher> m_dispatcher;
};

} // namespace sritec::jarvis
