#pragma once

#include <QObject>
#include <QString>
#include <QTimer>

namespace sritec::shell {

class NebulaAudioService;

/**
 * @brief NebulaPowerManager controls system power states:
 * Shutdown, Restart, Sleep, Screen Lock, and Session Exit.
 * 
 * Features a safety countdown confirmation workflow with audio alerts
 * and non-destructive host safety guards.
 */
class NebulaPowerManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isConfirmationActive READ isConfirmationActive NOTIFY isConfirmationActiveChanged)
    Q_PROPERTY(QString pendingAction READ pendingAction NOTIFY pendingActionChanged)
    Q_PROPERTY(int countdownSeconds READ countdownSeconds NOTIFY countdownSecondsChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(bool simulationMode READ simulationMode WRITE setSimulationMode NOTIFY simulationModeChanged)

public:
    explicit NebulaPowerManager(NebulaAudioService* audioService = nullptr, QObject* parent = nullptr);
    ~NebulaPowerManager() override = default;

    bool isConfirmationActive() const { return m_isConfirmationActive; }
    QString pendingAction() const { return m_pendingAction; }
    int countdownSeconds() const { return m_countdownSeconds; }
    QString statusMessage() const { return m_statusMessage; }
    bool simulationMode() const { return m_simulationMode; }
    void setSimulationMode(bool sim);

    // QML Invokable power state requests
    Q_INVOKABLE void requestShutdown();
    Q_INVOKABLE void requestRestart();
    Q_INVOKABLE void requestSleep();
    Q_INVOKABLE void requestLock();
    Q_INVOKABLE void requestQuit();

    // Confirm or abort pending action
    Q_INVOKABLE void confirmAction();
    Q_INVOKABLE void cancelAction();

signals:
    void isConfirmationActiveChanged(bool active);
    void pendingActionChanged(const QString& action);
    void countdownSecondsChanged(int seconds);
    void statusMessageChanged(const QString& msg);
    void simulationModeChanged(bool sim);
    void actionTriggered(const QString& action);

private slots:
    void onCountdownTick();

private:
    void triggerAction(const QString& action);
    void startConfirmation(const QString& action, int initialCountdown = 30);

    NebulaAudioService* m_audioService{nullptr};
    bool m_isConfirmationActive{false};
    QString m_pendingAction;
    int m_countdownSeconds{30};
    QString m_statusMessage;
    bool m_simulationMode{true}; // Safe host mode enabled by default
    QTimer* m_countdownTimer{nullptr};
};

} // namespace sritec::shell
