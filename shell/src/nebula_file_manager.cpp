#include "nebula_file_manager.hpp"
#include "sritec/logger.hpp"

#include <QStandardPaths>
#include <QFile>
#include <QDirIterator>
#include <QTextStream>
#include <QUrl>
#include <QDesktopServices>
#include <QStorageInfo>
#include <algorithm>

namespace sritec::shell {

NebulaFileManager::NebulaFileManager(QObject* parent)
    : QObject(parent)
{
    // Default to the project directory if valid, otherwise user home
    QString defaultDir = "/run/media/sarathi/250-2.1/aios";
    if (QDir(defaultDir).exists()) {
        m_currentPath = defaultDir;
    } else {
        m_currentPath = QDir::homePath();
    }

    scanPlacesAndDrives();
    scanCurrentDirectory();
    updateBreadcrumbs();
    sritec::Logger::instance().info("FILE_MGR", "NebulaFileManager initialized at " + m_currentPath.toStdString());
}

void NebulaFileManager::refreshDrives() {
    scanPlacesAndDrives();
}

void NebulaFileManager::scanPlacesAndDrives() {
    m_places.clear();

    auto addPlace = [this](const QString& id, const QString& name, const QString& path, const QString& icon) {
        QVariantMap p;
        p["id"] = id;
        p["name"] = name;
        p["path"] = path;
        p["icon"] = icon;
        p["exists"] = QDir(path).exists();
        m_places.append(p);
    };

    QString home = QDir::homePath();
    addPlace("home", "Home", home, "home");
    addPlace("recent", "Recent", home, "recent");
    addPlace("starred", "Starred", home, "starred");
    addPlace("trash", "Trash", home + "/.local/share/Trash/files", "trash");
    addPlace("documents", "Documents", QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation), "documents");
    addPlace("music", "Music", home + "/Music", "music");
    addPlace("pictures", "Pictures", home + "/Pictures", "pictures");
    addPlace("videos", "Videos", home + "/Videos", "videos");
    addPlace("downloads", "Downloads", QStandardPaths::writableLocation(QStandardPaths::DownloadLocation), "downloads");

    emit placesChanged();

    m_drives.clear();

    auto addDrive = [this](const QString& id, const QString& name, const QString& path, const QString& dev, const QString& size, const QString& type, bool isMounted) {
        QVariantMap d;
        d["id"] = id;
        d["name"] = name;
        d["path"] = path;
        d["device"] = dev;
        d["size"] = size;
        d["type"] = type;
        d["isMounted"] = isMounted;
        m_drives.append(d);
    };

    // User's detected physical partitions
    QString sda2Path = "/run/media/sarathi/250-2.1/aios";
    if (!QDir(sda2Path).exists()) {
        sda2Path = "/run/media/sarathi/250-2.1";
    }

    QString sda1Path = "/run/media/sarathi/2-250";
    if (!QDir(sda1Path).exists()) sda1Path = "/media/sarathi/2-250";
    bool sda1Mounted = QDir(sda1Path).exists();

    QString sda3Path = "/run/media/sarathi/2.500";
    if (!QDir(sda3Path).exists()) sda3Path = "/media/sarathi/2.500";
    bool sda3Mounted = QDir(sda3Path).exists();

    QString sda4Path = "/run/media/sarathi/1tb";
    if (!QDir(sda4Path).exists()) sda4Path = "/media/sarathi/1tb";
    bool sda4Mounted = QDir(sda4Path).exists();

    addDrive("sda1", "2-250", sda1Path, "/dev/sda1", "233 GB", "ssd", sda1Mounted);
    addDrive("sda2", "250-2.1 (AIOS)", sda2Path, "/dev/sda2", "229 GB", "ssd", true);
    addDrive("sda3", "2.500", sda3Path, "/dev/sda3", "466 GB", "drive", sda3Mounted);
    addDrive("sda4", "1tb", sda4Path, "/dev/sda4", "932 GB", "drive", sda4Mounted);
    addDrive("root", "File System", "/", "/dev/nvme0n1p2", "457 GB", "system", true);

    emit drivesChanged();
}

void NebulaFileManager::setCurrentPath(const QString& path) {
    if (m_currentPath != path) {
        navigateTo(path);
    }
}

bool NebulaFileManager::navigateTo(const QString& path) {
    QFileInfo fi(path);
    if (!fi.exists() || !fi.isDir()) {
        m_statusMessage = "Target directory does not exist: " + path;
        emit statusMessageChanged();
        emit fileOperationCompleted("navigate", false, m_statusMessage);
        return false;
    }

    m_currentPath = QDir::cleanPath(path);
    scanCurrentDirectory();
    updateBreadcrumbs();

    emit currentPathChanged();
    emit fileOperationCompleted("navigate", true, "Navigated to " + m_currentPath);
    return true;
}

bool NebulaFileManager::navigateUp() {
    QDir dir(m_currentPath);
    if (dir.cdUp()) {
        m_currentPath = dir.canonicalPath();
        scanCurrentDirectory();
        updateBreadcrumbs();
        emit currentPathChanged();
        return true;
    }
    return false;
}

void NebulaFileManager::refresh() {
    scanCurrentDirectory();
}

void NebulaFileManager::scanCurrentDirectory() {
    m_entries.clear();
    QDir dir(m_currentPath);

    if (!dir.exists()) {
        m_statusMessage = "Directory not found";
        emit statusMessageChanged();
        emit directoryEntriesChanged();
        return;
    }

    QFileInfo dirInfo(m_currentPath);
    m_isReadOnly = !dirInfo.isWritable();
    emit isReadOnlyChanged();

    // Scan directories first, then files
    dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot | QDir::Hidden);
    dir.setSorting(QDir::Name | QDir::IgnoreCase);
    QFileInfoList folderList = dir.entryInfoList();

    for (const auto& fi : folderList) {
        QVariantMap item;
        item["name"] = fi.fileName();
        item["path"] = fi.absoluteFilePath();
        item["isDir"] = true;
        item["type"] = "folder";
        item["size"] = "<DIR>";
        item["modified"] = fi.lastModified().toString("MMM dd, yyyy hh:mm");
        item["icon"] = "folder";
        item["isWritable"] = fi.isWritable();
        item["isExecutable"] = fi.isExecutable();
        m_entries.append(item);
    }

    dir.setFilter(QDir::Files | QDir::Hidden);
    dir.setSorting(QDir::Name | QDir::IgnoreCase);
    QFileInfoList fileList = dir.entryInfoList();

    for (const auto& fi : fileList) {
        QVariantMap item;
        item["name"] = fi.fileName();
        item["path"] = fi.absoluteFilePath();
        item["isDir"] = false;
        item["type"] = determineFileType(fi);
        item["size"] = formatFileSize(fi.size());
        item["sizeBytes"] = fi.size();
        item["modified"] = fi.lastModified().toString("MMM dd, yyyy hh:mm");
        item["icon"] = item["type"].toString();
        item["isWritable"] = fi.isWritable();
        item["isExecutable"] = fi.isExecutable();
        m_entries.append(item);
    }

    m_statusMessage = QString("%1 items in current directory").arg(m_entries.size());
    emit statusMessageChanged();
    emit directoryEntriesChanged();
}

void NebulaFileManager::updateBreadcrumbs() {
    m_breadcrumbs.clear();

    QString clean = QDir::cleanPath(m_currentPath);
    QStringList parts = clean.split('/', Qt::SkipEmptyParts);

    // Root entry
    QVariantMap rootPart;
    rootPart["name"] = "root";
    rootPart["path"] = "/";
    m_breadcrumbs.append(rootPart);

    QString accum = "";
    for (const QString& part : parts) {
        accum += "/" + part;
        QVariantMap b;
        b["name"] = part;
        b["path"] = accum;
        m_breadcrumbs.append(b);
    }

    emit pathBreadcrumbsChanged();
}

bool NebulaFileManager::isPathSafe(const QString& path) const {
    QString clean = QDir::cleanPath(path);
    // Disallow critical system root modifications
    if (clean == "/" || clean == "/bin" || clean == "/boot" || clean == "/dev" ||
        clean == "/etc" || clean == "/lib" || clean == "/lib64" || clean == "/proc" ||
        clean == "/sys" || clean == "/usr") {
        return false;
    }
    return true;
}

bool NebulaFileManager::createFolder(const QString& folderName) {
    if (folderName.trimmed().isEmpty()) {
        m_statusMessage = "Folder name cannot be empty";
        emit statusMessageChanged();
        emit fileOperationCompleted("createFolder", false, m_statusMessage);
        return false;
    }

    QDir dir(m_currentPath);
    if (!dir.exists()) return false;

    QString newPath = dir.filePath(folderName.trimmed());
    if (dir.exists(folderName.trimmed())) {
        m_statusMessage = "Folder or file already exists: " + folderName;
        emit statusMessageChanged();
        emit fileOperationCompleted("createFolder", false, m_statusMessage);
        return false;
    }

    if (dir.mkdir(folderName.trimmed())) {
        m_statusMessage = "Folder created: " + folderName;
        scanCurrentDirectory();
        emit statusMessageChanged();
        emit fileOperationCompleted("createFolder", true, m_statusMessage);
        sritec::Logger::instance().info("FILE_MGR", "Created directory " + newPath.toStdString());
        return true;
    }

    m_statusMessage = "Failed to create folder (permission denied)";
    emit statusMessageChanged();
    emit fileOperationCompleted("createFolder", false, m_statusMessage);
    return false;
}

bool NebulaFileManager::createFile(const QString& fileName, const QString& content) {
    if (fileName.trimmed().isEmpty()) {
        m_statusMessage = "File name cannot be empty";
        emit statusMessageChanged();
        emit fileOperationCompleted("createFile", false, m_statusMessage);
        return false;
    }

    QDir dir(m_currentPath);
    if (!dir.exists()) return false;

    QString newPath = dir.filePath(fileName.trimmed());
    if (dir.exists(fileName.trimmed()) || QFile::exists(newPath)) {
        m_statusMessage = "Folder or file already exists: " + fileName;
        emit statusMessageChanged();
        emit fileOperationCompleted("createFile", false, m_statusMessage);
        return false;
    }

    QFile file(newPath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        if (!content.isEmpty()) {
            QTextStream out(&file);
            out << content;
        }
        file.close();
        m_statusMessage = "File created: " + fileName;
        scanCurrentDirectory();
        emit statusMessageChanged();
        emit fileOperationCompleted("createFile", true, m_statusMessage);
        sritec::Logger::instance().info("FILE_MGR", "Created file " + newPath.toStdString());
        return true;
    }

    m_statusMessage = "Failed to create file (permission denied)";
    emit statusMessageChanged();
    emit fileOperationCompleted("createFile", false, m_statusMessage);
    return false;
}

bool NebulaFileManager::openItem(const QString& itemName) {
    QDir dir(m_currentPath);
    QString fullPath = dir.filePath(itemName);
    QFileInfo fi(fullPath);

    if (!fi.exists()) {
        m_statusMessage = "Item does not exist: " + itemName;
        emit statusMessageChanged();
        return false;
    }

    if (fi.isDir()) {
        return navigateTo(fullPath);
    }

    QString fileType = determineFileType(fi);
    emit fileOpenRequested(fullPath, fileType);

    // Provide system desktop service open
    QDesktopServices::openUrl(QUrl::fromLocalFile(fullPath));
    m_statusMessage = "Opening " + itemName;
    emit statusMessageChanged();
    return true;
}

bool NebulaFileManager::renameItem(const QString& oldName, const QString& newName) {
    if (oldName.isEmpty() || newName.isEmpty() || oldName == newName) {
        return false;
    }

    QDir dir(m_currentPath);
    QString oldPath = dir.filePath(oldName);
    QString newPath = dir.filePath(newName);

    if (!isPathSafe(oldPath) || !isPathSafe(newPath)) {
        m_statusMessage = "Protected system path cannot be renamed";
        emit statusMessageChanged();
        emit fileOperationCompleted("rename", false, m_statusMessage);
        return false;
    }

    if (dir.rename(oldName, newName)) {
        m_statusMessage = QString("Renamed '%1' to '%2'").arg(oldName, newName);
        scanCurrentDirectory();
        emit statusMessageChanged();
        emit fileOperationCompleted("rename", true, m_statusMessage);
        return true;
    }

    m_statusMessage = "Rename failed: permission denied or name conflict";
    emit statusMessageChanged();
    emit fileOperationCompleted("rename", false, m_statusMessage);
    return false;
}

bool NebulaFileManager::copyItem(const QString& sourceName, const QString& destDirectory) {
    QDir dir(m_currentPath);
    QString srcPath = dir.filePath(sourceName);
    QFileInfo srcInfo(srcPath);

    if (!srcInfo.exists()) {
        m_statusMessage = "Source item does not exist";
        emit statusMessageChanged();
        return false;
    }

    QDir targetDir(destDirectory);
    if (!targetDir.exists()) {
        m_statusMessage = "Destination directory does not exist";
        emit statusMessageChanged();
        return false;
    }

    QString targetPath = targetDir.filePath(sourceName);

    if (srcInfo.isDir()) {
        // Deep folder copy placeholder / warning
        m_statusMessage = "Directory copy must be confirmed";
        emit statusMessageChanged();
        return false;
    }

    if (QFile::copy(srcPath, targetPath)) {
        m_statusMessage = "Copied " + sourceName + " successfully";
        scanCurrentDirectory();
        emit statusMessageChanged();
        emit fileOperationCompleted("copy", true, m_statusMessage);
        return true;
    }

    m_statusMessage = "Copy failed";
    emit statusMessageChanged();
    emit fileOperationCompleted("copy", false, m_statusMessage);
    return false;
}

bool NebulaFileManager::moveItem(const QString& sourceName, const QString& destDirectory) {
    QDir dir(m_currentPath);
    QString srcPath = dir.filePath(sourceName);
    QFileInfo srcInfo(srcPath);

    if (!srcInfo.exists()) {
        m_statusMessage = "Source item does not exist";
        emit statusMessageChanged();
        return false;
    }

    QDir targetDir(destDirectory);
    if (!targetDir.exists()) {
        m_statusMessage = "Destination directory does not exist";
        emit statusMessageChanged();
        return false;
    }

    QString targetPath = targetDir.filePath(sourceName);
    if (QFile::rename(srcPath, targetPath)) {
        m_statusMessage = "Moved " + sourceName + " successfully";
        scanCurrentDirectory();
        emit statusMessageChanged();
        emit fileOperationCompleted("move", true, m_statusMessage);
        return true;
    }

    m_statusMessage = "Move failed";
    emit statusMessageChanged();
    emit fileOperationCompleted("move", false, m_statusMessage);
    return false;
}

bool NebulaFileManager::deleteItem(const QString& itemName) {
    QDir dir(m_currentPath);
    QString itemPath = dir.filePath(itemName);
    QFileInfo fi(itemPath);

    if (!fi.exists()) {
        m_statusMessage = "Item does not exist: " + itemName;
        emit statusMessageChanged();
        return false;
    }

    if (!isPathSafe(itemPath)) {
        m_statusMessage = "Security Guardrail: Protected system path cannot be deleted!";
        sritec::Logger::instance().error("FILE_MGR", "Prevented deletion of protected path: " + itemPath.toStdString());
        emit statusMessageChanged();
        emit fileOperationCompleted("delete", false, m_statusMessage);
        return false;
    }

    bool success = false;
    if (fi.isDir()) {
        QDir subDir(itemPath);
        success = subDir.removeRecursively();
    } else {
        success = QFile::remove(itemPath);
    }

    if (success) {
        m_statusMessage = "Deleted " + itemName;
        scanCurrentDirectory();
        emit statusMessageChanged();
        emit fileOperationCompleted("delete", true, m_statusMessage);
        sritec::Logger::instance().info("FILE_MGR", "Deleted item: " + itemPath.toStdString());
        return true;
    }

    m_statusMessage = "Failed to delete item (permission denied)";
    emit statusMessageChanged();
    emit fileOperationCompleted("delete", false, m_statusMessage);
    return false;
}

QVariantMap NebulaFileManager::readFilePreview(const QString& itemName, int maxBytes) {
    QVariantMap res;
    QDir dir(m_currentPath);
    QString filePath = dir.filePath(itemName);
    QFileInfo fi(filePath);

    res["name"] = fi.fileName();
    res["path"] = fi.absoluteFilePath();
    res["size"] = formatFileSize(fi.size());
    res["sizeBytes"] = fi.size();
    res["type"] = determineFileType(fi);
    res["modified"] = fi.lastModified().toString("yyyy-MM-dd hh:mm:ss");
    res["isDir"] = fi.isDir();

    if (fi.isDir()) {
        res["previewType"] = "folder";
        QDir folderDir(filePath);
        res["content"] = QString("%1 items in this directory").arg(folderDir.entryList(QDir::AllEntries | QDir::NoDotAndDotDot).size());
        return res;
    }

    QString ext = fi.suffix().toLower();
    if (ext == "png" || ext == "jpg" || ext == "jpeg" || ext == "bmp" || ext == "svg" || ext == "webp") {
        res["previewType"] = "image";
        res["imageUrl"] = QUrl::fromLocalFile(filePath).toString();
        res["content"] = "[Image Preview Available]";
        return res;
    }

    // Attempt text preview
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        res["previewType"] = "text";
        QByteArray data = file.read(maxBytes);
        res["content"] = QString::fromUtf8(data);
        res["isTruncated"] = (file.size() > maxBytes);
        file.close();
    } else {
        res["previewType"] = "binary";
        res["content"] = "[Binary File or Permission Denied]";
    }

    return res;
}

QVariantList NebulaFileManager::searchEntries(const QString& query) {
    QVariantList matches;
    if (query.trimmed().isEmpty()) {
        return m_entries;
    }

    QString term = query.trimmed().toLower();
    QDirIterator it(m_currentPath, QDir::AllEntries | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);

    int count = 0;
    while (it.hasNext() && count < 60) {
        it.next();
        QFileInfo fi = it.fileInfo();
        if (fi.fileName().toLower().contains(term)) {
            QVariantMap item;
            item["name"] = fi.fileName();
            item["path"] = fi.absoluteFilePath();
            item["isDir"] = fi.isDir();
            item["type"] = determineFileType(fi);
            item["size"] = formatFileSize(fi.size());
            item["modified"] = fi.lastModified().toString("MMM dd, yyyy");
            item["icon"] = item["type"].toString();
            matches.append(item);
            count++;
        }
    }

    return matches;
}

QString NebulaFileManager::determineFileType(const QFileInfo& fi) const {
    if (fi.isDir()) return "folder";

    QString ext = fi.suffix().toLower();
    if (ext == "cpp" || ext == "hpp" || ext == "c" || ext == "h" || ext == "py" ||
        ext == "js" || ext == "qml" || ext == "json" || ext == "cmake" || ext == "sh") {
        return "code";
    }
    if (ext == "md" || ext == "txt" || ext == "doc" || ext == "pdf" || ext == "rst") {
        return "document";
    }
    if (ext == "png" || ext == "jpg" || ext == "jpeg" || ext == "svg" || ext == "webp" || ext == "gif") {
        return "image";
    }
    if (ext == "mp3" || ext == "wav" || ext == "flac" || ext == "ogg") {
        return "audio";
    }
    if (ext == "mp4" || ext == "mkv" || ext == "avi" || ext == "webm") {
        return "video";
    }
    if (ext == "zip" || ext == "tar" || ext == "gz" || ext == "xz" || ext == "7z") {
        return "archive";
    }
    return "file";
}

QString NebulaFileManager::formatFileSize(qint64 bytes) const {
    if (bytes < 1024) return QString("%1 B").arg(bytes);
    if (bytes < 1024 * 1024) return QString("%1 KB").arg(bytes / 1024.0, 0, 'f', 1);
    if (bytes < 1024 * 1024 * 1024) return QString("%1 MB").arg(bytes / (1024.0 * 1024.0), 0, 'f', 1);
    return QString("%1 GB").arg(bytes / (1024.0 * 1024.0 * 1024.0), 0, 'f', 2);
}

QString NebulaFileManager::userHomePath() const {
    return QDir::homePath();
}

QString NebulaFileManager::projectRootPath() const {
    return "/run/media/sarathi/250-2.1/aios";
}

QString NebulaFileManager::documentsPath() const {
    return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
}

QString NebulaFileManager::downloadsPath() const {
    return QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
}

} // namespace sritec::shell
