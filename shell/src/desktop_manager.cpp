#include "desktop_manager.hpp"
#include "app_launcher.hpp"
#include "sritec/logger.hpp"

#include <QDateTime>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QTextStream>
#include <QProcess>
#include <QFileInfoList>
#include <QUuid>
#include <QStandardPaths>

namespace sritec::shell {

DesktopManager::DesktopManager(QObject* parent)
    : QObject(parent)
{
    loadSettings();
    detectHardwareCapabilities();

    // Default notifications to populate notification drawer
    addNotification("SRITEC AI OS Initialized", "Welcome to NEBULA Desktop Environment v0.2.2.", "info", "✦");
    addNotification("Security Perimeter Active", "Strict unprivileged user sandbox enforced.", "security", "⛨");
    addNotification("Neural Gateway Ready", "Local Mock and Multi-Cloud providers configured.", "success", "🧠");
}

void DesktopManager::loadSettings() {
    QSettings settings("SRITEC", "NEBULA");

    m_wallpaperType = settings.value("appearance/wallpaperType", "image").toString();
    m_wallpaperPath = settings.value("appearance/wallpaperPath", "qrc:/resources/images/wallpapers/ai_robotics_wallpaper.jpg").toString();
    if (m_wallpaperPath.isEmpty()) {
        m_wallpaperPath = "qrc:/resources/images/wallpapers/ai_robotics_wallpaper.jpg";
    }
    m_wallpaperMode = settings.value("appearance/wallpaperMode", "fill").toString();
    m_wallpaperIntensity = settings.value("appearance/wallpaperIntensity", 0.85).toReal();
    m_performanceMode = settings.value("appearance/performanceMode", "Balanced").toString();
    m_accentColor = settings.value("appearance/accentColor", "#00E5FF").toString();
    m_glassOpacity = settings.value("appearance/glassOpacity", 0.85).toReal();
    m_fontScale = settings.value("appearance/fontScale", 1.0).toReal();

    m_dockPosition = settings.value("dock/position", "bottom").toString();
    m_dockSize = settings.value("dock/size", "medium").toString();
    m_dockAutoHide = settings.value("dock/autoHide", false).toBool();

    QStringList savedPinned = settings.value("dock/pinnedApps").toStringList();
    if (!savedPinned.isEmpty()) {
        m_pinnedApps = savedPinned;
    }

    m_recentApps = settings.value("dock/recentApps").toStringList();

    // Load Desktop items
    int itemCount = settings.beginReadArray("desktop/items");
    if (itemCount >= 8) {
        m_desktopItems.clear();
        for (int i = 0; i < itemCount; ++i) {
            settings.setArrayIndex(i);
            DesktopItem item;
            item.id = settings.value("id").toString();
            item.name = settings.value("name").toString();
            item.type = settings.value("type").toString();
            item.target = settings.value("target").toString();
            item.x = settings.value("x").toInt();
            item.y = settings.value("y").toInt();
            item.icon = settings.value("icon").toString();
            m_desktopItems.append(item);
        }
        settings.endArray();
    } else {
        settings.endArray();
        loadDefaultDesktopItems();
    }
}

void DesktopManager::saveSettings() {
    QSettings settings("SRITEC", "NEBULA");

    settings.setValue("appearance/wallpaperType", m_wallpaperType);
    settings.setValue("appearance/wallpaperPath", m_wallpaperPath);
    settings.setValue("appearance/wallpaperMode", m_wallpaperMode);
    settings.setValue("appearance/wallpaperIntensity", m_wallpaperIntensity);
    settings.setValue("appearance/performanceMode", m_performanceMode);
    settings.setValue("appearance/accentColor", m_accentColor);
    settings.setValue("appearance/glassOpacity", m_glassOpacity);
    settings.setValue("appearance/fontScale", m_fontScale);

    settings.setValue("dock/position", m_dockPosition);
    settings.setValue("dock/size", m_dockSize);
    settings.setValue("dock/autoHide", m_dockAutoHide);
    settings.setValue("dock/pinnedApps", m_pinnedApps);
    settings.setValue("dock/recentApps", m_recentApps);

    // Save Desktop items
    settings.beginWriteArray("desktop/items", m_desktopItems.size());
    for (int i = 0; i < m_desktopItems.size(); ++i) {
        settings.setArrayIndex(i);
        settings.setValue("id", m_desktopItems[i].id);
        settings.setValue("name", m_desktopItems[i].name);
        settings.setValue("type", m_desktopItems[i].type);
        settings.setValue("target", m_desktopItems[i].target);
        settings.setValue("x", m_desktopItems[i].x);
        settings.setValue("y", m_desktopItems[i].y);
        settings.setValue("icon", m_desktopItems[i].icon);
    }
    settings.endArray();
    settings.sync();
}

void DesktopManager::loadDefaultDesktopItems() {
    m_desktopItems.clear();

    QString home = QDir::homePath();
    QString downloads = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    QString docs = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    // Column 1: System, Home, Drives & Places
    m_desktopItems.append({"item-comp", "Computer", "folder", "/", 40, 40, "💻"});
    m_desktopItems.append({"item-home", "Home", "folder", home, 40, 150, "🏠"});
    m_desktopItems.append({"item-ssd", "SSD 250-2.1", "folder", "/run/media/sarathi/250-2.1/aios", 40, 260, "💽"});
    m_desktopItems.append({"item-drive1tb", "1TB Storage", "folder", "/media/sarathi/1tb", 40, 370, "💾"});
    m_desktopItems.append({"item-docs", "Documents", "folder", docs, 40, 480, "📁"});
    m_desktopItems.append({"item-trash", "Trash", "folder", home + "/.local/share/Trash/files", 40, 590, "🗑"});

    // Column 2: Applications & Workspaces
    m_desktopItems.append({"item-web", "Web Browser", "app", "browser", 150, 40, "🌐"});
    m_desktopItems.append({"item-editor", "Code Studio", "app", "editor", 150, 150, "💻"});
    m_desktopItems.append({"item-files", "File Manager", "app", "files", 150, 260, "📁"});
    m_desktopItems.append({"item-term", "Smart Terminal", "app", "terminal", 150, 370, "⌨"});
    m_desktopItems.append({"item-dl", "Downloads", "folder", downloads, 150, 480, "📥"});
    m_desktopItems.append({"item-calc", "Calculator", "app", "calculator", 150, 590, "🖩"});

    saveSettings();
}

void DesktopManager::detectHardwareCapabilities() {
    // 1. Battery detection
    QDir powerSupplyDir("/sys/class/power_supply");
    QStringList batteries = powerSupplyDir.entryList(QStringList() << "BAT*", QDir::Dirs | QDir::NoDotAndDotDot);
    if (!batteries.isEmpty()) {
        m_hasBattery = true;
        QString batPath = "/sys/class/power_supply/" + batteries.first();
        QFile capFile(batPath + "/capacity");
        if (capFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            m_batteryPercent = capFile.readLine().trimmed().toInt();
            capFile.close();
        }
        QFile statusFile(batPath + "/status");
        if (statusFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QString status = statusFile.readLine().trimmed();
            m_isCharging = (status == "Charging");
            statusFile.close();
            m_batteryStatusText = QString("%1% (%2)").arg(m_batteryPercent).arg(status);
        }
    } else {
        m_hasBattery = false;
        m_batteryPercent = -1;
        m_isCharging = false;
        m_batteryStatusText = "Desktop AC Power (No Battery Detected)";
    }

    // 2. Backlight detection
    QDir backlightDir("/sys/class/backlight");
    QStringList backlights = backlightDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    if (!backlights.isEmpty()) {
        m_hasBacklight = true;
        m_backlightStatusText = "Hardware Backlight Active";
    } else {
        m_hasBacklight = false;
        m_brightnessPercent = 100;
        m_backlightStatusText = "Not Supported (External Desktop Display)";
    }

    // 3. Network detection
    QDir netDir("/sys/class/net");
    QStringList netEntries = netDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    m_hasWifi = false;
    for (const QString& iface : netEntries) {
        if (iface.startsWith("wl")) {
            m_hasWifi = true;
            m_wifiStatusText = QString("Wi-Fi Interface Detected (%1)").arg(iface);
            m_netIface = iface;
            break;
        }
    }
    if (!m_hasWifi) {
        m_wifiStatusText = "Not Supported (Using Wired Ethernet eno1)";
        m_netIface = "eno1";
    }

    // 4. Bluetooth detection
    QDir btDir("/sys/class/bluetooth");
    m_hasBluetooth = !btDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot).isEmpty();
    if (!m_hasBluetooth) {
        m_bluetoothStatusText = "Not Supported (No Bluetooth Adapter Detected)";
    } else {
        m_bluetoothStatusText = "Bluetooth Radio Active";
    }

    emit hardwareTelemetryUpdated();
}

QVariantList DesktopManager::desktopItems() const {
    QVariantList list;
    for (const auto& item : m_desktopItems) {
        QVariantMap map;
        map["id"] = item.id;
        map["name"] = item.name;
        map["type"] = item.type;
        map["target"] = item.target;
        map["x"] = item.x;
        map["y"] = item.y;
        map["icon"] = item.icon;
        list.append(map);
    }
    return list;
}

void DesktopManager::setWallpaperType(const QString& val) {
    if (m_wallpaperType != val) {
        m_wallpaperType = val;
        saveSettings();
        emit wallpaperTypeChanged();
    }
}

void DesktopManager::setWallpaperPath(const QString& val) {
    if (m_wallpaperPath != val) {
        m_wallpaperPath = val;
        saveSettings();
        emit wallpaperPathChanged();
    }
}

void DesktopManager::setWallpaperMode(const QString& val) {
    if (m_wallpaperMode != val) {
        m_wallpaperMode = val;
        saveSettings();
        emit wallpaperModeChanged();
    }
}

void DesktopManager::setWallpaperIntensity(double val) {
    if (m_wallpaperIntensity != val) {
        m_wallpaperIntensity = val;
        saveSettings();
        emit wallpaperIntensityChanged();
    }
}

void DesktopManager::setPerformanceMode(const QString& val) {
    if (m_performanceMode != val) {
        m_performanceMode = val;
        saveSettings();
        emit performanceModeChanged();
    }
}

void DesktopManager::setAccentColor(const QString& val) {
    if (m_accentColor != val) {
        m_accentColor = val;
        saveSettings();
        emit accentColorChanged();
    }
}

void DesktopManager::setGlassOpacity(double val) {
    if (m_glassOpacity != val) {
        m_glassOpacity = val;
        saveSettings();
        emit glassOpacityChanged();
    }
}

void DesktopManager::setFontScale(double val) {
    if (m_fontScale != val) {
        m_fontScale = val;
        saveSettings();
        emit fontScaleChanged();
    }
}

void DesktopManager::setDockPosition(const QString& val) {
    if (m_dockPosition != val) {
        m_dockPosition = val;
        saveSettings();
        emit dockPositionChanged();
    }
}

void DesktopManager::setDockSize(const QString& val) {
    if (m_dockSize != val) {
        m_dockSize = val;
        saveSettings();
        emit dockSizeChanged();
    }
}

void DesktopManager::setDockAutoHide(bool val) {
    if (m_dockAutoHide != val) {
        m_dockAutoHide = val;
        saveSettings();
        emit dockAutoHideChanged();
    }
}

void DesktopManager::setBrightnessPercent(int val) {
    if (m_brightnessPercent != val) {
        m_brightnessPercent = qBound(10, val, 100);
        emit brightnessPercentChanged();
    }
}

void DesktopManager::setAudioVolume(int val) {
    if (m_audioVolume != val) {
        m_audioVolume = qBound(0, val, 100);
        emit audioVolumeChanged();
    }
}

void DesktopManager::setIsMuted(bool val) {
    if (m_isMuted != val) {
        m_isMuted = val;
        emit isMutedChanged();
    }
}

void DesktopManager::setNightLightEnabled(bool val) {
    if (m_nightLightEnabled != val) {
        m_nightLightEnabled = val;
        emit nightLightEnabledChanged();
    }
}

void DesktopManager::setDoNotDisturb(bool val) {
    if (m_doNotDisturb != val) {
        m_doNotDisturb = val;
        emit doNotDisturbChanged();
    }
}

// Invocables - Desktop Items
void DesktopManager::createFolder(const QString& name, int x, int y) {
    QString folderName = name.trimmed().isEmpty() ? "New Folder" : name.trimmed();
    QString id = "folder-" + QUuid::createUuid().toString(QUuid::WithoutBraces).left(8);
    m_desktopItems.append({id, folderName, "folder", QDir::homePath() + "/" + folderName, x, y, "📁"});
    saveSettings();
    emit desktopItemsChanged();
    sritec::Logger::instance().info("DESKTOP", QString("Created folder item '%1'").arg(folderName).toStdString());
}

void DesktopManager::createShortcut(const QString& name, const QString& targetAppId, const QString& icon, int x, int y) {
    QString id = "shortcut-" + QUuid::createUuid().toString(QUuid::WithoutBraces).left(8);
    m_desktopItems.append({id, name, "app", targetAppId, x, y, icon});
    saveSettings();
    emit desktopItemsChanged();
}

void DesktopManager::renameItem(const QString& id, const QString& newName) {
    for (auto& item : m_desktopItems) {
        if (item.id == id) {
            item.name = newName.trimmed();
            saveSettings();
            emit desktopItemsChanged();
            return;
        }
    }
}

void DesktopManager::removeItem(const QString& id) {
    for (int i = 0; i < m_desktopItems.size(); ++i) {
        if (m_desktopItems[i].id == id) {
            m_desktopItems.removeAt(i);
            saveSettings();
            emit desktopItemsChanged();
            return;
        }
    }
}

void DesktopManager::updateItemPosition(const QString& id, int x, int y) {
    for (auto& item : m_desktopItems) {
        if (item.id == id) {
            item.x = x;
            item.y = y;
            saveSettings();
            emit desktopItemsChanged();
            return;
        }
    }
}

void DesktopManager::openItem(const QString& id) {
    for (const auto& item : m_desktopItems) {
        if (item.id == id) {
            if (item.type == "app") {
                recordAppOpened(item.target);
            } else if (item.type == "folder") {
                QProcess::startDetached("nautilus", QStringList() << item.target);
            }
            emit itemOpened(item.type, item.target);
            return;
        }
    }
}

void DesktopManager::pinApp(const QString& appId) {
    if (!m_pinnedApps.contains(appId)) {
        m_pinnedApps.append(appId);
        saveSettings();
        emit pinnedAppsChanged();
    }
}

void DesktopManager::unpinApp(const QString& appId) {
    if (m_pinnedApps.contains(appId)) {
        m_pinnedApps.removeAll(appId);
        saveSettings();
        emit pinnedAppsChanged();
    }
}

bool DesktopManager::isAppPinned(const QString& appId) const {
    return m_pinnedApps.contains(appId);
}

void DesktopManager::recordAppOpened(const QString& appId) {
    m_recentApps.removeAll(appId);
    m_recentApps.prepend(appId);
    if (m_recentApps.size() > 8) {
        m_recentApps.removeLast();
    }
    saveSettings();
    emit recentAppsChanged();
}

QVariantList DesktopManager::notifications() const {
    QVariantList list;
    for (const auto& n : m_notifications) {
        QVariantMap map;
        map["id"] = n.id;
        map["title"] = n.title;
        map["message"] = n.message;
        map["timestamp"] = n.timestamp;
        map["type"] = n.type;
        map["icon"] = n.icon;
        list.append(map);
    }
    return list;
}

void DesktopManager::addNotification(const QString& title, const QString& message, const QString& type, const QString& icon) {
    if (m_doNotDisturb && type != "security") {
        return;
    }

    NotificationItem item;
    item.id = "notif-" + QUuid::createUuid().toString(QUuid::WithoutBraces).left(8);
    item.title = title;
    item.message = message;
    item.timestamp = QDateTime::currentDateTime().toString("hh:mm AP");
    item.type = type;
    item.icon = icon;

    m_notifications.prepend(item);
    if (m_notifications.size() > 20) {
        m_notifications.removeLast();
    }
    emit notificationsChanged();
}

void DesktopManager::clearNotification(const QString& id) {
    for (int i = 0; i < m_notifications.size(); ++i) {
        if (m_notifications[i].id == id) {
            m_notifications.removeAt(i);
            emit notificationsChanged();
            return;
        }
    }
}

void DesktopManager::clearAllNotifications() {
    m_notifications.clear();
    emit notificationsChanged();
}

QVariantList DesktopManager::universalSearch(const QString& query) {
    QVariantList results;
    QString q = query.trimmed().toLower();
    if (q.isEmpty()) {
        return results;
    }

    // 1. Search Known Applications
    static const QList<QPair<QString, QStringList>> appData = {
        {"terminal", {"Smart Terminal", "Terminal Console", "ptyxis", "bash", "command", "shell", "⌨", "System"}},
        {"browser", {"Web Portal", "Firefox Browser", "internet", "web", "chrome", "edge", "🌐", "Internet"}},
        {"files", {"File Manager", "Nautilus File Explorer", "folders", "storage", "disk", "📁", "System"}},
        {"editor", {"Code Studio", "Text Editor", "gnome-text-editor", "code", "dev", "💻", "Development"}},
        {"calculator", {"Neural Calculator", "GNOME Calculator", "math", "numbers", "calc", "🖩", "Utilities"}},
        {"settings", {"System Settings", "Control Center", "preferences", "config", "theme", "⚙", "System"}},
        {"monitor", {"System Monitor", "Hardware Sensor", "cpu", "ram", "processes", "📊", "System"}}
    };

    for (const auto& [appId, details] : appData) {
        bool matches = false;
        for (const QString& kw : details) {
            if (kw.toLower().contains(q)) {
                matches = true;
                break;
            }
        }
        if (matches) {
            QVariantMap res;
            res["title"] = details[0];
            res["subtitle"] = details[1];
            res["category"] = "Application (" + details[7] + ")";
            res["type"] = "app";
            res["targetId"] = appId;
            res["icon"] = details[6];
            results.append(res);
        }
    }

    // 2. Search Desktop Items
    for (const auto& item : m_desktopItems) {
        if (item.name.toLower().contains(q)) {
            QVariantMap res;
            res["title"] = item.name;
            res["subtitle"] = "Desktop Shortcut (" + item.type + ")";
            res["category"] = "Desktop";
            res["type"] = item.type;
            res["targetId"] = item.target;
            res["icon"] = item.icon;
            results.append(res);
        }
    }

    // 3. Search Project Workspace Files (`aios`)
    QDir projectDir("/run/media/sarathi/250-2.1/aios");
    if (!projectDir.exists()) {
        projectDir = QDir::current();
    }
    if (projectDir.exists()) {
        QStringList fileFilters;
        fileFilters << QString("*%1*").arg(query.trimmed());
        QDirIterator it(projectDir.absolutePath(), fileFilters,
                        QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot,
                        QDirIterator::Subdirectories);
        int added = 0;
        while (it.hasNext() && added < 10) {
            it.next();
            QFileInfo fi = it.fileInfo();
            // Ignore build and git folders
            if (fi.absoluteFilePath().contains("/build/") || fi.absoluteFilePath().contains("/.git/")) {
                continue;
            }
            QVariantMap res;
            res["title"] = fi.fileName();
            res["subtitle"] = fi.absoluteFilePath();
            res["category"] = fi.isDir() ? "Project Directory" : "Project File";
            res["type"] = fi.isDir() ? "folder" : "file";
            res["targetId"] = fi.absoluteFilePath();
            res["icon"] = fi.isDir() ? "📁" : "📄";
            results.append(res);
            added++;
        }
    }

    return results;
}

void DesktopManager::refreshHardwareTelemetry() {
    detectHardwareCapabilities();
}

void DesktopManager::resetToDefaults() {
    m_wallpaperType = "procedural";
    m_wallpaperPath = "";
    m_wallpaperMode = "fill";
    m_wallpaperIntensity = 0.85;
    m_performanceMode = "Balanced";
    m_accentColor = "#00E5FF";
    m_glassOpacity = 0.85;
    m_fontScale = 1.0;
    m_dockPosition = "bottom";
    m_dockSize = "medium";
    m_dockAutoHide = false;
    m_pinnedApps = {"terminal", "browser", "files", "editor", "calculator", "settings"};
    m_doNotDisturb = false;

    loadDefaultDesktopItems();
    saveSettings();

    emit wallpaperTypeChanged();
    emit wallpaperPathChanged();
    emit wallpaperModeChanged();
    emit wallpaperIntensityChanged();
    emit performanceModeChanged();
    emit accentColorChanged();
    emit glassOpacityChanged();
    emit fontScaleChanged();
    emit dockPositionChanged();
    emit dockSizeChanged();
    emit dockAutoHideChanged();
    emit pinnedAppsChanged();
    emit doNotDisturbChanged();
}

} // namespace sritec::shell
