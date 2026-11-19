#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QMap>
#include <QVector>
#include <QDateTime>

namespace sritec::shell {

class AppLauncher;
class DesktopManager;

enum class AppClassification {
    InternalNative,        // Native NEBULA view (files, terminal, editor, etc.)
    EmbeddedWeb,           // Embedded Web & AI portals (browser, chatgpt, gemini, claude)
    UnsupportedExternal    // Unsupported external host apps (blocked to keep user inside NEBULA)
};

struct AppLaunchEntry {
    QString id;
    QString name;
    QString category; // "System", "Development", "Internet", "AI Engines", "Utilities", "Robotics"
    QString iconId;
    QString launchType; // "internal", "embedded_web", "unsupported", "external"
    AppClassification classification{AppClassification::InternalNative};
    QString accentColor;
    int defaultWidth{940};
    int defaultHeight{600};
    QString description;
    QString fallbackInternalApp; // Suggested alternative inside NEBULA
};

struct AppWindowState {
    QString windowId;
    QString appId;
    QString title;
    QString iconId;
    QString launchType;
    QString accentColor;
    double x{120};
    double y{100};
    double width{940};
    double height{600};
    bool isMinimized{false};
    bool isMaximized{false};
    bool isFocused{true};
    int zOrder{10};
    double restoreX{120};
    double restoreY{100};
    double restoreWidth{940};
    double restoreHeight{600};
    QString unsupportedNotice;
};

// ==============================================================================
// NebulaAppRuntime & Window Manager
// ==============================================================================
class AppLaunchManager : public QObject {
    Q_OBJECT

    // Transition State Properties
    Q_PROPERTY(bool isTransitionActive READ isTransitionActive NOTIFY transitionStateChanged)
    Q_PROPERTY(QString transitionPhase READ transitionPhase NOTIFY transitionStateChanged)
    Q_PROPERTY(QVariantMap activeTransition READ activeTransition NOTIFY transitionStateChanged)
    Q_PROPERTY(int animationDurationMs READ animationDurationMs WRITE setAnimationDurationMs NOTIFY animationDurationMsChanged)

    // Window Management Properties
    Q_PROPERTY(QVariantList openWindows READ openWindows NOTIFY openWindowsChanged)
    Q_PROPERTY(QString focusedWindowId READ focusedWindowId NOTIFY focusedWindowIdChanged)
    Q_PROPERTY(int activeWindowCount READ activeWindowCount NOTIFY openWindowsChanged)

    // Unsupported App Notification
    Q_PROPERTY(bool hasUnsupportedNotice READ hasUnsupportedNotice NOTIFY unsupportedNoticeChanged)
    Q_PROPERTY(QVariantMap unsupportedAppNotice READ unsupportedAppNotice NOTIFY unsupportedNoticeChanged)

public:
    explicit AppLaunchManager(AppLauncher* launcher = nullptr, DesktopManager* desktopMgr = nullptr, QObject* parent = nullptr);
    ~AppLaunchManager() override = default;

    bool isTransitionActive() const { return m_isTransitionActive; }
    QString transitionPhase() const { return m_transitionPhase; }
    QVariantMap activeTransition() const { return m_activeTransition; }
    int animationDurationMs() const { return m_animationDurationMs; }
    void setAnimationDurationMs(int ms);

    QVariantList openWindows() const;
    QString focusedWindowId() const { return m_focusedWindowId; }
    int activeWindowCount() const;

    bool hasUnsupportedNotice() const { return !m_unsupportedNotice.isEmpty(); }
    QVariantMap unsupportedAppNotice() const { return m_unsupportedNotice; }

    // Public Invokables for QML & Native Launch
    Q_INVOKABLE void requestAppLaunch(const QString& appId, double originX = -1, double originY = -1, double originWidth = 48, double originHeight = 48);
    Q_INVOKABLE void completeTransition(const QString& appId);
    Q_INVOKABLE void cancelTransition();
    Q_INVOKABLE void dismissUnsupportedNotice();

    // Window Control Operations
    Q_INVOKABLE void closeWindow(const QString& windowId);
    Q_INVOKABLE void minimizeWindow(const QString& windowId);
    Q_INVOKABLE void restoreWindow(const QString& windowId);
    Q_INVOKABLE void toggleMaximizeWindow(const QString& windowId);
    Q_INVOKABLE void focusWindow(const QString& windowId);
    Q_INVOKABLE void updateWindowGeometry(const QString& windowId, double x, double y, double width, double height);
    Q_INVOKABLE void cascadeWindows();
    Q_INVOKABLE void cycleNextWindow();

    // Queries & Classifications
    Q_INVOKABLE bool isAppRunning(const QString& appId) const;
    Q_INVOKABLE QString getRunningWindowId(const QString& appId) const;
    Q_INVOKABLE QVariantMap getAppRegistryEntry(const QString& appId) const;
    Q_INVOKABLE QVariantList getRegisteredApps() const;
    Q_INVOKABLE bool isInternalApp(const QString& appId) const;
    Q_INVOKABLE QString getAppClassification(const QString& appId) const;
    Q_INVOKABLE bool isAppSupported(const QString& appId) const;

signals:
    void transitionStateChanged();
    void animationDurationMsChanged();
    void openWindowsChanged();
    void focusedWindowIdChanged();
    void unsupportedNoticeChanged();

    void appLaunchRequested(const QString& appId, const QVariantMap& meta, double originX, double originY);
    void appLaunchCompleted(const QString& appId, bool success);
    void windowOpened(const QString& windowId, const QString& appId);
    void windowClosed(const QString& windowId, const QString& appId);
    void windowMinimized(const QString& windowId);
    void windowRestored(const QString& windowId);
    void windowFocused(const QString& windowId);
    void unsupportedAppRequested(const QString& appId, const QString& appName, const QString& alternative);

private:
    void registerDefaultApps();
    AppWindowState* findWindow(const QString& windowId);
    const AppWindowState* findWindow(const QString& windowId) const;
    QString generateWindowId(const QString& appId);
    void bringToFront(const QString& windowId);

    AppLauncher* m_appLauncher{nullptr};
    DesktopManager* m_desktopManager{nullptr};

    QMap<QString, AppLaunchEntry> m_registry;
    QVector<AppWindowState> m_windows;

    bool m_isTransitionActive{false};
    QString m_transitionPhase{"idle"}; // "idle", "burst", "expanding", "loading", "handoff", "success", "failed"
    QVariantMap m_activeTransition;
    int m_animationDurationMs{650};

    QString m_focusedWindowId;
    int m_windowSequence{1};
    int m_topZOrder{100};

    QVariantMap m_unsupportedNotice;
};

// Synonym / Architecture typedef for Milestone 3.4
using NebulaAppRuntime = AppLaunchManager;
using NebulaWindowManager = AppLaunchManager;

} // namespace sritec::shell
