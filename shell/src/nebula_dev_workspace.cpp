#include "nebula_dev_workspace.hpp"
#include "sritec/logger.hpp"

#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QTextStream>
#include <algorithm>

namespace sritec::shell {

NebulaDevWorkspace::NebulaDevWorkspace(QObject* parent)
    : QObject(parent)
{
    m_projectRoot = "/run/media/sarathi/250-2.1/aios";
    if (!QDir(m_projectRoot).exists()) {
        m_projectRoot = QDir::currentPath();
    }

    scanProjectTree();
    refreshGitStatus();

    // Open default project file for instant usability
    QString defaultDoc = m_projectRoot + "/CMakeLists.txt";
    if (QFile::exists(defaultDoc)) {
        openFile(defaultDoc);
    } else {
        newFile("main.cpp");
    }

    sritec::Logger::instance().info("DEV_STUDIO", "NebulaDevWorkspace initialized at root: " + m_projectRoot.toStdString());
}

void NebulaDevWorkspace::setProjectRoot(const QString& root) {
    if (m_projectRoot != root && QDir(root).exists()) {
        m_projectRoot = QDir::cleanPath(root);
        emit projectRootChanged();
        scanProjectTree();
        refreshGitStatus();
    }
}

QVariantList NebulaDevWorkspace::openTabs() const {
    QVariantList list;
    for (const auto& tab : m_tabs) {
        QVariantMap map;
        map["id"] = tab.id;
        map["path"] = tab.path;
        map["name"] = tab.name;
        map["language"] = tab.language;
        map["isModified"] = tab.isModified;
        map["isActive"] = (tab.id == m_activeTabId);
        list.append(map);
    }
    return list;
}

void NebulaDevWorkspace::setActiveTabId(const QString& tabId) {
    if (m_activeTabId != tabId && findTab(tabId)) {
        m_activeTabId = tabId;
        emit activeTabIdChanged();
        emit activeContentChanged();
        emit activeLanguageChanged();
        emit activeFilePathChanged();
        emit openTabsChanged();
    }
}

QString NebulaDevWorkspace::activeContent() const {
    const auto* tab = findTab(m_activeTabId);
    return tab ? tab->content : "";
}

void NebulaDevWorkspace::setActiveContent(const QString& content) {
    auto* tab = findTab(m_activeTabId);
    if (tab && tab->content != content) {
        tab->content = content;
        tab->isModified = true;
        emit activeContentChanged();
        emit openTabsChanged();
    }
}

QString NebulaDevWorkspace::activeLanguage() const {
    const auto* tab = findTab(m_activeTabId);
    return tab ? tab->language : "Plain Text";
}

QString NebulaDevWorkspace::activeFilePath() const {
    const auto* tab = findTab(m_activeTabId);
    return tab ? tab->path : "";
}

bool NebulaDevWorkspace::openFile(const QString& filePath) {
    QFileInfo fi(filePath);
    if (!fi.exists() || fi.isDir()) {
        return false;
    }

    QString canonical = fi.canonicalFilePath();

    // Check if already open
    for (const auto& tab : m_tabs) {
        if (tab.path == canonical) {
            setActiveTabId(tab.id);
            return true;
        }
    }

    QFile file(canonical);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        sritec::Logger::instance().error("DEV_STUDIO", "Failed to open file: " + canonical.toStdString());
        return false;
    }

    QTextStream in(&file);
    QString content = in.readAll();
    file.close();

    EditorTab tab;
    tab.id = QString("tab-%1").arg(m_tabCounter++);
    tab.path = canonical;
    tab.name = fi.fileName();
    tab.content = content;
    tab.language = detectLanguage(canonical);
    tab.isModified = false;

    m_tabs.append(tab);
    m_activeTabId = tab.id;

    emit openTabsChanged();
    emit activeTabIdChanged();
    emit activeContentChanged();
    emit activeLanguageChanged();
    emit activeFilePathChanged();

    sritec::Logger::instance().info("DEV_STUDIO", "Opened file: " + canonical.toStdString());
    return true;
}

bool NebulaDevWorkspace::saveActiveFile() {
    auto* tab = findTab(m_activeTabId);
    if (!tab) return false;

    QFile file(tab->path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        sritec::Logger::instance().error("DEV_STUDIO", "Failed to save file: " + tab->path.toStdString());
        emit fileSaved(tab->path, false);
        return false;
    }

    QTextStream out(&file);
    out << tab->content;
    file.close();

    tab->isModified = false;
    emit openTabsChanged();
    emit fileSaved(tab->path, true);
    refreshGitStatus();

    sritec::Logger::instance().info("DEV_STUDIO", "Saved file: " + tab->path.toStdString());
    return true;
}

bool NebulaDevWorkspace::saveFileAs(const QString& targetPath, const QString& content) {
    QFile file(targetPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }

    QTextStream out(&file);
    out << content;
    file.close();

    openFile(targetPath);
    return true;
}

bool NebulaDevWorkspace::closeTab(const QString& tabId) {
    for (int i = 0; i < m_tabs.size(); ++i) {
        if (m_tabs[i].id == tabId) {
            m_tabs.removeAt(i);
            if (m_activeTabId == tabId) {
                if (!m_tabs.isEmpty()) {
                    m_activeTabId = m_tabs.last().id;
                } else {
                    m_activeTabId.clear();
                    newFile();
                }
            }
            emit openTabsChanged();
            emit activeTabIdChanged();
            emit activeContentChanged();
            emit activeLanguageChanged();
            emit activeFilePathChanged();
            return true;
        }
    }
    return false;
}

void NebulaDevWorkspace::newFile(const QString& defaultName) {
    EditorTab tab;
    tab.id = QString("tab-%1").arg(m_tabCounter++);
    tab.path = m_projectRoot + "/" + defaultName;
    tab.name = defaultName;
    tab.content = "// SRITEC AI OS Code Studio\n// New buffer\n\n#include <iostream>\n\nint main() {\n    std::cout << \"Hello from NEBULA Code Studio!\" << std::endl;\n    return 0;\n}\n";
    tab.language = detectLanguage(tab.path);
    tab.isModified = false;

    m_tabs.append(tab);
    m_activeTabId = tab.id;

    emit openTabsChanged();
    emit activeTabIdChanged();
    emit activeContentChanged();
    emit activeLanguageChanged();
    emit activeFilePathChanged();
}

QVariantList NebulaDevWorkspace::searchInActiveFile(const QString& term) {
    QVariantList matches;
    if (term.isEmpty()) return matches;

    const auto* tab = findTab(m_activeTabId);
    if (!tab) return matches;

    QStringList lines = tab->content.split('\n');
    for (int i = 0; i < lines.size(); ++i) {
        int pos = lines[i].indexOf(term, 0, Qt::CaseInsensitive);
        if (pos != -1) {
            QVariantMap m;
            m["lineNumber"] = i + 1;
            m["lineText"] = lines[i].trimmed();
            m["column"] = pos;
            matches.append(m);
        }
    }
    return matches;
}

QString NebulaDevWorkspace::replaceInActiveFile(const QString& term, const QString& replacement, bool replaceAll) {
    auto* tab = findTab(m_activeTabId);
    if (!tab || term.isEmpty()) return "";

    if (replaceAll) {
        tab->content.replace(term, replacement);
    } else {
        int idx = tab->content.indexOf(term);
        if (idx != -1) {
            tab->content.replace(idx, term.length(), replacement);
        }
    }

    tab->isModified = true;
    emit activeContentChanged();
    emit openTabsChanged();
    return tab->content;
}

void NebulaDevWorkspace::refreshProjectTree() {
    scanProjectTree();
}

void NebulaDevWorkspace::scanProjectTree() {
    m_projectTree.clear();
    QDir dir(m_projectRoot);
    if (!dir.exists()) return;

    // Scan top-level directories and files
    dir.setFilter(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot);
    dir.setSorting(QDir::DirsFirst | QDir::Name);

    QFileInfoList list = dir.entryInfoList();
    for (const auto& fi : list) {
        // Skip .git and huge build cache
        if (fi.fileName() == ".git" || fi.fileName() == "build") continue;

        QVariantMap node;
        node["name"] = fi.fileName();
        node["path"] = fi.absoluteFilePath();
        node["isDir"] = fi.isDir();
        node["type"] = fi.isDir() ? "folder" : detectLanguage(fi.fileName());

        if (fi.isDir()) {
            QDir subDir(fi.absoluteFilePath());
            subDir.setFilter(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot);
            QFileInfoList subList = subDir.entryInfoList();
            QVariantList children;
            for (const auto& subFi : subList) {
                if (subFi.fileName() == ".git") continue;
                QVariantMap childNode;
                childNode["name"] = subFi.fileName();
                childNode["path"] = subFi.absoluteFilePath();
                childNode["isDir"] = subFi.isDir();
                childNode["type"] = subFi.isDir() ? "folder" : detectLanguage(subFi.fileName());
                children.append(childNode);
            }
            node["children"] = children;
        }

        m_projectTree.append(node);
    }

    emit projectTreeChanged();
}

void NebulaDevWorkspace::refreshGitStatus() {
    // Read current branch
    QProcess branchProc;
    branchProc.setWorkingDirectory(m_projectRoot);
    branchProc.start("git", QStringList() << "branch" << "--show-current");
    if (branchProc.waitForFinished(1000)) {
        QString b = QString::fromUtf8(branchProc.readAllStandardOutput()).trimmed();
        if (!b.isEmpty()) {
            m_gitBranch = b;
        }
    }

    // Read git status --porcelain
    m_gitStatusFiles.clear();
    QProcess statusProc;
    statusProc.setWorkingDirectory(m_projectRoot);
    statusProc.start("git", QStringList() << "status" << "--porcelain");
    if (statusProc.waitForFinished(1500)) {
        QString raw = QString::fromUtf8(statusProc.readAllStandardOutput());
        QStringList lines = raw.split('\n', Qt::SkipEmptyParts);
        for (const QString& line : lines) {
            if (line.length() >= 4) {
                QString statusBadge = line.left(2).trimmed();
                QString relPath = line.mid(3).trimmed();
                QVariantMap fileEntry;
                fileEntry["badge"] = statusBadge;
                fileEntry["path"] = m_projectRoot + "/" + relPath;
                fileEntry["fileName"] = QFileInfo(relPath).fileName();
                fileEntry["relative"] = relPath;
                m_gitStatusFiles.append(fileEntry);
            }
        }
    }

    emit gitStatusChanged();
}

QString NebulaDevWorkspace::detectLanguage(const QString& filePath) const {
    QString ext = QFileInfo(filePath).suffix().toLower();
    if (ext == "cpp" || ext == "cxx" || ext == "cc") return "C++20";
    if (ext == "hpp" || ext == "hxx" || ext == "h") return "C++ Header";
    if (ext == "qml") return "QML";
    if (ext == "cmake" || filePath.endsWith("CMakeLists.txt")) return "CMake";
    if (ext == "md" || ext == "markdown") return "Markdown";
    if (ext == "py") return "Python";
    if (ext == "json") return "JSON";
    if (ext == "sh" || ext == "bash") return "Shell Script";
    if (ext == "xml" || ext == "qrc") return "XML";
    return "Plain Text";
}

EditorTab* NebulaDevWorkspace::findTab(const QString& id) {
    for (auto& tab : m_tabs) {
        if (tab.id == id) return &tab;
    }
    return nullptr;
}

const EditorTab* NebulaDevWorkspace::findTab(const QString& id) const {
    for (const auto& tab : m_tabs) {
        if (tab.id == id) return &tab;
    }
    return nullptr;
}

} // namespace sritec::shell
