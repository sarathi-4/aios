#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

namespace sritec::shell {

struct EditorTab {
    QString id;
    QString path;
    QString name;
    QString content;
    QString language;
    bool isModified{false};
};

class NebulaDevWorkspace : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString projectRoot READ projectRoot WRITE setProjectRoot NOTIFY projectRootChanged)
    Q_PROPERTY(QVariantList projectTree READ projectTree NOTIFY projectTreeChanged)
    Q_PROPERTY(QVariantList openTabs READ openTabs NOTIFY openTabsChanged)
    Q_PROPERTY(QString activeTabId READ activeTabId WRITE setActiveTabId NOTIFY activeTabIdChanged)
    Q_PROPERTY(QString activeContent READ activeContent WRITE setActiveContent NOTIFY activeContentChanged)
    Q_PROPERTY(QString activeLanguage READ activeLanguage NOTIFY activeLanguageChanged)
    Q_PROPERTY(QString activeFilePath READ activeFilePath NOTIFY activeFilePathChanged)
    Q_PROPERTY(QString gitBranch READ gitBranch NOTIFY gitStatusChanged)
    Q_PROPERTY(QVariantList gitStatusFiles READ gitStatusFiles NOTIFY gitStatusChanged)
    Q_PROPERTY(int totalTabCount READ totalTabCount NOTIFY openTabsChanged)

public:
    explicit NebulaDevWorkspace(QObject* parent = nullptr);
    ~NebulaDevWorkspace() override = default;

    QString projectRoot() const { return m_projectRoot; }
    void setProjectRoot(const QString& root);

    QVariantList projectTree() const { return m_projectTree; }
    QVariantList openTabs() const;
    QString activeTabId() const { return m_activeTabId; }
    void setActiveTabId(const QString& tabId);

    QString activeContent() const;
    void setActiveContent(const QString& content);

    QString activeLanguage() const;
    QString activeFilePath() const;
    QString gitBranch() const { return m_gitBranch; }
    QVariantList gitStatusFiles() const { return m_gitStatusFiles; }
    int totalTabCount() const { return m_tabs.size(); }

    // Editor Operations
    Q_INVOKABLE bool openFile(const QString& filePath);
    Q_INVOKABLE bool saveActiveFile();
    Q_INVOKABLE bool saveFileAs(const QString& targetPath, const QString& content);
    Q_INVOKABLE bool closeTab(const QString& tabId);
    Q_INVOKABLE void newFile(const QString& defaultName = "untitled.cpp");

    // Search and Replace
    Q_INVOKABLE QVariantList searchInActiveFile(const QString& term);
    Q_INVOKABLE QString replaceInActiveFile(const QString& term, const QString& replacement, bool replaceAll = true);

    // Git Operations
    Q_INVOKABLE void refreshGitStatus();

    // Project Tree Refresh
    Q_INVOKABLE void refreshProjectTree();

signals:
    void projectRootChanged();
    void projectTreeChanged();
    void openTabsChanged();
    void activeTabIdChanged();
    void activeContentChanged();
    void activeLanguageChanged();
    void activeFilePathChanged();
    void gitStatusChanged();
    void fileSaved(const QString& path, bool success);

private:
    void scanProjectTree();
    QString detectLanguage(const QString& filePath) const;
    EditorTab* findTab(const QString& id);
    const EditorTab* findTab(const QString& id) const;

    QString m_projectRoot;
    QVariantList m_projectTree;
    QVector<EditorTab> m_tabs;
    QString m_activeTabId;
    QString m_gitBranch{"main"};
    QVariantList m_gitStatusFiles;
    int m_tabCounter{1};
};

} // namespace sritec::shell
