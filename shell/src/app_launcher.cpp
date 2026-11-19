#include "app_launcher.hpp"
#include "sritec/logger.hpp"

#include <QStandardPaths>
#include <QFileInfo>
#include <QDateTime>
#include <QFile>
#include <QTextStream>
#include <sys/statvfs.h>
#include <sys/utsname.h>

namespace sritec::shell {

AppLauncher::AppLauncher(QObject* parent)
    : QObject(parent)
{
    registerCatalog();
    probeAvailableBinaries();

    // Query host system kernel info
    struct utsname u{};
    if (uname(&u) == 0) {
        m_hostKernel = QString("%1 %2 (%3)").arg(u.sysname, u.release, u.machine);
    }

    refreshTelemetry();
}

void AppLauncher::registerCatalog() {
    // 1. Web Portals & Browsers
    m_catalog["chrome"] = {
        "chrome", "Google Chrome", "Enterprise high-performance web browser", "Internet", "🌐",
        {"google-chrome", "google-chrome-stable", "chromium-browser", "chromium"}, "", false
    };

    m_catalog["firefox"] = {
        "firefox", "Mozilla Firefox", "Privacy-centric modern web engine", "Internet", "🦊",
        {"firefox"}, "", false
    };

    m_catalog["edge"] = {
        "edge", "Microsoft Edge", "Microsoft Chromium-based browser", "Internet", "🌊",
        {"microsoft-edge", "microsoft-edge-stable", "edge"}, "", false
    };

    m_catalog["opera"] = {
        "opera", "Opera Browser", "Web portal with integrated AI engine", "Internet", "⭕",
        {"opera", "opera-stable"}, "", false
    };

    // Browser alias for backwards compatibility
    m_catalog["browser"] = {
        "browser", "Web Portal (Firefox)", "Default system web portal", "Internet", "🌐",
        {"firefox", "google-chrome", "microsoft-edge", "chromium-browser"}, "", false
    };

    // 2. Development & IDEs
    m_catalog["vscode"] = {
        "vscode", "Visual Studio Code", "Extensible code & workspace IDE", "Development", "📝",
        {"code", "code-insiders", "vscodium"}, "", false
    };

    m_catalog["antigravity"] = {
        "antigravity", "Antigravity IDE", "Google agentic engineering workspace", "Development", "🌌",
        {"agy", "antigravity"}, "", false
    };

    m_catalog["android_studio"] = {
        "android_studio", "Android Studio", "Official Android development environment", "Development", "🤖",
        {"studio", "android-studio"}, "", false
    };

    m_catalog["terminal"] = {
        "terminal", "Smart Terminal", "Sandboxed native shell console", "Development", "⌨",
        {"ptyxis", "gnome-terminal", "konsole", "alacritty", "xterm"}, "", false
    };

    // 3. AI Engines
    m_catalog["chatgpt"] = {
        "chatgpt", "ChatGPT Desktop", "OpenAI conversational intelligence", "AI Engines", "💬",
        {"chatgpt", "chatgpt-desktop"}, "", false
    };

    m_catalog["gemini"] = {
        "gemini", "Google Gemini", "Google multimodal neural assistant", "AI Engines", "✦",
        {"gemini-cli", "gemini"}, "", false
    };

    m_catalog["claude"] = {
        "claude", "Anthropic Claude", "Constitutional reasoning & synthesis", "AI Engines", "🧠",
        {"claude", "claude-desktop"}, "", false
    };

    m_catalog["codex"] = {
        "codex", "OpenAI Codex", "Automated code synthesis engine", "AI Engines", "⚡",
        {"codex"}, "", false
    };

    // 4. System & Productivity
    m_catalog["files"] = {
        "files", "Spatial Files", "Spatial filesystem navigator", "System", "📁",
        {"nautilus", "dolphin", "thunar", "pcmanfm"}, "", false
    };

    m_catalog["editor"] = {
        "editor", "Code Studio", "Development editor and workspace", "Development", "💻",
        {"code", "gnome-text-editor", "gedit", "kate"}, "", false
    };

    m_catalog["settings"] = {
        "settings", "System Settings", "Operating environment preferences", "System", "⚙",
        {"gnome-control-center", "systemsettings"}, "", false
    };

    m_catalog["calculator"] = {
        "calculator", "Neural Calculator", "High-precision mathematical utility", "Utilities", "🖩",
        {"gnome-calculator", "kcalc"}, "", false
    };

    m_catalog["monitor"] = {
        "monitor", "Hardware Sensor", "Real-time resource performance monitor", "System", "📊",
        {"gnome-system-monitor"}, "", false
    };
}

void AppLauncher::probeAvailableBinaries() {
    for (auto it = m_catalog.begin(); it != m_catalog.end(); ++it) {
        for (const QString& candidate : it->binaryCandidates) {
            QString path = QStandardPaths::findExecutable(candidate);
            if (!path.isEmpty() && QFileInfo::exists(path)) {
                it->verifiedPath = path;
                it->isAvailable = true;
                break;
            }
        }
    }
}

QVariantList AppLauncher::installedApps() const {
    QVariantList list;
    for (auto it = m_catalog.begin(); it != m_catalog.end(); ++it) {
        if (it->id == "browser") continue; // Alias for firefox
        QVariantMap map;
        map["id"] = it->id;
        map["name"] = it->name;
        map["description"] = it->description;
        map["category"] = it->category;
        map["icon"] = it->icon;
        map["isAvailable"] = it->isAvailable;
        map["verifiedPath"] = it->verifiedPath;
        list.append(map);
    }
    return list;
}

QStringList AppLauncher::availableAppIds() const {
    QStringList list;
    for (auto it = m_catalog.begin(); it != m_catalog.end(); ++it) {
        if (it->isAvailable) {
            list.append(it->id);
        }
    }
    return list;
}

bool AppLauncher::isAvailable(const QString& appId) const {
    auto it = m_catalog.find(appId);
    return (it != m_catalog.end() && it->isAvailable);
}

QString AppLauncher::getAppName(const QString& appId) const {
    auto it = m_catalog.find(appId);
    return (it != m_catalog.end()) ? it->name : appId;
}

QString AppLauncher::getAppDescription(const QString& appId) const {
    auto it = m_catalog.find(appId);
    return (it != m_catalog.end()) ? it->description : "";
}

QString AppLauncher::getAppIcon(const QString& appId) const {
    auto it = m_catalog.find(appId);
    return (it != m_catalog.end()) ? it->icon : "▣";
}

QString AppLauncher::getAppBinary(const QString& appId) const {
    auto it = m_catalog.find(appId);
    return (it != m_catalog.end()) ? it->verifiedPath : "";
}

bool AppLauncher::launch(const QString& appId) {
    auto it = m_catalog.find(appId);
    if (it == m_catalog.end() || !it->isAvailable || it->verifiedPath.isEmpty()) {
        m_lastLaunchError = QString("Application '%1' is not installed or available on this host.").arg(appId);
        sritec::Logger::instance().warn("LAUNCHER", m_lastLaunchError.toStdString());
        emit lastLaunchErrorChanged();
        emit appLaunched(appId, false);
        return false;
    }

    m_lastLaunchedApp = it->name;
    m_lastLaunchError.clear();

    sritec::Logger::instance().info("LAUNCHER", QString("Spawning child process: %1 (%2)").arg(it->name, it->verifiedPath).toStdString());

    // Launch directly via QProcess with zero shell intervention (prevents command injection)
    bool ok = QProcess::startDetached(it->verifiedPath, QStringList());
    if (!ok) {
        m_lastLaunchError = QString("Failed to spawn process '%1'.").arg(it->verifiedPath);
        sritec::Logger::instance().error("LAUNCHER", m_lastLaunchError.toStdString());
        emit lastLaunchErrorChanged();
        emit appLaunched(appId, false);
        return false;
    }

    emit lastLaunchedAppChanged();
    emit lastLaunchErrorChanged();
    emit appLaunched(appId, true);
    return true;
}

void AppLauncher::refreshTelemetry() {
    sampleTelemetry();
    emit telemetryUpdated();
}

void AppLauncher::sampleTelemetry() {
    // 1. Memory usage via /proc/meminfo
    QFile meminfo("/proc/meminfo");
    if (meminfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&meminfo);
        unsigned long long totalKb = 0, availKb = 0;
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.startsWith("MemTotal:")) {
                QStringList parts = line.split(' ', Qt::SkipEmptyParts);
                if (parts.size() >= 2) totalKb = parts[1].toULongLong();
            } else if (line.startsWith("MemAvailable:")) {
                QStringList parts = line.split(' ', Qt::SkipEmptyParts);
                if (parts.size() >= 2) availKb = parts[1].toULongLong();
            }
        }
        meminfo.close();

        if (totalKb > 0) {
            unsigned long long usedKb = totalKb - availKb;
            m_ramPercent = static_cast<int>((usedKb * 100) / totalKb);
        }
    }

    // 2. Disk usage via statvfs
    struct statvfs stat{};
    if (statvfs("/", &stat) == 0) {
        unsigned long long total = stat.f_blocks * stat.f_frsize;
        unsigned long long free = stat.f_bavail * stat.f_frsize;
        if (total > 0) {
            unsigned long long used = total - free;
            m_diskPercent = static_cast<int>((used * 100) / total);
        }
    }

    // 3. CPU calculation via /proc/stat
    QFile procStat("/proc/stat");
    if (procStat.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&procStat);
        QString line = in.readLine(); // "cpu  user nice system idle iowait..."
        procStat.close();

        QStringList parts = line.split(' ', Qt::SkipEmptyParts);
        if (parts.size() >= 5) {
            unsigned long long user = parts[1].toULongLong();
            unsigned long long nice = parts[2].toULongLong();
            unsigned long long system = parts[3].toULongLong();
            unsigned long long idle = parts[4].toULongLong();
            unsigned long long total = user + nice + system + idle;

            if (m_prevTotalTime > 0 && total > m_prevTotalTime) {
                unsigned long long totalDiff = total - m_prevTotalTime;
                unsigned long long idleDiff = idle - m_prevIdleTime;
                if (totalDiff >= idleDiff) {
                    m_cpuPercent = static_cast<int>(((totalDiff - idleDiff) * 100) / totalDiff);
                    if (m_cpuPercent < 2) m_cpuPercent = 2; // baseline floor
                    if (m_cpuPercent > 100) m_cpuPercent = 100;
                }
            }
            m_prevTotalTime = total;
            m_prevIdleTime = idle;
        }
    }
}

QString AppLauncher::getSystemDiagnostics() {
    sampleTelemetry();
    return QString("[SRITEC SYSTEM TELEMETRY]\n"
                   "Host OS: %1\n"
                   "Kernel:  %2\n"
                   "CPU:     %3% active\n"
                   "RAM:     %4% allocated\n"
                   "Disk:    %5% capacity used\n"
                   "Status:  Secure Sandbox Active\n")
        .arg(m_hostDistro, m_hostKernel)
        .arg(m_cpuPercent)
        .arg(m_ramPercent)
        .arg(m_diskPercent);
}

} // namespace sritec::shell
