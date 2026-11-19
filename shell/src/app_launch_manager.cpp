#include "app_launch_manager.hpp"
#include "app_launcher.hpp"
#include "desktop_manager.hpp"
#include "sritec/logger.hpp"

#include <algorithm>

namespace sritec::shell {

AppLaunchManager::AppLaunchManager(AppLauncher* launcher, DesktopManager* desktopMgr, QObject* parent)
    : QObject(parent)
    , m_appLauncher(launcher)
    , m_desktopManager(desktopMgr)
{
    registerDefaultApps();
    sritec::Logger::instance().info("APP_LAUNCH", "NebulaAppRuntime & Universal Window Manager initialized.");
}

void AppLaunchManager::registerDefaultApps() {
    // =========================================================================
    // 1. NEBULA Internal Applications (Native QML/C++ Canvas)
    // =========================================================================
    m_registry["files"] = {
        "files", "Spatial Files", "System", "files", "internal",
        AppClassification::InternalNative, "#00E5FF", 960, 620,
        "Spatial filesystem navigator and neural file catalog", ""
    };

    m_registry["terminal"] = {
        "terminal", "Smart Terminal", "System", "terminal", "internal",
        AppClassification::InternalNative, "#00E5FF", 900, 560,
        "Sandboxed cyber command console with intelligent assistance", ""
    };

    m_registry["calculator"] = {
        "calculator", "Neural Calculator", "Utilities", "calculator", "internal",
        AppClassification::InternalNative, "#00E5FF", 460, 620,
        "High-precision scientific and neural mathematical engine", ""
    };

    m_registry["settings"] = {
        "settings", "System Settings", "System", "settings", "internal",
        AppClassification::InternalNative, "#8B5CF6", 960, 620,
        "Operating environment personalization, themes, and devices", ""
    };

    m_registry["monitor"] = {
        "monitor", "Hardware Diagnostics", "System", "monitor", "internal",
        AppClassification::InternalNative, "#00F5A0", 920, 580,
        "Real-time CPU, RAM, disk, and sensor telemetry monitor", ""
    };

    m_registry["calendar"] = {
        "calendar", "Chrono Hub", "Utilities", "calendar", "internal",
        AppClassification::InternalNative, "#00E5FF", 760, 520,
        "Temporal scheduling, task agenda, and system chronometer", ""
    };

    m_registry["editor"] = {
        "editor", "Code Studio", "Development", "code", "internal",
        AppClassification::InternalNative, "#3B82F6", 1020, 660,
        "Intelligent code editor, project explorer, and development workspace", ""
    };

    m_registry["robotics"] = {
        "robotics", "Robotics Ecosystem", "Robotics", "robotics", "internal",
        AppClassification::InternalNative, "#00E5FF", 1120, 680,
        "Multi-agent kinematics and autonomous robot simulation suite", ""
    };

    m_registry["assistant"] = {
        "assistant", "LISA AI Studio", "AI Engines", "assistant", "internal",
        AppClassification::InternalNative, "#00E5FF", 960, 640,
        "Conversational AI assistant and provider gateway hub", ""
    };

    // =========================================================================
    // 2. Embedded Web & AI Portals (Runs INSIDE NEBULA)
    // =========================================================================
    m_registry["browser"] = {
        "browser", "NEBULA Web & AI Portal", "Internet", "browser", "internal",
        AppClassification::EmbeddedWeb, "#00E5FF", 1100, 700,
        "Integrated multi-tabbed web portal and AI research workspace", ""
    };

    m_registry["chatgpt"] = {
        "chatgpt", "ChatGPT Portal", "AI Engines", "chatgpt", "internal",
        AppClassification::EmbeddedWeb, "#00F5A0", 1040, 680,
        "OpenAI conversational intelligence portal inside NEBULA", "assistant"
    };

    m_registry["gemini"] = {
        "gemini", "Google Gemini", "AI Engines", "gemini", "internal",
        AppClassification::EmbeddedWeb, "#00E5FF", 1040, 680,
        "Google multimodal neural assistant portal inside NEBULA", "assistant"
    };

    m_registry["claude"] = {
        "claude", "Anthropic Claude", "AI Engines", "claude", "internal",
        AppClassification::EmbeddedWeb, "#FFB800", 1040, 680,
        "Anthropic constitutional reasoning portal inside NEBULA", "assistant"
    };

    // =========================================================================
    // 3. Unsupported External Applications (Blocked from Detached Host Spawning)
    // =========================================================================
    m_registry["firefox"] = {
        "firefox", "Mozilla Firefox", "Internet", "firefox", "external",
        AppClassification::UnsupportedExternal, "#FF7700", 1100, 700,
        "External host browser", "browser"
    };

    m_registry["chrome"] = {
        "chrome", "Google Chrome", "Internet", "chrome", "external",
        AppClassification::UnsupportedExternal, "#00E5FF", 1100, 700,
        "External host browser", "browser"
    };

    m_registry["edge"] = {
        "edge", "Microsoft Edge", "Internet", "edge", "external",
        AppClassification::UnsupportedExternal, "#00F5A0", 1100, 700,
        "External host browser", "browser"
    };

    m_registry["opera"] = {
        "opera", "Opera Browser", "Internet", "opera", "external",
        AppClassification::UnsupportedExternal, "#FF3B5C", 1100, 700,
        "External host browser", "browser"
    };

    m_registry["vscode"] = {
        "vscode", "Visual Studio Code", "Development", "vscode", "external",
        AppClassification::UnsupportedExternal, "#3B82F6", 1160, 720,
        "External IDE", "editor"
    };

    m_registry["antigravity"] = {
        "antigravity", "Antigravity IDE", "Development", "antigravity", "external",
        AppClassification::UnsupportedExternal, "#8B5CF6", 1160, 720,
        "External agentic workspace", "editor"
    };

    m_registry["android_studio"] = {
        "android_studio", "Android Studio", "Development", "android_studio", "external",
        AppClassification::UnsupportedExternal, "#00F5A0", 1160, 720,
        "External Android SDK IDE", "editor"
    };

    m_registry["codex"] = {
        "codex", "OpenAI Codex", "AI Engines", "codex", "external",
        AppClassification::UnsupportedExternal, "#00E5FF", 1000, 680,
        "External code synthesis client", "editor"
    };

    m_registry["ollama"] = {
        "ollama", "Ollama Local AI", "AI Engines", "ai_core", "external",
        AppClassification::UnsupportedExternal, "#8B5CF6", 1000, 680,
        "Local open-weights neural runtime", "assistant"
    };
}

void AppLaunchManager::setAnimationDurationMs(int ms) {
    if (m_animationDurationMs != ms && ms >= 100 && ms <= 2000) {
        m_animationDurationMs = ms;
        emit animationDurationMsChanged();
    }
}

QVariantList AppLaunchManager::openWindows() const {
    QVariantList list;
    for (const auto& w : m_windows) {
        QVariantMap map;
        map["windowId"] = w.windowId;
        map["appId"] = w.appId;
        map["title"] = w.title;
        map["iconId"] = w.iconId;
        map["launchType"] = w.launchType;
        map["accentColor"] = w.accentColor;
        map["x"] = w.x;
        map["y"] = w.y;
        map["width"] = w.width;
        map["height"] = w.height;
        map["isMinimized"] = w.isMinimized;
        map["isMaximized"] = w.isMaximized;
        map["isFocused"] = w.isFocused;
        map["zOrder"] = w.zOrder;
        map["unsupportedNotice"] = w.unsupportedNotice;
        list.append(map);
    }
    return list;
}

int AppLaunchManager::activeWindowCount() const {
    int count = 0;
    for (const auto& w : m_windows) {
        if (!w.isMinimized) count++;
    }
    return count;
}

void AppLaunchManager::requestAppLaunch(const QString& appId, double originX, double originY, double originWidth, double originHeight) {
    sritec::Logger::instance().info("APP_LAUNCH", QString("Launch request for app '%1' from origin (%2, %3)").arg(appId).arg(originX).arg(originY).toStdString());

    // Record in DesktopManager recent apps
    if (m_desktopManager) {
        m_desktopManager->recordAppOpened(appId);
    }

    // Check if internal app is already running
    if (isAppRunning(appId)) {
        QString winId = getRunningWindowId(appId);
        restoreWindow(winId);
        focusWindow(winId);
        sritec::Logger::instance().info("APP_LAUNCH", QString("App '%1' already running; focused window '%2'.").arg(appId, winId).toStdString());
        return;
    }

    // Lookup metadata in registry
    AppLaunchEntry entry;
    if (m_registry.contains(appId)) {
        entry = m_registry[appId];
    } else {
        entry = {
            appId, appId, "Application", "ai_core", "external",
            AppClassification::UnsupportedExternal, "#00E5FF", 880, 560, "Application", ""
        };
    }

    // Default origin coordinates if not provided (screen center / dock center)
    double oX = (originX >= 0) ? originX : 960 - originWidth / 2.0;
    double oY = (originY >= 0) ? originY : 1000 - originHeight / 2.0;

    // Calculate target geometry with cascade offset
    double targetW = entry.defaultWidth;
    double targetH = entry.defaultHeight;
    double cascadeOffset = (m_windows.size() % 6) * 32.0;
    double targetX = std::max(60.0, (1920.0 - targetW) / 2.0 + cascadeOffset);
    double targetY = std::max(80.0, (1080.0 - targetH) / 2.0 - 40.0 + cascadeOffset);

    // Build transition descriptor
    m_activeTransition.clear();
    m_activeTransition["active"] = true;
    m_activeTransition["appId"] = appId;
    m_activeTransition["name"] = entry.name;
    m_activeTransition["category"] = entry.category;
    m_activeTransition["iconId"] = entry.iconId;
    m_activeTransition["launchType"] = entry.launchType;
    m_activeTransition["accentColor"] = entry.accentColor;
    m_activeTransition["originX"] = oX;
    m_activeTransition["originY"] = oY;
    m_activeTransition["originWidth"] = originWidth;
    m_activeTransition["originHeight"] = originHeight;
    m_activeTransition["targetX"] = targetX;
    m_activeTransition["targetY"] = targetY;
    m_activeTransition["targetWidth"] = targetW;
    m_activeTransition["targetHeight"] = targetH;
    m_activeTransition["durationMs"] = m_animationDurationMs;
    m_activeTransition["fallbackApp"] = entry.fallbackInternalApp;

    bool isSupported = (entry.classification != AppClassification::UnsupportedExternal);
    m_activeTransition["isSupported"] = isSupported;
    m_activeTransition["isAvailable"] = isSupported;

    m_isTransitionActive = true;
    m_transitionPhase = "burst";
    emit transitionStateChanged();
    emit appLaunchRequested(appId, m_activeTransition, oX, oY);
}

void AppLaunchManager::completeTransition(const QString& appId) {
    if (!m_isTransitionActive || m_activeTransition["appId"].toString() != appId) {
        return;
    }

    QString launchType = m_activeTransition["launchType"].toString();
    QString fallback = m_activeTransition["fallbackApp"].toString();

    if (launchType == "internal" || launchType == "embedded_web") {
        // Create live window state
        QString winId = generateWindowId(appId);
        AppWindowState win;
        win.windowId = winId;
        win.appId = appId;
        win.title = m_activeTransition["name"].toString();
        win.iconId = m_activeTransition["iconId"].toString();
        win.launchType = launchType;
        win.accentColor = m_activeTransition["accentColor"].toString();
        win.x = m_activeTransition["targetX"].toDouble();
        win.y = m_activeTransition["targetY"].toDouble();
        win.width = m_activeTransition["targetWidth"].toDouble();
        win.height = m_activeTransition["targetHeight"].toDouble();
        win.restoreX = win.x;
        win.restoreY = win.y;
        win.restoreWidth = win.width;
        win.restoreHeight = win.height;
        win.isMinimized = false;
        win.isMaximized = false;
        win.isFocused = true;
        win.zOrder = ++m_topZOrder;

        // Unfocus previous windows
        for (auto& w : m_windows) {
            w.isFocused = false;
        }

        m_windows.append(win);
        m_focusedWindowId = winId;

        m_isTransitionActive = false;
        m_transitionPhase = "idle";
        m_activeTransition.clear();

        emit openWindowsChanged();
        emit focusedWindowIdChanged();
        emit transitionStateChanged();
        emit windowOpened(winId, appId);
        emit appLaunchCompleted(appId, true);

        sritec::Logger::instance().info("APP_LAUNCH", QString("Internal window '%1' opened for app '%2'.").arg(winId, appId).toStdString());
    } else {
        // External / Unsupported Application Handling
        // Do NOT silently launch external host processes.
        // Keep the user safely inside NEBULA.
        QString appName = m_activeTransition["name"].toString();
        sritec::Logger::instance().info("APP_LAUNCH", QString("App '%1' is classified as unsupported external. Suppressing host window launch.").arg(appId).toStdString());

        m_unsupportedNotice.clear();
        m_unsupportedNotice["appId"] = appId;
        m_unsupportedNotice["name"] = appName;
        m_unsupportedNotice["message"] = QString("Application '%1' is not yet available inside NEBULA.").arg(appName);
        m_unsupportedNotice["details"] = "To maintain an immersive and secure operating environment, external host windows are prevented from opening detached.";
        m_unsupportedNotice["alternative"] = fallback;

        m_isTransitionActive = false;
        m_transitionPhase = "idle";
        m_activeTransition.clear();

        emit unsupportedNoticeChanged();
        emit unsupportedAppRequested(appId, appName, fallback);
        emit transitionStateChanged();
        emit appLaunchCompleted(appId, false);
    }
}

void AppLaunchManager::cancelTransition() {
    if (m_isTransitionActive) {
        m_isTransitionActive = false;
        m_transitionPhase = "idle";
        m_activeTransition.clear();
        emit transitionStateChanged();
    }
}

void AppLaunchManager::dismissUnsupportedNotice() {
    if (!m_unsupportedNotice.isEmpty()) {
        m_unsupportedNotice.clear();
        emit unsupportedNoticeChanged();
    }
}

void AppLaunchManager::closeWindow(const QString& windowId) {
    for (int i = 0; i < m_windows.size(); ++i) {
        if (m_windows[i].windowId == windowId) {
            QString appId = m_windows[i].appId;
            m_windows.removeAt(i);

            // Re-assign focus to next top window
            if (m_focusedWindowId == windowId) {
                m_focusedWindowId.clear();
                int highestZ = -1;
                for (const auto& w : m_windows) {
                    if (!w.isMinimized && w.zOrder > highestZ) {
                        highestZ = w.zOrder;
                        m_focusedWindowId = w.windowId;
                    }
                }
                if (!m_focusedWindowId.isEmpty()) {
                    auto* nextWin = findWindow(m_focusedWindowId);
                    if (nextWin) nextWin->isFocused = true;
                }
                emit focusedWindowIdChanged();
            }

            emit openWindowsChanged();
            emit windowClosed(windowId, appId);
            sritec::Logger::instance().info("APP_LAUNCH", QString("Window '%1' closed.").arg(windowId).toStdString());
            return;
        }
    }
}

void AppLaunchManager::minimizeWindow(const QString& windowId) {
    auto* win = findWindow(windowId);
    if (!win) return;

    win->isMinimized = true;
    win->isFocused = false;

    // Re-focus remaining visible window
    if (m_focusedWindowId == windowId) {
        m_focusedWindowId.clear();
        int highestZ = -1;
        for (const auto& w : m_windows) {
            if (!w.isMinimized && w.zOrder > highestZ) {
                highestZ = w.zOrder;
                m_focusedWindowId = w.windowId;
            }
        }
        if (!m_focusedWindowId.isEmpty()) {
            auto* nextWin = findWindow(m_focusedWindowId);
            if (nextWin) nextWin->isFocused = true;
        }
        emit focusedWindowIdChanged();
    }

    emit openWindowsChanged();
    emit windowMinimized(windowId);
}

void AppLaunchManager::restoreWindow(const QString& windowId) {
    auto* win = findWindow(windowId);
    if (!win) return;

    win->isMinimized = false;
    bringToFront(windowId);
    emit openWindowsChanged();
    emit windowRestored(windowId);
}

void AppLaunchManager::toggleMaximizeWindow(const QString& windowId) {
    auto* win = findWindow(windowId);
    if (!win) return;

    if (!win->isMaximized) {
        // Save restore geometry
        win->restoreX = win->x;
        win->restoreY = win->y;
        win->restoreWidth = win->width;
        win->restoreHeight = win->height;

        // Maximize to full spatial desktop area (excluding Top HUD and Dock)
        win->x = 0;
        win->y = 56;
        win->width = 1920;
        win->height = 1080 - 56 - 80;
        win->isMaximized = true;
    } else {
        win->x = win->restoreX;
        win->y = win->restoreY;
        win->width = win->restoreWidth;
        win->height = win->restoreHeight;
        win->isMaximized = false;
    }

    bringToFront(windowId);
    emit openWindowsChanged();
}

void AppLaunchManager::focusWindow(const QString& windowId) {
    bringToFront(windowId);
}

void AppLaunchManager::updateWindowGeometry(const QString& windowId, double x, double y, double width, double height) {
    auto* win = findWindow(windowId);
    if (!win) return;

    win->x = std::clamp(x, -width + 100.0, 1920.0 - 100.0);
    win->y = std::clamp(y, 48.0, 1080.0 - 80.0);
    win->width = std::max(400.0, std::min(1920.0, width));
    win->height = std::max(300.0, std::min(1080.0, height));
    win->isMaximized = false;

    emit openWindowsChanged();
}

void AppLaunchManager::cascadeWindows() {
    double startX = 120.0;
    double startY = 100.0;
    double step = 36.0;

    for (int i = 0; i < m_windows.size(); ++i) {
        m_windows[i].x = startX + (i * step);
        m_windows[i].y = startY + (i * step);
        m_windows[i].isMaximized = false;
        m_windows[i].isMinimized = false;
    }
    emit openWindowsChanged();
}

void AppLaunchManager::cycleNextWindow() {
    if (m_windows.size() <= 1) return;

    int curIdx = -1;
    for (int i = 0; i < m_windows.size(); ++i) {
        if (m_windows[i].windowId == m_focusedWindowId) {
            curIdx = i;
            break;
        }
    }

    int nextIdx = (curIdx + 1) % m_windows.size();
    restoreWindow(m_windows[nextIdx].windowId);
    focusWindow(m_windows[nextIdx].windowId);
}

bool AppLaunchManager::isAppRunning(const QString& appId) const {
    for (const auto& w : m_windows) {
        if (w.appId == appId) return true;
    }
    return false;
}

QString AppLaunchManager::getRunningWindowId(const QString& appId) const {
    for (const auto& w : m_windows) {
        if (w.appId == appId) return w.windowId;
    }
    return "";
}

QVariantMap AppLaunchManager::getAppRegistryEntry(const QString& appId) const {
    if (m_registry.contains(appId)) {
        const auto& e = m_registry[appId];
        QVariantMap map;
        map["id"] = e.id;
        map["name"] = e.name;
        map["category"] = e.category;
        map["iconId"] = e.iconId;
        map["launchType"] = e.launchType;
        map["accentColor"] = e.accentColor;
        map["defaultWidth"] = e.defaultWidth;
        map["defaultHeight"] = e.defaultHeight;
        map["description"] = e.description;
        map["fallbackApp"] = e.fallbackInternalApp;
        map["isSupported"] = (e.classification != AppClassification::UnsupportedExternal);
        return map;
    }
    return {};
}

QVariantList AppLaunchManager::getRegisteredApps() const {
    QVariantList list;
    for (const auto& e : m_registry) {
        QVariantMap map;
        map["id"] = e.id;
        map["name"] = e.name;
        map["category"] = e.category;
        map["iconId"] = e.iconId;
        map["launchType"] = e.launchType;
        map["accentColor"] = e.accentColor;
        map["description"] = e.description;
        map["fallbackApp"] = e.fallbackInternalApp;
        map["isSupported"] = (e.classification != AppClassification::UnsupportedExternal);
        list.append(map);
    }
    return list;
}

bool AppLaunchManager::isInternalApp(const QString& appId) const {
    if (m_registry.contains(appId)) {
        return m_registry[appId].launchType == "internal";
    }
    return false;
}

QString AppLaunchManager::getAppClassification(const QString& appId) const {
    if (m_registry.contains(appId)) {
        switch (m_registry[appId].classification) {
            case AppClassification::InternalNative: return "InternalNative";
            case AppClassification::EmbeddedWeb: return "EmbeddedWeb";
            case AppClassification::UnsupportedExternal: return "UnsupportedExternal";
        }
    }
    return "UnsupportedExternal";
}

bool AppLaunchManager::isAppSupported(const QString& appId) const {
    if (m_registry.contains(appId)) {
        return m_registry[appId].classification != AppClassification::UnsupportedExternal;
    }
    return false;
}

AppWindowState* AppLaunchManager::findWindow(const QString& windowId) {
    for (auto& w : m_windows) {
        if (w.windowId == windowId) return &w;
    }
    return nullptr;
}

const AppWindowState* AppLaunchManager::findWindow(const QString& windowId) const {
    for (const auto& w : m_windows) {
        if (w.windowId == windowId) return &w;
    }
    return nullptr;
}

QString AppLaunchManager::generateWindowId(const QString& appId) {
    return QString("win-%1-%2").arg(appId).arg(m_windowSequence++);
}

void AppLaunchManager::bringToFront(const QString& windowId) {
    auto* target = findWindow(windowId);
    if (!target) return;

    target->zOrder = ++m_topZOrder;
    target->isFocused = true;
    m_focusedWindowId = windowId;

    for (auto& w : m_windows) {
        if (w.windowId != windowId) {
            w.isFocused = false;
        }
    }

    emit openWindowsChanged();
    emit focusedWindowIdChanged();
    emit windowFocused(windowId);
}

} // namespace sritec::shell
