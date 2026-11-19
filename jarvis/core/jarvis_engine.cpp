#include "jarvis_engine.hpp"
#include "../security/jarvis_security_manager.hpp"
#include "../settings/jarvis_settings.hpp"
#include "../wakeword/wakeword_detector.hpp"
#include "../voice/voice_system.hpp"
#include "../speech/speech_recognizer.hpp"
#include "../intent/intent_recognizer.hpp"
#include "../vision/camera_service.hpp"
#include "../gestures/gesture_recognizer.hpp"
#include "../actions/action_dispatcher.hpp"
#include "sritec/logger.hpp"

namespace sritec::jarvis {

JarvisEngine::JarvisEngine(
    sritec::shell::AppLaunchManager* appLaunchMgr,
    sritec::shell::AppLauncher* launcher,
    sritec::shell::DesktopManager* desktopMgr,
    sritec::ai::AIBridge* aiBridge,
    QObject* parent)
    : QObject(parent)
{
    sritec::Logger::instance().info("JARVIS", "Initializing NEBULA JARVIS Multimodal Voice & Vision Subsystem...");

    // 1. Initialize Subsystems
    m_security = std::make_unique<JarvisSecurityManager>(this);
    m_settings = std::make_unique<JarvisSettings>(this);
    m_wakeWord = std::make_unique<WakeWordDetector>(this);
    m_voice = std::make_unique<VoiceSystem>(m_security.get(), this);
    m_speech = std::make_unique<SpeechRecognizer>(this);
    m_intent = std::make_unique<IntentRecognizer>(this);
    m_camera = std::make_unique<CameraService>(m_security.get(), this);
    m_gestures = std::make_unique<GestureRecognizer>(this);
    m_dispatcher = std::make_unique<ActionDispatcher>(
        m_security.get(), appLaunchMgr, launcher, desktopMgr, aiBridge, m_camera.get(), this
    );

    // Apply persisted settings
    m_wakeWord->setEnabled(m_settings->isWakeWordEnabled());
    m_wakeWord->setSensitivity(m_settings->wakeWordSensitivity());
    m_speech->setLanguage(m_settings->preferredLanguage());
    m_speech->setSpeechSpeed(m_settings->speechSpeed());
    m_gestures->setEnabled(m_settings->isGestureControlEnabled());
    m_gestures->setSensitivity(m_settings->gestureSensitivity());
    m_gestures->setLeftHandMode(m_settings->isLeftHandMode());

    // 2. Wire Up Internal Signals
    // Wake Word -> Engine
    connect(m_wakeWord.get(), &WakeWordDetector::wakeWordDetected, this, [this](const QString& phrase, double) {
        if (!m_isActive) return;
        sritec::Logger::instance().info("JARVIS", "Wake-word triggered: " + phrase.toStdString());
        setState(JarvisState::Listening);
        startListening();
        m_speech->speak("Yes, sir?", m_settings->preferredLanguage());
    });

    // Voice System -> Engine
    connect(m_voice.get(), &VoiceSystem::audioLevelChanged, this, &JarvisEngine::audioLevelChanged);
    connect(m_voice.get(), &VoiceSystem::muteStateChanged, this, &JarvisEngine::micMutedChanged);
    connect(m_voice.get(), &VoiceSystem::listeningStateChanged, this, &JarvisEngine::micStateChanged);

    // Speech -> Engine
    connect(m_speech.get(), &SpeechRecognizer::speechStarted, this, [this](const QString& text) {
        setState(JarvisState::Speaking);
        m_lastSpokenResponse = text;
        emit spokenResponseChanged(text);
    });
    connect(m_speech.get(), &SpeechRecognizer::speechFinished, this, [this]() {
        if (m_state == JarvisState::Speaking) {
            setState(JarvisState::Idle);
        }
    });

    // Gestures -> Camera Vision Link
    connect(m_camera.get(), &CameraService::handLandmarksDetected, m_gestures.get(), &GestureRecognizer::processLandmarks);
    connect(m_camera.get(), &CameraService::runningStateChanged, this, &JarvisEngine::cameraActiveChanged);
    connect(m_gestures.get(), &GestureRecognizer::gestureChanged, this, &JarvisEngine::gestureChanged);
    connect(m_gestures.get(), &GestureRecognizer::confidenceChanged, this, &JarvisEngine::gestureConfidenceChanged);

    // Initial greeting
    addHistoryItem("jarvis", "JARVIS AI Voice & Vision System Online. Multimodal Core Ready.", m_settings->preferredLanguage());

    setState(JarvisState::Idle);
    m_wakeWord->startListening();

    sritec::Logger::instance().info("JARVIS", "JARVIS Core Engine ready. State: IDLE.");
}

JarvisEngine::~JarvisEngine() {
    stopListening();
    if (m_camera) m_camera->stopCamera();
}

void JarvisEngine::setState(JarvisState newState) {
    if (m_state != newState) {
        m_state = newState;
        emit stateChanged(m_state, stateToString(m_state));
        sritec::Logger::instance().info("JARVIS", "State changed to: " + stateToString(m_state).toStdString());
    }
}

void JarvisEngine::setActive(bool active) {
    if (m_isActive != active) {
        m_isActive = active;
        emit activeChanged(active);
        if (!active) {
            setState(JarvisState::Offline);
            stopListening();
            if (m_camera) m_camera->stopCamera();
        } else {
            setState(JarvisState::Idle);
            if (m_wakeWord) m_wakeWord->startListening();
        }
    }
}

void JarvisEngine::togglePower() {
    setActive(!m_isActive);
}

bool JarvisEngine::isWakeWordListening() const {
    return m_wakeWord ? m_wakeWord->isListeningForWakeWord() : false;
}

bool JarvisEngine::isMicListening() const {
    return m_voice ? m_voice->isListening() : false;
}

bool JarvisEngine::isMicMuted() const {
    return m_security ? m_security->isMicrophoneMuted() : false;
}

bool JarvisEngine::isCameraActive() const {
    return m_camera ? m_camera->isRunning() : false;
}

double JarvisEngine::audioLevel() const {
    return m_voice ? m_voice->audioLevel() : 0.0;
}

QString JarvisEngine::detectedGesture() const {
    return m_gestures ? m_gestures->currentGesture() : "None";
}

double JarvisEngine::gestureConfidence() const {
    return m_gestures ? m_gestures->confidence() : 0.0;
}

QString JarvisEngine::activeLanguage() const {
    return m_settings ? m_settings->preferredLanguage() : "en";
}

void JarvisEngine::setActiveLanguage(const QString& lang) {
    if (m_settings) {
        m_settings->setPreferredLanguage(lang);
        if (m_speech) m_speech->setLanguage(lang);
        emit languageChanged(lang);
    }
}

void JarvisEngine::startListening() {
    if (!m_isActive) return;
    setState(JarvisState::Listening);
    if (m_voice) m_voice->startListening();
}

void JarvisEngine::stopListening() {
    if (m_voice) m_voice->stopListening();
    if (m_state == JarvisState::Listening) {
        setState(JarvisState::Idle);
    }
}

void JarvisEngine::toggleMicrophone() {
    if (m_security) {
        m_security->setMicrophoneMuted(!m_security->isMicrophoneMuted());
    }
}

void JarvisEngine::toggleCamera() {
    if (m_camera) {
        m_camera->toggleCamera();
    }
}

void JarvisEngine::requestCameraPermission() {
    if (m_security) {
        m_security->requestCameraPermission();
        if (m_camera) m_camera->startCamera();
    }
}

void JarvisEngine::processUserInput(const QString& rawInput) {
    if (!m_isActive || rawInput.trimmed().isEmpty()) return;

    m_lastTranscript = rawInput.trimmed();
    emit transcriptChanged(m_lastTranscript);

    addHistoryItem("user", m_lastTranscript, activeLanguage());
    setState(JarvisState::Processing);

    // 1. Check for Wake Word
    QString matched;
    double conf = 0.0;
    m_wakeWord->testWakeWordInText(rawInput, matched, conf);

    // 2. Intent Recognition
    IntentResult intent = m_intent->parseCommand(rawInput);
    sritec::Logger::instance().info("JARVIS", QString("Parsed intent: Type=%1, Target='%2', Action='%3', Lang='%4'").arg(static_cast<int>(intent.type)).arg(intent.target, intent.action, intent.detectedLanguage).toStdString());

    setState(JarvisState::ExecutingApprovedAction);

    // 3. Dispatch Approved Action
    QString feedback;
    QString spoken;
    bool ok = m_dispatcher->executeIntent(intent, feedback, spoken);

    m_lastFeedback = feedback;
    m_lastSpokenResponse = spoken;
    emit feedbackChanged(feedback);
    emit spokenResponseChanged(spoken);
    emit intentExecuted(intent.action, intent.target, ok);

    addHistoryItem("jarvis", feedback, intent.detectedLanguage);

    // 4. Voice Response
    if (!spoken.isEmpty()) {
        m_speech->speak(spoken, intent.detectedLanguage);
    } else {
        setState(JarvisState::Idle);
    }
}

void JarvisEngine::simulateWakeWord(const QString& phrase) {
    QString matched;
    double conf = 0.0;
    if (m_wakeWord->testWakeWordInText(phrase, matched, conf)) {
        startListening();
    }
}

void JarvisEngine::simulateGesture(const QString& gestureName, double confidence) {
    if (m_gestures) {
        m_gestures->simulateGesture(gestureName, confidence);
    }
}

void JarvisEngine::emergencyShutdown() {
    if (m_security) {
        m_security->emergencyShutdownAllSensors();
    }
    stopListening();
    if (m_camera) m_camera->stopCamera();
    setState(JarvisState::Offline);
    m_isActive = false;
    emit activeChanged(false);
}

void JarvisEngine::clearHistory() {
    m_history.clear();
    emit historyChanged();
}

void JarvisEngine::addHistoryItem(const QString& role, const QString& content, const QString& lang) {
    QVariantMap item;
    item["role"] = role;
    item["content"] = content;
    item["language"] = lang;
    item["timestamp"] = QDateTime::currentDateTime().toString("hh:mm:ss");
    m_history.append(item);
    if (m_history.size() > 50) {
        m_history.removeFirst();
    }
    emit historyChanged();
}

} // namespace sritec::jarvis
