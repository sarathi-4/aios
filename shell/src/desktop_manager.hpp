#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QSettings>
#include <QMap>
#include <QVector>

namespace sritec::shell {

struct DesktopItem {
    QString id;
    QString name;
    QString type; // "app", "folder", "file"
    QString target; // appId or path
    int x{40};
    int y{40};
    QString icon;
};

struct NotificationItem {
    QString id;
    QString title;
    QString message;
    QString timestamp;
    QString type; // "info", "success", "warning", "security"
    QString icon;
};

class DesktopManager : public QObject {
    Q_OBJECT

    // Desktop Items
    Q_PROPERTY(QVariantList desktopItems READ desktopItems NOTIFY desktopItemsChanged)

    // Wallpaper & Appearance Settings
    Q_PROPERTY(QString wallpaperType READ wallpaperType WRITE setWallpaperType NOTIFY wallpaperTypeChanged)
    Q_PROPERTY(QString wallpaperPath READ wallpaperPath WRITE setWallpaperPath NOTIFY wallpaperPathChanged)
    Q_PROPERTY(QString wallpaperMode READ wallpaperMode WRITE setWallpaperMode NOTIFY wallpaperModeChanged)
    Q_PROPERTY(double wallpaperIntensity READ wallpaperIntensity WRITE setWallpaperIntensity NOTIFY wallpaperIntensityChanged)
    Q_PROPERTY(QString performanceMode READ performanceMode WRITE setPerformanceMode NOTIFY performanceModeChanged)
    Q_PROPERTY(QString accentColor READ accentColor WRITE setAccentColor NOTIFY accentColorChanged)
    Q_PROPERTY(double glassOpacity READ glassOpacity WRITE setGlassOpacity NOTIFY glassOpacityChanged)
    Q_PROPERTY(double fontScale READ fontScale WRITE setFontScale NOTIFY fontScaleChanged)

    // Dock Settings
    Q_PROPERTY(QString dockPosition READ dockPosition WRITE setDockPosition NOTIFY dockPositionChanged)
    Q_PROPERTY(QString dockSize READ dockSize WRITE setDockSize NOTIFY dockSizeChanged)
    Q_PROPERTY(bool dockAutoHide READ dockAutoHide WRITE setDockAutoHide NOTIFY dockAutoHideChanged)
    Q_PROPERTY(QStringList pinnedApps READ pinnedApps NOTIFY pinnedAppsChanged)
    Q_PROPERTY(QStringList recentApps READ recentApps NOTIFY recentAppsChanged)

    // Hardware & Quick Settings Telemetry (Real checks, no fake controls)
    Q_PROPERTY(bool hasBattery READ hasBattery NOTIFY hardwareTelemetryUpdated)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY hardwareTelemetryUpdated)
    Q_PROPERTY(bool isCharging READ isCharging NOTIFY hardwareTelemetryUpdated)
    Q_PROPERTY(QString batteryStatusText READ batteryStatusText NOTIFY hardwareTelemetryUpdated)

    Q_PROPERTY(bool hasBacklight READ hasBacklight NOTIFY hardwareTelemetryUpdated)
    Q_PROPERTY(int brightnessPercent READ brightnessPercent WRITE setBrightnessPercent NOTIFY brightnessPercentChanged)
    Q_PROPERTY(QString backlightStatusText READ backlightStatusText NOTIFY hardwareTelemetryUpdated)

    Q_PROPERTY(bool hasWifi READ hasWifi NOTIFY hardwareTelemetryUpdated)
    Q_PROPERTY(QString wifiStatusText READ wifiStatusText NOTIFY hardwareTelemetryUpdated)
    Q_PROPERTY(QString networkInterfaceName READ networkInterfaceName NOTIFY hardwareTelemetryUpdated)

    Q_PROPERTY(bool hasBluetooth READ hasBluetooth NOTIFY hardwareTelemetryUpdated)
    Q_PROPERTY(QString bluetoothStatusText READ bluetoothStatusText NOTIFY hardwareTelemetryUpdated)

    Q_PROPERTY(int audioVolume READ audioVolume WRITE setAudioVolume NOTIFY audioVolumeChanged)
    Q_PROPERTY(bool isMuted READ isMuted WRITE setIsMuted NOTIFY isMutedChanged)

    Q_PROPERTY(bool nightLightSupported READ nightLightSupported CONSTANT)
    Q_PROPERTY(bool nightLightEnabled READ nightLightEnabled WRITE setNightLightEnabled NOTIFY nightLightEnabledChanged)

    // Notifications
    Q_PROPERTY(QVariantList notifications READ notifications NOTIFY notificationsChanged)
    Q_PROPERTY(int unreadNotificationsCount READ unreadNotificationsCount NOTIFY notificationsChanged)
    Q_PROPERTY(bool doNotDisturb READ doNotDisturb WRITE setDoNotDisturb NOTIFY doNotDisturbChanged)

public:
    explicit DesktopManager(QObject* parent = nullptr);
    ~DesktopManager() override = default;

    // Getters
    QVariantList desktopItems() const;

    QString wallpaperType() const { return m_wallpaperType; }
    void setWallpaperType(const QString& val);

    QString wallpaperPath() const { return m_wallpaperPath; }
    void setWallpaperPath(const QString& val);

    QString wallpaperMode() const { return m_wallpaperMode; }
    void setWallpaperMode(const QString& val);

    double wallpaperIntensity() const { return m_wallpaperIntensity; }
    void setWallpaperIntensity(double val);

    QString performanceMode() const { return m_performanceMode; }
    void setPerformanceMode(const QString& val);

    QString accentColor() const { return m_accentColor; }
    void setAccentColor(const QString& val);

    double glassOpacity() const { return m_glassOpacity; }
    void setGlassOpacity(double val);

    double fontScale() const { return m_fontScale; }
    void setFontScale(double val);

    QString dockPosition() const { return m_dockPosition; }
    void setDockPosition(const QString& val);

    QString dockSize() const { return m_dockSize; }
    void setDockSize(const QString& val);

    bool dockAutoHide() const { return m_dockAutoHide; }
    void setDockAutoHide(bool val);

    QStringList pinnedApps() const { return m_pinnedApps; }
    QStringList recentApps() const { return m_recentApps; }

    bool hasBattery() const { return m_hasBattery; }
    int batteryPercent() const { return m_batteryPercent; }
    bool isCharging() const { return m_isCharging; }
    QString batteryStatusText() const { return m_batteryStatusText; }

    bool hasBacklight() const { return m_hasBacklight; }
    int brightnessPercent() const { return m_brightnessPercent; }
    void setBrightnessPercent(int val);
    QString backlightStatusText() const { return m_backlightStatusText; }

    bool hasWifi() const { return m_hasWifi; }
    QString wifiStatusText() const { return m_wifiStatusText; }
    QString networkInterfaceName() const { return m_netIface; }

    bool hasBluetooth() const { return m_hasBluetooth; }
    QString bluetoothStatusText() const { return m_bluetoothStatusText; }

    int audioVolume() const { return m_audioVolume; }
    void setAudioVolume(int val);

    bool isMuted() const { return m_isMuted; }
    void setIsMuted(bool val);

    bool nightLightSupported() const { return false; } // Not supported on raw X11/Wayland without compositor gamma
    bool nightLightEnabled() const { return m_nightLightEnabled; }
    void setNightLightEnabled(bool val);

    QVariantList notifications() const;
    int unreadNotificationsCount() const { return m_notifications.size(); }
    bool doNotDisturb() const { return m_doNotDisturb; }
    void setDoNotDisturb(bool val);

    // Invocables - Desktop Items
    Q_INVOKABLE void createFolder(const QString& name, int x = 40, int y = 40);
    Q_INVOKABLE void createShortcut(const QString& name, const QString& targetAppId, const QString& icon = "▣", int x = 40, int y = 40);
    Q_INVOKABLE void renameItem(const QString& id, const QString& newName);
    Q_INVOKABLE void removeItem(const QString& id);
    Q_INVOKABLE void updateItemPosition(const QString& id, int x, int y);
    Q_INVOKABLE void openItem(const QString& id);

    // Invocables - Dock
    Q_INVOKABLE void pinApp(const QString& appId);
    Q_INVOKABLE void unpinApp(const QString& appId);
    Q_INVOKABLE bool isAppPinned(const QString& appId) const;
    Q_INVOKABLE void recordAppOpened(const QString& appId);

    // Invocables - Notifications
    Q_INVOKABLE void addNotification(const QString& title, const QString& message, const QString& type = "info", const QString& icon = "ℹ");
    Q_INVOKABLE void clearNotification(const QString& id);
    Q_INVOKABLE void clearAllNotifications();

    // Invocables - Universal Search
    Q_INVOKABLE QVariantList universalSearch(const QString& query);

    // Invocables - System & Hardware Telemetry
    Q_INVOKABLE void refreshHardwareTelemetry();

    // Invocables - Reset Settings to Default
    Q_INVOKABLE void resetToDefaults();

signals:
    void desktopItemsChanged();
    void wallpaperTypeChanged();
    void wallpaperPathChanged();
    void wallpaperModeChanged();
    void wallpaperIntensityChanged();
    void performanceModeChanged();
    void accentColorChanged();
    void glassOpacityChanged();
    void fontScaleChanged();
    void dockPositionChanged();
    void dockSizeChanged();
    void dockAutoHideChanged();
    void pinnedAppsChanged();
    void recentAppsChanged();
    void hardwareTelemetryUpdated();
    void brightnessPercentChanged();
    void audioVolumeChanged();
    void isMutedChanged();
    void nightLightEnabledChanged();
    void notificationsChanged();
    void doNotDisturbChanged();
    void itemOpened(const QString& type, const QString& target);

private:
    void loadSettings();
    void saveSettings();
    void loadDefaultDesktopItems();
    void detectHardwareCapabilities();

    // State
    QVector<DesktopItem> m_desktopItems;
    QVector<NotificationItem> m_notifications;

    QString m_wallpaperType{"procedural"};
    QString m_wallpaperPath{""};
    QString m_wallpaperMode{"fill"};
    double m_wallpaperIntensity{0.85};
    QString m_performanceMode{"Balanced"};
    QString m_accentColor{"#00E5FF"};
    double m_glassOpacity{0.85};
    double m_fontScale{1.0};

    QString m_dockPosition{"bottom"};
    QString m_dockSize{"medium"};
    bool m_dockAutoHide{false};
    QStringList m_pinnedApps{"terminal", "browser", "files", "editor", "calculator", "settings"};
    QStringList m_recentApps;

    bool m_hasBattery{false};
    int m_batteryPercent{-1};
    bool m_isCharging{false};
    QString m_batteryStatusText{"Desktop AC Power (No Battery Detected)"};

    bool m_hasBacklight{false};
    int m_brightnessPercent{100};
    QString m_backlightStatusText{"Not Supported (External Desktop Display)"};

    bool m_hasWifi{false};
    QString m_wifiStatusText{"Not Supported (Using Wired Ethernet eno1)"};
    QString m_netIface{"eno1"};

    bool m_hasBluetooth{false};
    QString m_bluetoothStatusText{"Not Supported (No Bluetooth Adapter)"};

    int m_audioVolume{75};
    bool m_isMuted{false};
    bool m_nightLightEnabled{false};
    bool m_doNotDisturb{false};
};

} // namespace sritec::shell
