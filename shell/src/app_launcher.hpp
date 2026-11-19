#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QMap>
#include <QProcess>

namespace sritec::shell {

struct AppMetadata {
    QString id;
    QString name;
    QString description;
    QString category; // "Internet", "Development", "AI Engines", "System", "Utilities"
    QString icon;
    QStringList binaryCandidates;
    QString verifiedPath;
    bool isAvailable{false};
};

class AppLauncher : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList installedApps READ installedApps NOTIFY availableAppIdsChanged)
    Q_PROPERTY(QStringList availableAppIds READ availableAppIds NOTIFY availableAppIdsChanged)
    Q_PROPERTY(QString lastLaunchedApp READ lastLaunchedApp NOTIFY lastLaunchedAppChanged)
    Q_PROPERTY(QString lastLaunchError READ lastLaunchError NOTIFY lastLaunchErrorChanged)
    Q_PROPERTY(int cpuUsagePercent READ cpuUsagePercent NOTIFY telemetryUpdated)
    Q_PROPERTY(int ramUsagePercent READ ramUsagePercent NOTIFY telemetryUpdated)
    Q_PROPERTY(int diskUsagePercent READ diskUsagePercent NOTIFY telemetryUpdated)
    Q_PROPERTY(QString hostKernel READ hostKernel CONSTANT)
    Q_PROPERTY(QString hostDistro READ hostDistro CONSTANT)

public:
    explicit AppLauncher(QObject* parent = nullptr);
    ~AppLauncher() override = default;

    QVariantList installedApps() const;
    QStringList availableAppIds() const;
    QString lastLaunchedApp() const { return m_lastLaunchedApp; }
    QString lastLaunchError() const { return m_lastLaunchError; }

    int cpuUsagePercent() const { return m_cpuPercent; }
    int ramUsagePercent() const { return m_ramPercent; }
    int diskUsagePercent() const { return m_diskPercent; }

    QString hostKernel() const { return m_hostKernel; }
    QString hostDistro() const { return m_hostDistro; }

    Q_INVOKABLE bool launch(const QString& appId);
    Q_INVOKABLE bool isAvailable(const QString& appId) const;
    Q_INVOKABLE QString getAppName(const QString& appId) const;
    Q_INVOKABLE QString getAppDescription(const QString& appId) const;
    Q_INVOKABLE QString getAppIcon(const QString& appId) const;
    Q_INVOKABLE QString getAppBinary(const QString& appId) const;

    Q_INVOKABLE void refreshTelemetry();
    Q_INVOKABLE QString getSystemDiagnostics();

signals:
    void availableAppIdsChanged();
    void lastLaunchedAppChanged();
    void lastLaunchErrorChanged();
    void telemetryUpdated();
    void appLaunched(const QString& appId, bool success);

private:
    void registerCatalog();
    void probeAvailableBinaries();
    void sampleTelemetry();

    QMap<QString, AppMetadata> m_catalog;
    QString m_lastLaunchedApp;
    QString m_lastLaunchError;

    int m_cpuPercent{18};
    int m_ramPercent{42};
    int m_diskPercent{36};
    QString m_hostKernel{"Linux 7.0 (x86_64)"};
    QString m_hostDistro{"Ubuntu 26.04 LTS (Resolute)"};

    unsigned long long m_prevIdleTime{0};
    unsigned long long m_prevTotalTime{0};
};

} // namespace sritec::shell
