#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

namespace sritec::shell {

struct BrowserTab {
    QString id;
    QString title;
    QString url;
    QString favicon;
    bool isSecure{true};
    bool isLoading{false};
    QStringList historyStack;
    int historyIndex{0};
};

class NebulaBrowserBackend : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantList tabs READ tabs NOTIFY tabsChanged)
    Q_PROPERTY(QString activeTabId READ activeTabId WRITE setActiveTabId NOTIFY activeTabIdChanged)
    Q_PROPERTY(QString activeUrl READ activeUrl NOTIFY activeUrlChanged)
    Q_PROPERTY(QString activeTitle READ activeTitle NOTIFY activeTitleChanged)
    Q_PROPERTY(bool activeIsSecure READ activeIsSecure NOTIFY activeIsSecureChanged)
    Q_PROPERTY(bool activeIsLoading READ activeIsLoading NOTIFY activeIsLoadingChanged)
    Q_PROPERTY(bool canGoBack READ canGoBack NOTIFY activeTabHistoryChanged)
    Q_PROPERTY(bool canGoForward READ canGoForward NOTIFY activeTabHistoryChanged)
    Q_PROPERTY(QVariantList bookmarks READ bookmarks NOTIFY bookmarksChanged)
    Q_PROPERTY(QVariantList history READ history NOTIFY historyChanged)
    Q_PROPERTY(QVariantList downloads READ downloads NOTIFY downloadsChanged)
    Q_PROPERTY(bool isPrivateBrowsing READ isPrivateBrowsing WRITE setPrivateBrowsing NOTIFY privateBrowsingChanged)
    Q_PROPERTY(bool isWebEngineInstalled READ isWebEngineInstalled CONSTANT)
    Q_PROPERTY(QString engineNotice READ engineNotice CONSTANT)

public:
    explicit NebulaBrowserBackend(QObject* parent = nullptr);
    ~NebulaBrowserBackend() override = default;

    QVariantList tabs() const;
    QString activeTabId() const { return m_activeTabId; }
    void setActiveTabId(const QString& id);

    QString activeUrl() const;
    QString activeTitle() const;
    bool activeIsSecure() const;
    bool activeIsLoading() const;
    bool canGoBack() const;
    bool canGoForward() const;

    QVariantList bookmarks() const { return m_bookmarks; }
    QVariantList history() const { return m_history; }
    QVariantList downloads() const { return m_downloads; }
    bool isPrivateBrowsing() const { return m_isPrivateBrowsing; }
    void setPrivateBrowsing(bool enabled);

    bool isWebEngineInstalled() const { return false; /* Audited: qt6-webengine-dev not installed */ }
    QString engineNotice() const;

    // Navigation Operations
    Q_INVOKABLE QString createTab(const QString& url = "https://duckduckgo.com", const QString& title = "New Tab");
    Q_INVOKABLE bool closeTab(const QString& tabId);
    Q_INVOKABLE void navigate(const QString& input);
    Q_INVOKABLE void goBack();
    Q_INVOKABLE void goForward();
    Q_INVOKABLE void reload();

    // AI Direct Portals
    Q_INVOKABLE void openAIPortal(const QString& provider);

    // Bookmarks & History
    Q_INVOKABLE void addBookmark(const QString& title, const QString& url);
    Q_INVOKABLE void removeBookmark(const QString& url);
    Q_INVOKABLE bool isBookmarked(const QString& url) const;
    Q_INVOKABLE void clearHistory();

signals:
    void tabsChanged();
    void activeTabIdChanged();
    void activeUrlChanged();
    void activeTitleChanged();
    void activeIsSecureChanged();
    void activeIsLoadingChanged();
    void activeTabHistoryChanged();
    void bookmarksChanged();
    void historyChanged();
    void downloadsChanged();
    void privateBrowsingChanged();
    void downloadCompleted(const QString& fileName, const QString& path);

private:
    void initDefaultBookmarks();
    BrowserTab* findTab(const QString& id);
    const BrowserTab* findTab(const QString& id) const;
    QString formatUrlOrQuery(const QString& input) const;
    QString extractDomain(const QString& url) const;

    QVector<BrowserTab> m_tabs;
    QString m_activeTabId;
    QVariantList m_bookmarks;
    QVariantList m_history;
    QVariantList m_downloads;
    bool m_isPrivateBrowsing{false};
    int m_tabCounter{1};
};

} // namespace sritec::shell
