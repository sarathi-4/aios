#pragma once

#include <QString>
#include <QVariantMap>
#include <QDateTime>

namespace sritec::jarvis {

enum class JarvisState {
    Offline = 0,
    Idle = 1,
    WakeWordListening = 2,
    Listening = 3,
    Processing = 4,
    ExecutingApprovedAction = 5,
    Speaking = 6,
    Error = 7
};

inline QString stateToString(JarvisState state) {
    switch (state) {
        case JarvisState::Offline: return "Offline";
        case JarvisState::Idle: return "Idle";
        case JarvisState::WakeWordListening: return "WakeWordListening";
        case JarvisState::Listening: return "Listening";
        case JarvisState::Processing: return "Processing";
        case JarvisState::ExecutingApprovedAction: return "ExecutingApprovedAction";
        case JarvisState::Speaking: return "Speaking";
        case JarvisState::Error: return "Error";
    }
    return "Unknown";
}

enum class HandGesture {
    None = 0,
    OpenPalm = 1,                 // Enable cursor movement
    ThumbIndexPinch = 2,          // Left click
    TwoFingerPinch = 3,           // Right click
    TwoFingerVerticalMove = 4,    // Scroll
    ClosedFist = 5,               // Pause gesture control
    SwipeLeft = 6,                // Previous workspace
    SwipeRight = 7,               // Next workspace
    OpenPalmHold = 8,             // Show gesture menu
    ThumbIndexDistanceChange = 9  // Zoom where supported
};

inline QString gestureToString(HandGesture gesture) {
    switch (gesture) {
        case HandGesture::None: return "None";
        case HandGesture::OpenPalm: return "OpenPalm";
        case HandGesture::ThumbIndexPinch: return "ThumbIndexPinch";
        case HandGesture::TwoFingerPinch: return "TwoFingerPinch";
        case HandGesture::TwoFingerVerticalMove: return "TwoFingerVerticalMove";
        case HandGesture::ClosedFist: return "ClosedFist";
        case HandGesture::SwipeLeft: return "SwipeLeft";
        case HandGesture::SwipeRight: return "SwipeRight";
        case HandGesture::OpenPalmHold: return "OpenPalmHold";
        case HandGesture::ThumbIndexDistanceChange: return "ThumbIndexDistanceChange";
    }
    return "Unknown";
}

enum class IntentType {
    Unknown = 0,
    AppLaunch = 1,
    SystemStatus = 2,
    WindowControl = 3,
    WorkspaceSwitch = 4,
    CameraControl = 5,
    SearchFiles = 6,
    StopListening = 7,
    GeneralQuery = 8
};

struct IntentResult {
    IntentType type{IntentType::Unknown};
    QString rawQuery;
    QString target;             // e.g. "files", "browser", "terminal", "vscode"
    QString action;             // e.g. "open", "close", "minimize", "maximize", "on", "off"
    QString detectedLanguage;   // "en", "ta", "hi"
    double confidence{0.0};
    bool requiresConfirmation{false};
    QString confirmationPrompt;
    QVariantMap parameters;
};

struct CameraDeviceInfo {
    int id{0};
    QString name;
    QString deviceNode;         // e.g. /dev/video0
    bool isAvailable{false};
    int maxWidth{1280};
    int maxHeight{720};
    int maxFps{30};
};

struct VoiceMetrics {
    double energyLevel{0.0};    // 0.0 to 1.0 (RMS power)
    bool isVoiceActive{false};
    double speechDurationMs{0.0};
};

} // namespace sritec::jarvis
