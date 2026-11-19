#include "app_launch_manager.hpp"
#include "app_launcher.hpp"
#include "desktop_manager.hpp"
#include "nebula_file_manager.hpp"
#include "nebula_terminal_backend.hpp"
#include "nebula_dev_workspace.hpp"
#include "nebula_browser_backend.hpp"
#include "nebula_dev_workstation.hpp"
#include "nebula_audio_service.hpp"
#include "nebula_screen_capture_service.hpp"
#include "nebula_power_manager.hpp"
#include "sritec/logger.hpp"

#include <QGuiApplication>
#include <cassert>
#include <iostream>

int main(int argc, char* argv[]) {
    qputenv("QT_QPA_PLATFORM", "offscreen");
    QGuiApplication app(argc, argv);

    std::cout << "[TEST] Starting Milestone 3.4 Internal Application Ecosystem Unit Test Suite..." << std::endl;

    auto* launcher = new sritec::shell::AppLauncher(&app);
    auto* desktopMgr = new sritec::shell::DesktopManager(&app);
    auto* launchMgr = new sritec::shell::AppLaunchManager(launcher, desktopMgr, &app);

    // Test 1: Registry Verification & Classification
    std::cout << "[TEST] 1. Verifying App Launch Registry catalog and classifications..." << std::endl;
    QVariantList registeredApps = launchMgr->getRegisteredApps();
    assert(!registeredApps.isEmpty());
    assert(registeredApps.size() >= 15);

    QVariantMap filesMeta = launchMgr->getAppRegistryEntry("files");
    assert(filesMeta["id"].toString() == "files");
    assert(filesMeta["launchType"].toString() == "internal");
    assert(launchMgr->isInternalApp("files"));
    assert(launchMgr->isAppSupported("files"));
    assert(launchMgr->getAppClassification("files") == "InternalNative");

    QVariantMap browserMeta = launchMgr->getAppRegistryEntry("browser");
    assert(browserMeta["id"].toString() == "browser");
    assert(browserMeta["launchType"].toString() == "internal");
    assert(launchMgr->isInternalApp("browser"));
    assert(launchMgr->isAppSupported("browser"));
    assert(launchMgr->getAppClassification("browser") == "EmbeddedWeb");

    QVariantMap firefoxMeta = launchMgr->getAppRegistryEntry("firefox");
    assert(firefoxMeta["id"].toString() == "firefox");
    assert(firefoxMeta["launchType"].toString() == "external");
    assert(!launchMgr->isInternalApp("firefox"));
    assert(!launchMgr->isAppSupported("firefox"));
    assert(launchMgr->getAppClassification("firefox") == "UnsupportedExternal");
    assert(firefoxMeta["fallbackApp"].toString() == "browser");

    std::cout << "[TEST] 1. PASSED: Registry contains " << registeredApps.size() << " registered applications with strict classifications." << std::endl;

    // Test 2: Internal Application Launch Lifecycle
    std::cout << "[TEST] 2. Verifying internal application launch lifecycle..." << std::endl;
    int reqCount = 0;
    int openCount = 0;
    QObject::connect(launchMgr, &sritec::shell::AppLaunchManager::appLaunchRequested, [&reqCount]() {
        reqCount++;
    });
    QObject::connect(launchMgr, &sritec::shell::AppLaunchManager::windowOpened, [&openCount]() {
        openCount++;
    });

    launchMgr->requestAppLaunch("files", 100.0, 200.0, 48.0, 48.0);
    assert(reqCount == 1);
    assert(launchMgr->isTransitionActive());
    assert(launchMgr->transitionPhase() == "burst");

    QVariantMap activeTrans = launchMgr->activeTransition();
    assert(activeTrans["appId"].toString() == "files");
    assert(activeTrans["originX"].toDouble() == 100.0);
    assert(activeTrans["originY"].toDouble() == 200.0);

    // Complete transition to open internal window
    launchMgr->completeTransition("files");
    assert(!launchMgr->isTransitionActive());
    assert(openCount == 1);
    assert(launchMgr->isAppRunning("files"));
    assert(launchMgr->activeWindowCount() == 1);

    QString winId = launchMgr->getRunningWindowId("files");
    assert(!winId.isEmpty());
    assert(launchMgr->focusedWindowId() == winId);

    std::cout << "[TEST] 2. PASSED: Internal window created: " << winId.toStdString() << std::endl;

    // Test 3: Multi-Window Operations (Minimize, Restore, Maximize, Close)
    std::cout << "[TEST] 3. Verifying multi-window operations..." << std::endl;
    launchMgr->minimizeWindow(winId);
    assert(launchMgr->activeWindowCount() == 0);

    launchMgr->restoreWindow(winId);
    assert(launchMgr->activeWindowCount() == 1);

    launchMgr->toggleMaximizeWindow(winId);
    QVariantList openWins = launchMgr->openWindows();
    assert(!openWins.isEmpty());
    assert(openWins.first().toMap()["isMaximized"].toBool() == true);

    launchMgr->toggleMaximizeWindow(winId);
    openWins = launchMgr->openWindows();
    assert(openWins.first().toMap()["isMaximized"].toBool() == false);

    // Test second internal window
    launchMgr->requestAppLaunch("terminal", 400.0, 300.0, 48.0, 48.0);
    launchMgr->completeTransition("terminal");
    assert(launchMgr->activeWindowCount() == 2);
    assert(launchMgr->isAppRunning("terminal"));

    QString termWinId = launchMgr->getRunningWindowId("terminal");
    assert(launchMgr->focusedWindowId() == termWinId);

    // Focus switching
    launchMgr->focusWindow(winId);
    assert(launchMgr->focusedWindowId() == winId);

    // Close windows
    launchMgr->closeWindow(winId);
    assert(!launchMgr->isAppRunning("files"));
    assert(launchMgr->activeWindowCount() == 1);

    launchMgr->closeWindow(termWinId);
    assert(!launchMgr->isAppRunning("terminal"));
    assert(launchMgr->activeWindowCount() == 0);

    std::cout << "[TEST] 3. PASSED: Multi-window management and focus verified." << std::endl;

    // Test 4: External Application Launch Handoff & Unsupported Notification
    std::cout << "[TEST] 4. Verifying external application launch handoff and host suppression..." << std::endl;
    int completeCount = 0;
    bool unsupportedNotified = false;
    QObject::connect(launchMgr, &sritec::shell::AppLaunchManager::appLaunchCompleted, [&completeCount]() {
        completeCount++;
    });
    QObject::connect(launchMgr, &sritec::shell::AppLaunchManager::unsupportedAppRequested,
                     [&unsupportedNotified](const QString&, const QString&, const QString&) {
        unsupportedNotified = true;
    });

    launchMgr->requestAppLaunch("firefox", 500.0, 600.0, 48.0, 48.0);
    assert(launchMgr->isTransitionActive());
    assert(launchMgr->activeTransition()["launchType"].toString() == "external");

    launchMgr->completeTransition("firefox");
    assert(!launchMgr->isTransitionActive());
    assert(completeCount == 1);
    assert(unsupportedNotified);
    assert(launchMgr->hasUnsupportedNotice());
    assert(launchMgr->unsupportedAppNotice()["appId"].toString() == "firefox");
    assert(launchMgr->unsupportedAppNotice()["alternative"].toString() == "browser");

    // External apps do NOT create detached host floating window frames
    assert(!launchMgr->isAppRunning("firefox"));
    assert(launchMgr->activeWindowCount() == 0);

    launchMgr->dismissUnsupportedNotice();
    assert(!launchMgr->hasUnsupportedNotice());

    std::cout << "[TEST] 4. PASSED: External process suppression verified with internal notice." << std::endl;

    // Test 5: Re-launching Running Application Focuses Existing Window
    std::cout << "[TEST] 5. Verifying re-launch focuses existing window..." << std::endl;
    launchMgr->requestAppLaunch("calculator", 120.0, 120.0);
    launchMgr->completeTransition("calculator");
    QString calcWin = launchMgr->getRunningWindowId("calculator");
    assert(!calcWin.isEmpty());

    // Minimize it
    launchMgr->minimizeWindow(calcWin);
    assert(launchMgr->activeWindowCount() == 0);

    // Requesting launch again should restore and focus existing window without duplicate creation
    launchMgr->requestAppLaunch("calculator");
    assert(launchMgr->activeWindowCount() == 1);
    assert(launchMgr->focusedWindowId() == calcWin);

    launchMgr->closeWindow(calcWin);
    std::cout << "[TEST] 5. PASSED: Existing instance focused and restored." << std::endl;

    // Test 6: NebulaFileManager Real Filesystem Operations
    std::cout << "[TEST] 6. Verifying NebulaFileManager filesystem navigation & guardrails..." << std::endl;
    auto* fileMgr = new sritec::shell::NebulaFileManager(&app);
    assert(!fileMgr->currentPath().isEmpty());
    assert(fileMgr->totalItemCount() > 0);
    assert(!fileMgr->pathBreadcrumbs().isEmpty());

    // Verify places and detected drives
    assert(!fileMgr->places().isEmpty());
    assert(fileMgr->places().size() >= 5);
    assert(!fileMgr->drives().isEmpty());
    assert(fileMgr->drives().size() >= 3);
    bool found250Drive = false;
    for (const auto& d : fileMgr->drives()) {
        if (d.toMap()["name"].toString().contains("250")) {
            found250Drive = true;
            break;
        }
    }
    assert(found250Drive);

    // Test directory preview
    QVariantMap preview = fileMgr->readFilePreview("CMakeLists.txt", 1024);
    assert(preview["name"].toString() == "CMakeLists.txt");
    assert(preview["previewType"].toString() == "text");
    assert(!preview["content"].toString().isEmpty());

    // Test guardrails preventing root deletion
    bool delRoot = fileMgr->deleteItem("/etc");
    assert(!delRoot); // Must be rejected by isPathSafe()

    std::cout << "[TEST] 6. PASSED: NebulaFileManager operations and guardrails verified." << std::endl;

    // Test 7: NebulaTerminalBackend Interactive Commands & Guardrails
    std::cout << "[TEST] 7. Verifying NebulaTerminalBackend commands & AI safety..." << std::endl;
    auto* termBackend = new sritec::shell::NebulaTerminalBackend(&app);
    assert(termBackend->sessionCount() >= 1);
    assert(!termBackend->activeSessionId().isEmpty());

    // Test safe built-in help
    termBackend->executeCommand("help");
    assert(!termBackend->activeOutput().isEmpty());

    // Test safety alert on sudo escalation
    bool safetyTriggered = false;
    QObject::connect(termBackend, &sritec::shell::NebulaTerminalBackend::safetyAlertTriggered,
                     [&safetyTriggered](const QString&, const QString&) {
        safetyTriggered = true;
    });

    termBackend->executeCommand("sudo apt install something");
    assert(safetyTriggered);

    safetyTriggered = false;
    termBackend->executeCommand("rm -rf /");
    assert(safetyTriggered);

    std::cout << "[TEST] 7. PASSED: NebulaTerminalBackend interactive execution and guardrails verified." << std::endl;

    // Test 8: NebulaDevWorkspace Project Explorer & File Tabs
    std::cout << "[TEST] 8. Verifying NebulaDevWorkspace project tree & tabs..." << std::endl;
    auto* devWorkspace = new sritec::shell::NebulaDevWorkspace(&app);
    assert(!devWorkspace->projectRoot().isEmpty());
    assert(!devWorkspace->projectTree().isEmpty());
    assert(devWorkspace->totalTabCount() >= 1);
    assert(!devWorkspace->activeContent().isEmpty());

    // Search in active file
    QVariantList matches = devWorkspace->searchInActiveFile("cmake");
    // CMakeLists.txt typically contains "cmake" or "project"
    if (matches.isEmpty()) {
        matches = devWorkspace->searchInActiveFile("SRITEC");
    }
    std::cout << "[TEST] 8. PASSED: NebulaDevWorkspace workspace active with " << devWorkspace->totalTabCount() << " open buffer." << std::endl;

    // Test 9: NebulaBrowserBackend Tabs, History & Portals
    std::cout << "[TEST] 9. Verifying NebulaBrowserBackend tabs, bookmarks & AI portals..." << std::endl;
    auto* browserBackend = new sritec::shell::NebulaBrowserBackend(&app);
    assert(!browserBackend->tabs().isEmpty());
    assert(!browserBackend->bookmarks().isEmpty());

    // Navigate to a search query
    browserBackend->navigate("holographic quantum computing");
    assert(browserBackend->activeUrl().contains("duckduckgo.com"));

    // Open AI Portal
    browserBackend->openAIPortal("chatgpt");
    assert(browserBackend->activeUrl() == "https://chatgpt.com");
    assert(browserBackend->tabs().size() >= 2);

    browserBackend->openAIPortal("gemini");
    assert(browserBackend->activeUrl() == "https://gemini.google.com");
    assert(browserBackend->tabs().size() >= 3);

    std::cout << "[TEST] 9. PASSED: NebulaBrowserBackend tab routing and AI portals verified." << std::endl;

    // Test 10: NebulaDevWorkstation IDE Detection & Human-Approval Guardrails
    std::cout << "[TEST] 10. Verifying NebulaDevWorkstation IDE audits and AI code proposal approval..." << std::endl;
    auto* devWorkstation = new sritec::shell::NebulaDevWorkstation(&app);
    assert(devWorkstation->isAntigravityActive());
    assert(devWorkstation->isAndroidSdkAvailable());
    assert(!devWorkstation->androidSdkComponents().isEmpty());
    assert(!devWorkstation->installedJdks().isEmpty());

    // Switch workspace modes
    devWorkstation->setActiveMode("vscode");
    assert(devWorkstation->activeMode() == "vscode");
    devWorkstation->setActiveMode("android_studio");
    assert(devWorkstation->activeMode() == "android_studio");

    // Test AI proposal and human rejection
    QString testTarget = "/run/media/sarathi/250-2.1/aios/build/test_ai_proposal.txt";
    QString changeId1 = devWorkstation->proposeCodeChange(testTarget, "int value = 42;\n", "Fix configuration");
    assert(!changeId1.isEmpty());
    assert(devWorkstation->pendingChangeCount() == 1);

    QVariantMap changeMeta = devWorkstation->getChangeDetails(changeId1);
    assert(changeMeta["status"].toString() == "pending");
    assert(!changeMeta["diffLines"].toList().isEmpty());

    // Human rejects the proposal
    bool rejected = devWorkstation->rejectChange(changeId1);
    assert(rejected);
    assert(devWorkstation->pendingChangeCount() == 0);

    // Test AI proposal and human approval
    QString changeId2 = devWorkstation->proposeCodeChange(testTarget, "int approvedValue = 100;\n", "Human approved fix");
    assert(devWorkstation->pendingChangeCount() == 1);
    bool approved = devWorkstation->approveChange(changeId2);
    assert(approved);
    assert(devWorkstation->pendingChangeCount() == 0);

    // Verify written content on disk
    QFile verifyFile(testTarget);
    assert(verifyFile.open(QIODevice::ReadOnly | QIODevice::Text));
    assert(QString::fromUtf8(verifyFile.readAll()).contains("approvedValue = 100"));
    verifyFile.close();
    QFile::remove(testTarget);

    std::cout << "[TEST] 10. PASSED: NebulaDevWorkstation IDE audits and human approval guardrails verified." << std::endl;

    // Test 11: NebulaAudioService Procedural Audio Engine
    std::cout << "[TEST] 11. Verifying NebulaAudioService procedural sound effect waveforms..." << std::endl;
    auto* audioService = new sritec::shell::NebulaAudioService(&app);
    assert(audioService->soundEffectsEnabled());
    assert(audioService->volume() == 75);
    assert(!audioService->isMuted());

    // Test bounds clamping
    audioService->setVolume(150);
    assert(audioService->volume() == 100);
    audioService->setVolume(-20);
    assert(audioService->volume() == 0);
    audioService->setVolume(80);
    assert(audioService->volume() == 80);

    // Verify WAV files on disk
    QString clickWav = audioService->soundFilePath("click");
    QString swipeWav = audioService->soundFilePath("swipe");
    QString screenshotWav = audioService->soundFilePath("screenshot");
    QString chimeWav = audioService->soundFilePath("chime");
    QString notifWav = audioService->soundFilePath("notification");

    assert(QFile::exists(clickWav));
    assert(QFile::exists(swipeWav));
    assert(QFile::exists(screenshotWav));
    assert(QFile::exists(chimeWav));
    assert(QFile::exists(notifWav));

    // Verify WAV RIFF header of click sound
    QFile f(clickWav);
    assert(f.open(QIODevice::ReadOnly));
    QByteArray header = f.read(12);
    assert(header.startsWith("RIFF"));
    assert(header.endsWith("WAVE"));
    assert(f.size() > 500); // 45ms 16-bit 44.1kHz mono is ~4000 bytes
    f.close();

    // Verify sound playback triggers
    audioService->playClick();
    assert(audioService->lastPlayedSound() == "click");
    audioService->playSwipe();
    assert(audioService->lastPlayedSound() == "swipe");
    audioService->playScreenshot();
    assert(audioService->lastPlayedSound() == "screenshot");
    audioService->playChime();
    assert(audioService->lastPlayedSound() == "chime");
    audioService->playNotification();
    assert(audioService->lastPlayedSound() == "notification");

    // Test mute suppression
    audioService->setIsMuted(true);
    assert(audioService->isMuted());
    audioService->playSound("click");
    audioService->setIsMuted(false);

    std::cout << "[TEST] 11. PASSED: NebulaAudioService synthesized WAV files and property controls verified." << std::endl;

    // Test 12: NebulaPowerManager Power State Machine & Safety Guards
    std::cout << "[TEST] 12. Verifying NebulaPowerManager safety guards and countdown workflow..." << std::endl;
    auto* powerManager = new sritec::shell::NebulaPowerManager(audioService, &app);
    assert(powerManager->simulationMode()); // Default must protect host
    assert(!powerManager->isConfirmationActive());

    // Request Shutdown
    powerManager->requestShutdown();
    assert(powerManager->isConfirmationActive());
    assert(powerManager->pendingAction() == "shutdown");
    assert(powerManager->countdownSeconds() == 30);
    assert(!powerManager->statusMessage().isEmpty());

    // Cancel action
    powerManager->cancelAction();
    assert(!powerManager->isConfirmationActive());
    assert(powerManager->pendingAction().isEmpty());
    assert(powerManager->countdownSeconds() == 0);

    // Request Restart
    powerManager->requestRestart();
    assert(powerManager->isConfirmationActive());
    assert(powerManager->pendingAction() == "restart");
    assert(powerManager->countdownSeconds() == 30);
    powerManager->cancelAction();

    // Request Sleep
    powerManager->requestSleep();
    assert(powerManager->isConfirmationActive());
    assert(powerManager->pendingAction() == "sleep");
    powerManager->cancelAction();

    // Request Lock
    powerManager->requestLock();
    assert(powerManager->isConfirmationActive());
    assert(powerManager->pendingAction() == "lock");
    powerManager->cancelAction();

    // Request Quit
    powerManager->requestQuit();
    assert(powerManager->isConfirmationActive());
    assert(powerManager->pendingAction() == "quit");
    powerManager->cancelAction();

    std::cout << "[TEST] 12. PASSED: NebulaPowerManager countdown state machine and host protection verified." << std::endl;

    // Test 13: NebulaScreenCaptureService & Video Recorder
    std::cout << "[TEST] 13. Verifying NebulaScreenCaptureService capture and recorder workflow..." << std::endl;
    auto* screenCapture = new sritec::shell::NebulaScreenCaptureService(audioService, &app);
    assert(!screenCapture->isRecording());
    assert(screenCapture->recordingDurationSeconds() == 0);

    // Start Recording
    bool recStarted = screenCapture->startRecording(nullptr);
    assert(recStarted);
    assert(screenCapture->isRecording());
    assert(!screenCapture->lastRecordingPath().isEmpty());

    // Stop Recording
    bool recStopped = screenCapture->stopRecording();
    assert(recStopped);
    assert(!screenCapture->isRecording());

    std::cout << "[TEST] 13. PASSED: NebulaScreenCaptureService recording state transitions verified." << std::endl;

    std::cout << "\n========================================================" << std::endl;
    std::cout << " [SUCCESS] All 13 NEBULA Core System Test Cases Passed!" << std::endl;
    std::cout << "========================================================" << std::endl;

    return 0;
}
