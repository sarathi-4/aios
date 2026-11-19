#include "nebula_power_manager.hpp"
#include "nebula_audio_service.hpp"
#include "sritec/logger.hpp"

#include <QCoreApplication>
#include <QProcess>

namespace sritec::shell {

NebulaPowerManager::NebulaPowerManager(NebulaAudioService* audioService, QObject* parent)
    : QObject(parent)
    , m_audioService(audioService)
    , m_countdownTimer(new QTimer(this))
{
    m_countdownTimer->setInterval(1000);
    connect(m_countdownTimer, &QTimer::timeout, this, &NebulaPowerManager::onCountdownTick);

    sritec::Logger::instance().info("POWER", "NebulaPowerManager initialized (Safe Host Simulation Mode: ON)");
}

void NebulaPowerManager::setSimulationMode(bool sim) {
    if (m_simulationMode != sim) {
        m_simulationMode = sim;
        emit simulationModeChanged(sim);
        sritec::Logger::instance().info("POWER", QString("Simulation mode set to %1").arg(sim ? "ON" : "OFF").toStdString());
    }
}

void NebulaPowerManager::requestShutdown() {
    startConfirmation("shutdown", 30);
}

void NebulaPowerManager::requestRestart() {
    startConfirmation("restart", 30);
}

void NebulaPowerManager::requestSleep() {
    startConfirmation("sleep", 15);
}

void NebulaPowerManager::requestLock() {
    // Lock can be triggered immediately or with quick confirm
    startConfirmation("lock", 10);
}

void NebulaPowerManager::requestQuit() {
    startConfirmation("quit", 15);
}

void NebulaPowerManager::startConfirmation(const QString& action, int initialCountdown) {
    m_pendingAction = action;
    m_countdownSeconds = initialCountdown;
    m_isConfirmationActive = true;

    if (action == "shutdown") {
        m_statusMessage = "System is preparing to safely halt all neural services and power off.";
    } else if (action == "restart") {
        m_statusMessage = "System is preparing to reboot NEBULA operating environment.";
    } else if (action == "sleep") {
        m_statusMessage = "Entering low-power neural suspension state.";
    } else if (action == "lock") {
        m_statusMessage = "Securing NEBULA workspace and locking active user session.";
    } else if (action == "quit") {
        m_statusMessage = "Terminating NEBULA desktop session and returning to host display.";
    }

    emit pendingActionChanged(m_pendingAction);
    emit countdownSecondsChanged(m_countdownSeconds);
    emit statusMessageChanged(m_statusMessage);
    emit isConfirmationActiveChanged(true);

    if (m_audioService) {
        m_audioService->playNotification();
    }

    m_countdownTimer->start();
    sritec::Logger::instance().info("POWER", QString("Power confirmation requested for: %1 (Countdown: %2s)")
        .arg(action).arg(initialCountdown).toStdString());
}

void NebulaPowerManager::cancelAction() {
    if (!m_isConfirmationActive) return;

    m_countdownTimer->stop();
    m_isConfirmationActive = false;
    m_pendingAction.clear();
    m_countdownSeconds = 0;

    emit isConfirmationActiveChanged(false);
    emit pendingActionChanged(m_pendingAction);
    emit countdownSecondsChanged(0);

    if (m_audioService) {
        m_audioService->playClick();
    }

    sritec::Logger::instance().info("POWER", "Power action aborted by user.");
}

void NebulaPowerManager::confirmAction() {
    if (!m_isConfirmationActive) return;

    m_countdownTimer->stop();
    QString action = m_pendingAction;
    m_isConfirmationActive = false;
    emit isConfirmationActiveChanged(false);

    triggerAction(action);
}

void NebulaPowerManager::onCountdownTick() {
    if (m_countdownSeconds > 1) {
        m_countdownSeconds--;
        emit countdownSecondsChanged(m_countdownSeconds);
        // Play subtle tick on last 5 seconds
        if (m_countdownSeconds <= 5 && m_audioService) {
            m_audioService->playClick();
        }
    } else {
        // Countdown reached 0: execute action
        confirmAction();
    }
}

void NebulaPowerManager::triggerAction(const QString& action) {
    emit actionTriggered(action);
    sritec::Logger::instance().info("POWER", QString("Executing power action: %1 (Simulation: %2)")
        .arg(action).arg(m_simulationMode ? "YES" : "NO").toStdString());

    if (m_audioService) {
        m_audioService->playChime();
    }

    if (m_simulationMode) {
        // Safe Simulation Mode: Do not reboot or power off user's host PC!
        sritec::Logger::instance().info("POWER", 
            QString("[SAFE SIMULATION] Gracefully executing step-by-step: %1").arg(action).toStdString());

        if (action == "quit" || action == "shutdown") {
            sritec::Logger::instance().info("POWER", "Flushing workspace buffers and shutting down application.");
            QTimer::singleShot(600, []() {
                QCoreApplication::quit();
            });
        }
        return;
    }

    // Real Execution Mode (Used on production ISO / dedicated hardware)
    if (action == "shutdown") {
        QProcess::startDetached("/usr/bin/systemctl", QStringList() << "poweroff");
    } else if (action == "restart") {
        QProcess::startDetached("/usr/bin/systemctl", QStringList() << "reboot");
    } else if (action == "sleep") {
        QProcess::startDetached("/usr/bin/systemctl", QStringList() << "suspend");
    } else if (action == "lock") {
        QProcess::startDetached("/usr/bin/loginctl", QStringList() << "lock-session");
    } else if (action == "quit") {
        QCoreApplication::quit();
    }
}

} // namespace sritec::shell
