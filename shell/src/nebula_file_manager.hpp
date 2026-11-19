#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QFileInfo>
#include <QDir>
#include <QDateTime>

namespace sritec::shell {

class NebulaFileManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString currentPath READ currentPath WRITE setCurrentPath NOTIFY currentPathChanged)
    Q_PROPERTY(QVariantList directoryEntries READ directoryEntries NOTIFY directoryEntriesChanged)
    Q_PROPERTY(QVariantList pathBreadcrumbs READ pathBreadcrumbs NOTIFY pathBreadcrumbsChanged)
    Q_PROPERTY(QVariantList places READ places NOTIFY placesChanged)
    Q_PROPERTY(QVariantList drives READ drives NOTIFY drivesChanged)
    Q_PROPERTY(int totalItemCount READ totalItemCount NOTIFY directoryEntriesChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(bool isReadOnly READ isReadOnly NOTIFY isReadOnlyChanged)

public:
    explicit NebulaFileManager(QObject* parent = nullptr);
    ~NebulaFileManager() override = default;

    QString currentPath() const { return m_currentPath; }
    void setCurrentPath(const QString& path);

    QVariantList directoryEntries() const { return m_entries; }
    QVariantList pathBreadcrumbs() const { return m_breadcrumbs; }
    QVariantList places() const { return m_places; }
    QVariantList drives() const { return m_drives; }
    int totalItemCount() const { return m_entries.size(); }
    QString statusMessage() const { return m_statusMessage; }
    bool isReadOnly() const { return m_isReadOnly; }

    // Navigation
    Q_INVOKABLE bool navigateTo(const QString& path);
    Q_INVOKABLE bool navigateUp();
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void refreshDrives();

    // Operations (Safe, unprivileged filesystem manipulation)
    Q_INVOKABLE bool createFolder(const QString& folderName);
    Q_INVOKABLE bool createFile(const QString& fileName, const QString& content = "");
    Q_INVOKABLE bool renameItem(const QString& oldName, const QString& newName);
    Q_INVOKABLE bool copyItem(const QString& sourceName, const QString& destDirectory);
    Q_INVOKABLE bool moveItem(const QString& sourceName, const QString& destDirectory);
    Q_INVOKABLE bool deleteItem(const QString& itemName);
    Q_INVOKABLE bool openItem(const QString& itemName);

    // File Preview & Inspection
    Q_INVOKABLE QVariantMap readFilePreview(const QString& itemName, int maxBytes = 32768);
    Q_INVOKABLE QVariantList searchEntries(const QString& query);

    // Quick Locations
    Q_INVOKABLE QString userHomePath() const;
    Q_INVOKABLE QString projectRootPath() const;
    Q_INVOKABLE QString documentsPath() const;
    Q_INVOKABLE QString downloadsPath() const;

signals:
    void currentPathChanged();
    void directoryEntriesChanged();
    void pathBreadcrumbsChanged();
    void placesChanged();
    void drivesChanged();
    void statusMessageChanged();
    void isReadOnlyChanged();
    void fileOperationCompleted(const QString& operation, bool success, const QString& message);
    void fileOpenRequested(const QString& filePath, const QString& fileType);

private:
    void scanCurrentDirectory();
    void updateBreadcrumbs();
    void scanPlacesAndDrives();
    bool isPathSafe(const QString& path) const;
    QString formatFileSize(qint64 bytes) const;
    QString determineFileType(const QFileInfo& fi) const;

    QString m_currentPath;
    QVariantList m_entries;
    QVariantList m_breadcrumbs;
    QVariantList m_places;
    QVariantList m_drives;
    QString m_statusMessage{"Ready"};
    bool m_isReadOnly{false};
};

} // namespace sritec::shell
