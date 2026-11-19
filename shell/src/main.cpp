#include "sritec/common.hpp"
#include "sritec/logger.hpp"
#include "sritec/ai/ai_bridge.hpp"
#include "app_launcher.hpp"
#include "app_launch_manager.hpp"
#include "desktop_manager.hpp"
#include "nebula_file_manager.hpp"
#include "nebula_terminal_backend.hpp"
#include "nebula_dev_workspace.hpp"
#include "nebula_browser_backend.hpp"
#include "nebula_dev_workstation.hpp"
#include "nebula_audio_service.hpp"
#include "nebula_screen_capture_service.hpp"
#include "nebula_power_manager.hpp"
#include "core/jarvis_engine.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QTimer>
#include <QFileInfo>
#include <QDir>

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);

    // Parse command line arguments
    QString screenshotPath;
    QString screenshotDrawerPath;
    QString screenshotRoboticsPath;
    QString screenshotTransitionPath;
    QString screenshotWindowsPath;
    QString screenshotBrowserPath;
    QString screenshotStudioPath;
    QString screenshotFilesPath;
    QString screenshotWorkstationPath;
    QString screenshotPowerPath;
    QString screenshotJarvisPath;

    for (int i = 1; i < argc; ++i) {
        if (QString(argv[i]) == "--screenshot" && i + 1 < argc) {
            screenshotPath = QString::fromUtf8(argv[i + 1]);
        } else if (QString(argv[i]) == "--screenshot-drawer" && i + 1 < argc) {
            screenshotDrawerPath = QString::fromUtf8(argv[i + 1]);
        } else if (QString(argv[i]) == "--screenshot-robotics" && i + 1 < argc) {
            screenshotRoboticsPath = QString::fromUtf8(argv[i + 1]);
        } else if (QString(argv[i]) == "--screenshot-transition" && i + 1 < argc) {
            screenshotTransitionPath = QString::fromUtf8(argv[i + 1]);
        } else if (QString(argv[i]) == "--screenshot-windows" && i + 1 < argc) {
            screenshotWindowsPath = QString::fromUtf8(argv[i + 1]);
        } else if (QString(argv[i]) == "--screenshot-browser" && i + 1 < argc) {
            screenshotBrowserPath = QString::fromUtf8(argv[i + 1]);
        } else if (QString(argv[i]) == "--screenshot-studio" && i + 1 < argc) {
            screenshotStudioPath = QString::fromUtf8(argv[i + 1]);
        } else if (QString(argv[i]) == "--screenshot-files" && i + 1 < argc) {
            screenshotFilesPath = QString::fromUtf8(argv[i + 1]);
        } else if (QString(argv[i]) == "--screenshot-workstation" && i + 1 < argc) {
            screenshotWorkstationPath = QString::fromUtf8(argv[i + 1]);
        } else if (QString(argv[i]) == "--screenshot-power" && i + 1 < argc) {
            screenshotPowerPath = QString::fromUtf8(argv[i + 1]);
        } else if (QString(argv[i]) == "--screenshot-jarvis" && i + 1 < argc) {
            screenshotJarvisPath = QString::fromUtf8(argv[i + 1]);
        }
    }

    app.setApplicationName("SRITEC AI OS");
    app.setApplicationVersion(QString::fromUtf8(sritec::OS_VERSION.data(), sritec::OS_VERSION.size()));
    app.setOrganizationName("SRITEC");
    app.setOrganizationDomain("sritec.internal");

    QQuickStyle::setStyle("Basic");

    sritec::Logger::instance().info("MAIN", "Initializing SRITEC AI OS Digital Workspace v0.1");

    // Register C++ Types for QML instantiation or property access
    qmlRegisterType<sritec::ai::AIBridge>("sritec.ai", 1, 0, "AIBridge");
    qmlRegisterType<sritec::shell::AppLauncher>("sritec.shell", 1, 0, "AppLauncher");
    qmlRegisterType<sritec::shell::AppLaunchManager>("sritec.shell", 1, 0, "AppLaunchManager");
    qmlRegisterType<sritec::shell::DesktopManager>("sritec.shell", 1, 0, "DesktopManager");
    qmlRegisterType<sritec::shell::NebulaFileManager>("sritec.shell", 1, 0, "NebulaFileManager");
    qmlRegisterType<sritec::shell::NebulaTerminalBackend>("sritec.shell", 1, 0, "NebulaTerminalBackend");
    qmlRegisterType<sritec::shell::NebulaDevWorkspace>("sritec.shell", 1, 0, "NebulaDevWorkspace");
    qmlRegisterType<sritec::shell::NebulaBrowserBackend>("sritec.shell", 1, 0, "NebulaBrowserBackend");
    qmlRegisterType<sritec::shell::NebulaDevWorkstation>("sritec.shell", 1, 0, "NebulaDevWorkstation");
    qmlRegisterType<sritec::shell::NebulaAudioService>("sritec.shell", 1, 0, "NebulaAudioService");
    qmlRegisterType<sritec::shell::NebulaScreenCaptureService>("sritec.shell", 1, 0, "NebulaScreenCaptureService");
    qmlRegisterType<sritec::shell::NebulaPowerManager>("sritec.shell", 1, 0, "NebulaPowerManager");
    qmlRegisterType<sritec::jarvis::JarvisEngine>("sritec.jarvis", 1, 0, "JarvisEngine");

    // Register SRITECTheme singleton
    qmlRegisterSingletonType(
        QUrl(QStringLiteral("qrc:/qml/theme/SRITECTheme.qml")),
        "sritec.theme",
        1,
        0,
        "SRITECTheme"
    );

    QQmlApplicationEngine engine;

    // Add QRC search paths for module resolution
    engine.addImportPath(QStringLiteral("qrc:/"));
    engine.addImportPath(QStringLiteral("qrc:/qml"));

    // Create shared instances
    auto* aiBridge = new sritec::ai::AIBridge(&app);
    auto* appLauncher = new sritec::shell::AppLauncher(&app);
    auto* desktopManager = new sritec::shell::DesktopManager(&app);
    auto* appLaunchManager = new sritec::shell::AppLaunchManager(appLauncher, desktopManager, &app);
    auto* fileManager = new sritec::shell::NebulaFileManager(&app);
    auto* terminalBackend = new sritec::shell::NebulaTerminalBackend(&app);
    auto* devWorkspace = new sritec::shell::NebulaDevWorkspace(&app);
    auto* browserBackend = new sritec::shell::NebulaBrowserBackend(&app);
    auto* devWorkstation = new sritec::shell::NebulaDevWorkstation(&app);
    auto* audioService = new sritec::shell::NebulaAudioService(&app);
    auto* screenCapture = new sritec::shell::NebulaScreenCaptureService(audioService, &app);
    auto* powerManager = new sritec::shell::NebulaPowerManager(audioService, &app);
    auto* jarvisEngine = new sritec::jarvis::JarvisEngine(appLaunchManager, appLauncher, desktopManager, aiBridge, &app);

    QObject::connect(desktopManager, &sritec::shell::DesktopManager::itemOpened,
                     [appLaunchManager](const QString& type, const QString& target) {
        if (type == "app") {
            appLaunchManager->requestAppLaunch(target);
        }
    });

    engine.rootContext()->setContextProperty("globalAIBridge", aiBridge);
    engine.rootContext()->setContextProperty("globalAppLauncher", appLauncher);
    engine.rootContext()->setContextProperty("globalDesktopManager", desktopManager);
    engine.rootContext()->setContextProperty("globalAppLaunchManager", appLaunchManager);
    engine.rootContext()->setContextProperty("globalNebulaRuntime", appLaunchManager);
    engine.rootContext()->setContextProperty("globalFileManager", fileManager);
    engine.rootContext()->setContextProperty("globalTerminalBackend", terminalBackend);
    engine.rootContext()->setContextProperty("globalDevWorkspace", devWorkspace);
    engine.rootContext()->setContextProperty("globalBrowserBackend", browserBackend);
    engine.rootContext()->setContextProperty("globalDevWorkstation", devWorkstation);
    engine.rootContext()->setContextProperty("globalAudioService", audioService);
    engine.rootContext()->setContextProperty("globalScreenCapture", screenCapture);
    engine.rootContext()->setContextProperty("globalPowerManager", powerManager);
    engine.rootContext()->setContextProperty("globalJarvis", jarvisEngine);

    engine.rootContext()->setContextProperty("OS_NAME", QString::fromUtf8(sritec::OS_NAME.data(), sritec::OS_NAME.size()));
    engine.rootContext()->setContextProperty("OS_VERSION", QString::fromUtf8(sritec::OS_VERSION.data(), sritec::OS_VERSION.size()));
    engine.rootContext()->setContextProperty("OS_CODENAME", QString::fromUtf8(sritec::OS_CODENAME.data(), sritec::OS_CODENAME.size()));

    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject* obj, const QUrl& objUrl) {
            if (!obj && url == objUrl) {
                sritec::Logger::instance().error("MAIN", "Failed to load QML scene root.");
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection
    );

    engine.load(url);

    if (!screenshotPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated desktop screenshot scheduled for %1").arg(screenshotPath).toStdString());
        QTimer::singleShot(1000, [&engine, screenshotPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);
                    QTimer::singleShot(800, [win, screenshotPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("UI Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    if (!screenshotDrawerPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated drawer screenshot scheduled for %1").arg(screenshotDrawerPath).toStdString());
        QTimer::singleShot(1200, [&engine, screenshotDrawerPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);
                    auto* drawer = win->findChild<QObject*>("appDrawer");
                    if (drawer) {
                        QMetaObject::invokeMethod(drawer, "openDrawer");
                    }
                    QTimer::singleShot(600, [win, screenshotDrawerPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotDrawerPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotDrawerPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("App Drawer Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotDrawerPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    if (!screenshotRoboticsPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated robotics workspace screenshot scheduled for %1").arg(screenshotRoboticsPath).toStdString());
        QTimer::singleShot(1200, [&engine, screenshotRoboticsPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);
                    auto* stack = win->findChild<QObject*>("workspaceStack");
                    if (stack) {
                        stack->setProperty("currentIndex", 6);
                    }
                    QTimer::singleShot(800, [win, screenshotRoboticsPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotRoboticsPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotRoboticsPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("Robotics Workspace Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotRoboticsPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    if (!screenshotTransitionPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated app launch transition screenshot scheduled for %1").arg(screenshotTransitionPath).toStdString());
        QTimer::singleShot(1000, [&engine, appLaunchManager, screenshotTransitionPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);
                    appLaunchManager->requestAppLaunch("files", 100.0, 240.0, 48.0, 48.0);
                    QTimer::singleShot(240, [win, screenshotTransitionPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotTransitionPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotTransitionPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("App Launch Transition Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotTransitionPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    if (!screenshotWindowsPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated multi-window experience screenshot scheduled for %1").arg(screenshotWindowsPath).toStdString());
        QTimer::singleShot(1000, [&engine, appLaunchManager, screenshotWindowsPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);

                    // Open three simultaneous floating internal windows
                    appLaunchManager->requestAppLaunch("files", 100.0, 200.0, 48.0, 48.0);
                    appLaunchManager->completeTransition("files");

                    appLaunchManager->requestAppLaunch("terminal", 400.0, 300.0, 48.0, 48.0);
                    appLaunchManager->completeTransition("terminal");

                    appLaunchManager->requestAppLaunch("browser", 1000.0, 180.0, 48.0, 48.0);
                    appLaunchManager->completeTransition("browser");

                    // Set distinct cascade geometries
                    appLaunchManager->updateWindowGeometry(appLaunchManager->getRunningWindowId("files"), 80.0, 100.0, 780.0, 520.0);
                    appLaunchManager->updateWindowGeometry(appLaunchManager->getRunningWindowId("terminal"), 580.0, 220.0, 760.0, 480.0);
                    appLaunchManager->updateWindowGeometry(appLaunchManager->getRunningWindowId("browser"), 940.0, 120.0, 920.0, 580.0);

                    // Focus the Browser
                    appLaunchManager->focusWindow(appLaunchManager->getRunningWindowId("browser"));

                    QTimer::singleShot(800, [win, screenshotWindowsPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotWindowsPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotWindowsPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("Multi-Window Experience Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotWindowsPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    if (!screenshotBrowserPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated browser screenshot scheduled for %1").arg(screenshotBrowserPath).toStdString());
        QTimer::singleShot(1000, [&engine, appLaunchManager, screenshotBrowserPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);

                    appLaunchManager->requestAppLaunch("browser", 500.0, 400.0, 48.0, 48.0);
                    appLaunchManager->completeTransition("browser");
                    appLaunchManager->updateWindowGeometry(appLaunchManager->getRunningWindowId("browser"), 180.0, 90.0, 1560.0, 860.0);

                    QTimer::singleShot(800, [win, screenshotBrowserPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotBrowserPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotBrowserPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("Browser Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotBrowserPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    if (!screenshotStudioPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated code studio screenshot scheduled for %1").arg(screenshotStudioPath).toStdString());
        QTimer::singleShot(1000, [&engine, appLaunchManager, screenshotStudioPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);

                    appLaunchManager->requestAppLaunch("editor", 500.0, 400.0, 48.0, 48.0);
                    appLaunchManager->completeTransition("editor");
                    appLaunchManager->updateWindowGeometry(appLaunchManager->getRunningWindowId("editor"), 160.0, 80.0, 1600.0, 880.0);

                    QTimer::singleShot(800, [win, screenshotStudioPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotStudioPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotStudioPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("Code Studio Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotStudioPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    if (!screenshotFilesPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated file manager screenshot scheduled for %1").arg(screenshotFilesPath).toStdString());
        QTimer::singleShot(1000, [&engine, appLaunchManager, screenshotFilesPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);

                    appLaunchManager->requestAppLaunch("files", 500.0, 400.0, 48.0, 48.0);
                    appLaunchManager->completeTransition("files");
                    appLaunchManager->updateWindowGeometry(appLaunchManager->getRunningWindowId("files"), 160.0, 80.0, 1600.0, 880.0);

                    QTimer::singleShot(800, [win, screenshotFilesPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotFilesPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotFilesPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("File Manager Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotFilesPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    if (!screenshotWorkstationPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated AI Developer Workstation screenshot scheduled for %1").arg(screenshotWorkstationPath).toStdString());
        QTimer::singleShot(1200, [&engine, screenshotWorkstationPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);
                    auto* stack = win->findChild<QObject*>("workspaceStack");
                    if (stack) {
                        stack->setProperty("currentIndex", 2); // Workspace 2 is Developer Workspace
                    }
                    QTimer::singleShot(800, [win, screenshotWorkstationPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotWorkstationPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotWorkstationPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("AI Developer Workstation Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotWorkstationPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    if (!screenshotPowerPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated Power Control Modal screenshot scheduled for %1").arg(screenshotPowerPath).toStdString());
        QTimer::singleShot(1000, [&engine, powerManager, screenshotPowerPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);
                    powerManager->requestShutdown();
                    QTimer::singleShot(800, [win, screenshotPowerPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotPowerPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotPowerPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("Power Modal Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotPowerPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    if (!screenshotJarvisPath.isEmpty()) {
        sritec::Logger::instance().info("MAIN", QString("Automated JARVIS HUD screenshot scheduled for %1").arg(screenshotJarvisPath).toStdString());
        QTimer::singleShot(1000, [&engine, jarvisEngine, screenshotJarvisPath, &app]() {
            const auto rootObjects = engine.rootObjects();
            if (!rootObjects.isEmpty()) {
                auto* win = qobject_cast<QQuickWindow*>(rootObjects.first());
                if (win) {
                    win->showNormal();
                    win->resize(1920, 1080);
                    jarvisEngine->setActive(true);
                    jarvisEngine->startListening();
                    QTimer::singleShot(800, [win, screenshotJarvisPath, &app]() {
                        QImage img = win->grabWindow();
                        QFileInfo fi(screenshotJarvisPath);
                        QDir().mkpath(fi.absolutePath());
                        bool saved = img.save(screenshotJarvisPath, "PNG");
                        sritec::Logger::instance().info("MAIN", QString("JARVIS HUD Framebuffer saved to %1 (%2x%3): %4")
                            .arg(screenshotJarvisPath)
                            .arg(img.width())
                            .arg(img.height())
                            .arg(saved ? "SUCCESS" : "FAILED").toStdString());
                        app.quit();
                    });
                    return;
                }
            }
            app.quit();
        });
    }

    return app.exec();
}
