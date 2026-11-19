#include "gesture_recognizer.hpp"
#include "sritec/logger.hpp"

#include <QDateTime>

namespace sritec::jarvis {

GestureRecognizer::GestureRecognizer(QObject* parent)
    : QObject(parent)
{
    sritec::Logger::instance().info("GESTURE_REC", "GestureRecognizer initialized with 9 standard spatial hand mappings.");
}

void GestureRecognizer::setEnabled(bool enabled) {
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged(enabled);
        if (!enabled) {
            m_currentGesture = HandGesture::None;
            m_confidence = 0.0;
            emit gestureChanged("None");
            emit confidenceChanged(0.0);
        }
    }
}

void GestureRecognizer::setLeftHandMode(bool leftHand) {
    if (m_isLeftHandMode != leftHand) {
        m_isLeftHandMode = leftHand;
        emit handModeChanged(leftHand);
        sritec::Logger::instance().info("GESTURE_REC", QString("Hand mode switched to: %1").arg(leftHand ? "LEFT" : "RIGHT").toStdString());
    }
}

void GestureRecognizer::setSensitivity(double sensitivity) {
    double s = qBound(0.1, sensitivity, 1.0);
    if (qAbs(m_sensitivity - s) > 0.01) {
        m_sensitivity = s;
        emit sensitivityChanged(s);
    }
}

void GestureRecognizer::calibrate() {
    m_cursorPos = QPointF(960.0, 540.0);
    emit virtualCursorPosChanged(m_cursorPos);
    sritec::Logger::instance().info("GESTURE_REC", "Gesture sensor calibrated to screen center (960, 540).");
}

void GestureRecognizer::simulateGesture(const QString& gestureName, double confidence) {
    if (!m_enabled) return;

    QString lower = gestureName.trimmed().toLower();
    HandGesture gesture = HandGesture::None;

    if (lower == "openpalm" || lower == "open_palm" || lower == "palm") {
        gesture = HandGesture::OpenPalm;
    } else if (lower == "pinch" || lower == "thumbindexpinch" || lower == "left_click") {
        gesture = HandGesture::ThumbIndexPinch;
    } else if (lower == "twofingerpinch" || lower == "right_click") {
        gesture = HandGesture::TwoFingerPinch;
    } else if (lower == "scroll" || lower == "twofingerverticalmove") {
        gesture = HandGesture::TwoFingerVerticalMove;
    } else if (lower == "closedfist" || lower == "fist" || lower == "pause") {
        gesture = HandGesture::ClosedFist;
    } else if (lower == "swipeleft" || lower == "swipe_left") {
        gesture = HandGesture::SwipeLeft;
    } else if (lower == "swiperight" || lower == "swipe_right") {
        gesture = HandGesture::SwipeRight;
    } else if (lower == "openpalmhold" || lower == "menu") {
        gesture = HandGesture::OpenPalmHold;
    } else if (lower == "zoom" || lower == "distance_change" || lower == "thumbindexdistancechange") {
        gesture = HandGesture::ThumbIndexDistanceChange;
    }

    m_currentGesture = gesture;
    m_confidence = qBound(0.0, confidence, 1.0);

    emit gestureChanged(gestureToString(gesture));
    emit confidenceChanged(m_confidence);
    emit gestureActionTriggered(gesture, gestureToString(gesture));

    qint64 now = QDateTime::currentMSecsSinceEpoch();

    // Trigger discrete action with click debounce
    if (gesture == HandGesture::ThumbIndexPinch) {
        if (now - m_lastClickTimeMs >= ClickDebounceMs) {
            m_lastClickTimeMs = now;
            emit leftClickTriggered(m_cursorPos);
            sritec::Logger::instance().info("GESTURE_REC", "Gesture Action: Left Click fired.");
        }
    } else if (gesture == HandGesture::TwoFingerPinch) {
        if (now - m_lastClickTimeMs >= ClickDebounceMs) {
            m_lastClickTimeMs = now;
            emit rightClickTriggered(m_cursorPos);
            sritec::Logger::instance().info("GESTURE_REC", "Gesture Action: Right Click fired.");
        }
    } else if (gesture == HandGesture::SwipeLeft) {
        emit workspaceSwipeTriggered(-1);
    } else if (gesture == HandGesture::SwipeRight) {
        emit workspaceSwipeTriggered(1);
    } else if (gesture == HandGesture::TwoFingerVerticalMove) {
        emit scrollTriggered(-120);
    }
}

void GestureRecognizer::processLandmarks(const QVariantList& landmarks) {
    if (!m_enabled || landmarks.isEmpty()) return;

    // Smooth virtual cursor position based on index finger tip (landmark index 1 or 2)
    if (landmarks.size() >= 2) {
        QVariantMap tip = landmarks[1].toMap();
        double normX = tip["x"].toDouble();
        double normY = tip["y"].toDouble();

        if (m_isLeftHandMode) {
            normX = 1.0 - normX; // Invert for left-handed mirror mapping
        }

        double targetX = normX * 1920.0;
        double targetY = normY * 1080.0;

        // Exponential smoothing filter
        double alpha = 0.35 * m_sensitivity;
        m_cursorPos.setX(m_cursorPos.x() * (1.0 - alpha) + targetX * alpha);
        m_cursorPos.setY(m_cursorPos.y() * (1.0 - alpha) + targetY * alpha);

        emit virtualCursorPosChanged(m_cursorPos);
    }
}

} // namespace sritec::jarvis
