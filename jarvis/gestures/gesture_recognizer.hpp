#pragma once

#include <QObject>
#include <QString>
#include <QPointF>
#include "jarvis_types.hpp"

namespace sritec::jarvis {

class GestureRecognizer : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isEnabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString currentGesture READ currentGesture NOTIFY gestureChanged)
    Q_PROPERTY(double confidence READ confidence NOTIFY confidenceChanged)
    Q_PROPERTY(bool isLeftHandMode READ isLeftHandMode WRITE setLeftHandMode NOTIFY handModeChanged)
    Q_PROPERTY(double sensitivity READ sensitivity WRITE setSensitivity NOTIFY sensitivityChanged)
    Q_PROPERTY(QPointF virtualCursorPos READ virtualCursorPos NOTIFY virtualCursorPosChanged)

public:
    explicit GestureRecognizer(QObject* parent = nullptr);
    ~GestureRecognizer() override = default;

    bool isEnabled() const { return m_enabled; }
    void setEnabled(bool enabled);

    QString currentGesture() const { return gestureToString(m_currentGesture); }
    HandGesture activeGestureEnum() const { return m_currentGesture; }
    double confidence() const { return m_confidence; }

    bool isLeftHandMode() const { return m_isLeftHandMode; }
    void setLeftHandMode(bool leftHand);

    double sensitivity() const { return m_sensitivity; }
    void setSensitivity(double sensitivity);

    QPointF virtualCursorPos() const { return m_cursorPos; }

    // Direct gesture simulation and classification API
    Q_INVOKABLE void simulateGesture(const QString& gestureName, double confidence = 0.95);
    Q_INVOKABLE void calibrate();

    // Process hand landmark data (21 3D points or 5 finger endpoints)
    void processLandmarks(const QVariantList& landmarks);

signals:
    void enabledChanged(bool enabled);
    void gestureChanged(const QString& gesture);
    void confidenceChanged(double confidence);
    void handModeChanged(bool isLeft);
    void sensitivityChanged(double sensitivity);
    void virtualCursorPosChanged(const QPointF& pos);

    // Discrete action triggers
    void gestureActionTriggered(HandGesture gesture, const QString& actionName);
    void leftClickTriggered(const QPointF& pos);
    void rightClickTriggered(const QPointF& pos);
    void scrollTriggered(int deltaY);
    void workspaceSwipeTriggered(int direction); // -1: prev, +1: next

private:
    bool m_enabled{true};
    HandGesture m_currentGesture{HandGesture::None};
    double m_confidence{0.0};
    bool m_isLeftHandMode{false};
    double m_sensitivity{0.80};
    QPointF m_cursorPos{960.0, 540.0};

    qint64 m_lastClickTimeMs{0};
    static constexpr qint64 ClickDebounceMs = 350;
};

} // namespace sritec::jarvis
