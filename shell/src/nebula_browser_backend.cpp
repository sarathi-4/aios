#include "nebula_browser_backend.hpp"
#include "sritec/logger.hpp"

#include <QUrl>
#include <QUrlQuery>
#include <QDateTime>

namespace sritec::shell {

NebulaBrowserBackend::NebulaBrowserBackend(QObject* parent)
    : QObject(parent)
{
    initDefaultBookmarks();

    // Open initial tab
    createTab("https://duckduckgo.com", "DuckDuckGo Search");

    sritec::Logger::instance().info("BROWSER", "NebulaBrowserBackend initialized with secure sandboxed profile.");
}

QString NebulaBrowserBackend::engineNotice() const {
    return "Qt WebEngine is not installed on the host system (requires package 'qt6-webengine-dev'). "
           "In accordance with Milestone 3.4 safety rules, package installation without approval is withheld. "
           "NEBULA Web & AI Portal is active with sandboxed web portals and direct AI gateways.";
}

void NebulaBrowserBackend::initDefaultBookmarks() {
    auto addBm = [this](const QString& title, const QString& url, const QString& icon) {
        QVariantMap bm;
        bm["title"] = title;
        bm["url"] = url;
        bm["icon"] = icon;
        m_bookmarks.append(bm);
    };

    addBm("ChatGPT", "https://chatgpt.com", "chatgpt");
    addBm("Google Gemini", "https://gemini.google.com", "gemini");
    addBm("Anthropic Claude", "https://claude.ai", "claude");
    addBm("DuckDuckGo", "https://duckduckgo.com", "search");
    addBm("GitHub", "https://github.com", "code");
    addBm("SRITEC Docs", "https://sritec.internal/docs", "documents");
}

QVariantList NebulaBrowserBackend::tabs() const {
    QVariantList list;
    for (const auto& tab : m_tabs) {
        QVariantMap map;
        map["id"] = tab.id;
        map["title"] = tab.title;
        map["url"] = tab.url;
        map["domain"] = extractDomain(tab.url);
        map["isSecure"] = tab.isSecure;
        map["isLoading"] = tab.isLoading;
        map["isActive"] = (tab.id == m_activeTabId);
        list.append(map);
    }
    return list;
}

void NebulaBrowserBackend::setActiveTabId(const QString& id) {
    if (m_activeTabId != id && findTab(id)) {
        m_activeTabId = id;
        emit activeTabIdChanged();
        emit activeUrlChanged();
        emit activeTitleChanged();
        emit activeIsSecureChanged();
        emit activeIsLoadingChanged();
        emit activeTabHistoryChanged();
        emit tabsChanged();
    }
}

QString NebulaBrowserBackend::activeUrl() const {
    const auto* tab = findTab(m_activeTabId);
    return tab ? tab->url : "";
}

QString NebulaBrowserBackend::activeTitle() const {
    const auto* tab = findTab(m_activeTabId);
    return tab ? tab->title : "";
}

bool NebulaBrowserBackend::activeIsSecure() const {
    const auto* tab = findTab(m_activeTabId);
    return tab ? tab->isSecure : true;
}

bool NebulaBrowserBackend::activeIsLoading() const {
    const auto* tab = findTab(m_activeTabId);
    return tab ? tab->isLoading : false;
}

bool NebulaBrowserBackend::canGoBack() const {
    const auto* tab = findTab(m_activeTabId);
    return tab ? (tab->historyIndex > 0) : false;
}

bool NebulaBrowserBackend::canGoForward() const {
    const auto* tab = findTab(m_activeTabId);
    return tab ? (tab->historyIndex < tab->historyStack.size() - 1) : false;
}

void NebulaBrowserBackend::setPrivateBrowsing(bool enabled) {
    if (m_isPrivateBrowsing != enabled) {
        m_isPrivateBrowsing = enabled;
        emit privateBrowsingChanged();
        sritec::Logger::instance().info("BROWSER", QString("Private browsing mode set to: %1").arg(enabled ? "ENABLED" : "DISABLED").toStdString());
    }
}

QString NebulaBrowserBackend::createTab(const QString& url, const QString& title) {
    BrowserTab tab;
    tab.id = QString("browser-tab-%1").arg(m_tabCounter++);
    tab.url = url;
    tab.title = title;
    tab.isSecure = url.startsWith("https://");
    tab.isLoading = false;
    tab.historyStack.append(url);
    tab.historyIndex = 0;

    m_tabs.append(tab);
    m_activeTabId = tab.id;

    emit tabsChanged();
    emit activeTabIdChanged();
    emit activeUrlChanged();
    emit activeTitleChanged();
    emit activeIsSecureChanged();
    emit activeIsLoadingChanged();
    emit activeTabHistoryChanged();

    sritec::Logger::instance().info("BROWSER", "Opened new browser tab: " + tab.id.toStdString());
    return tab.id;
}

bool NebulaBrowserBackend::closeTab(const QString& tabId) {
    if (m_tabs.size() <= 1) {
        // Do not close last tab; navigate to default portal
        navigate("https://duckduckgo.com");
        return true;
    }

    for (int i = 0; i < m_tabs.size(); ++i) {
        if (m_tabs[i].id == tabId) {
            m_tabs.removeAt(i);
            if (m_activeTabId == tabId) {
                m_activeTabId = m_tabs.last().id;
            }
            emit tabsChanged();
            emit activeTabIdChanged();
            emit activeUrlChanged();
            emit activeTitleChanged();
            emit activeIsSecureChanged();
            emit activeIsLoadingChanged();
            emit activeTabHistoryChanged();
            return true;
        }
    }
    return false;
}

void NebulaBrowserBackend::navigate(const QString& input) {
    auto* tab = findTab(m_activeTabId);
    if (!tab) return;

    QString finalUrl = formatUrlOrQuery(input);
    tab->url = finalUrl;
    tab->isSecure = finalUrl.startsWith("https://");
    tab->title = extractDomain(finalUrl);

    // Truncate forward history if navigating to a new URL
    if (tab->historyIndex < tab->historyStack.size() - 1) {
        tab->historyStack = tab->historyStack.mid(0, tab->historyIndex + 1);
    }
    tab->historyStack.append(finalUrl);
    tab->historyIndex = tab->historyStack.size() - 1;

    // Record in history if not private
    if (!m_isPrivateBrowsing) {
        QVariantMap entry;
        entry["title"] = tab->title;
        entry["url"] = finalUrl;
        entry["timestamp"] = QDateTime::currentDateTime().toString("hh:mm:ss");
        m_history.prepend(entry);
        if (m_history.size() > 200) m_history.removeLast();
        emit historyChanged();
    }

    emit activeUrlChanged();
    emit activeTitleChanged();
    emit activeIsSecureChanged();
    emit activeTabHistoryChanged();
    emit tabsChanged();

    sritec::Logger::instance().info("BROWSER", "Navigated to: " + finalUrl.toStdString());
}

void NebulaBrowserBackend::goBack() {
    auto* tab = findTab(m_activeTabId);
    if (!tab || tab->historyIndex <= 0) return;

    tab->historyIndex--;
    tab->url = tab->historyStack[tab->historyIndex];
    tab->title = extractDomain(tab->url);
    tab->isSecure = tab->url.startsWith("https://");

    emit activeUrlChanged();
    emit activeTitleChanged();
    emit activeIsSecureChanged();
    emit activeTabHistoryChanged();
    emit tabsChanged();
}

void NebulaBrowserBackend::goForward() {
    auto* tab = findTab(m_activeTabId);
    if (!tab || tab->historyIndex >= tab->historyStack.size() - 1) return;

    tab->historyIndex++;
    tab->url = tab->historyStack[tab->historyIndex];
    tab->title = extractDomain(tab->url);
    tab->isSecure = tab->url.startsWith("https://");

    emit activeUrlChanged();
    emit activeTitleChanged();
    emit activeIsSecureChanged();
    emit activeTabHistoryChanged();
    emit tabsChanged();
}

void NebulaBrowserBackend::reload() {
    auto* tab = findTab(m_activeTabId);
    if (!tab) return;

    tab->isLoading = true;
    emit activeIsLoadingChanged();
    emit tabsChanged();
    // In pure sandboxed mode, simulate quick handshake refresh
}

void NebulaBrowserBackend::openAIPortal(const QString& provider) {
    if (provider == "chatgpt") {
        createTab("https://chatgpt.com", "ChatGPT — OpenAI");
    } else if (provider == "gemini") {
        createTab("https://gemini.google.com", "Google Gemini");
    } else if (provider == "claude") {
        createTab("https://claude.ai", "Claude — Anthropic");
    } else {
        createTab("https://duckduckgo.com/?q=ai+research", "Intelligent Search");
    }
}

void NebulaBrowserBackend::addBookmark(const QString& title, const QString& url) {
    if (isBookmarked(url)) return;

    QVariantMap bm;
    bm["title"] = title.isEmpty() ? extractDomain(url) : title;
    bm["url"] = url;
    bm["icon"] = "bookmark";
    m_bookmarks.append(bm);
    emit bookmarksChanged();
}

void NebulaBrowserBackend::removeBookmark(const QString& url) {
    for (int i = 0; i < m_bookmarks.size(); ++i) {
        if (m_bookmarks[i].toMap()["url"].toString() == url) {
            m_bookmarks.removeAt(i);
            emit bookmarksChanged();
            return;
        }
    }
}

bool NebulaBrowserBackend::isBookmarked(const QString& url) const {
    for (const auto& bm : m_bookmarks) {
        if (bm.toMap()["url"].toString() == url) {
            return true;
        }
    }
    return false;
}

void NebulaBrowserBackend::clearHistory() {
    m_history.clear();
    emit historyChanged();
}

QString NebulaBrowserBackend::formatUrlOrQuery(const QString& input) const {
    QString trimmed = input.trimmed();
    if (trimmed.isEmpty()) return "https://duckduckgo.com";

    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
        return trimmed;
    }

    // Check if input looks like a domain name
    if (trimmed.contains('.') && !trimmed.contains(' ')) {
        return "https://" + trimmed;
    }

    // Otherwise format as search query
    return "https://duckduckgo.com/?q=" + QUrl::toPercentEncoding(trimmed);
}

QString NebulaBrowserBackend::extractDomain(const QString& url) const {
    QUrl qurl(url);
    QString host = qurl.host();
    if (host.startsWith("www.")) host = host.mid(4);
    return host.isEmpty() ? "Web Portal" : host;
}

BrowserTab* NebulaBrowserBackend::findTab(const QString& id) {
    for (auto& tab : m_tabs) {
        if (tab.id == id) return &tab;
    }
    return nullptr;
}

const BrowserTab* NebulaBrowserBackend::findTab(const QString& id) const {
    for (const auto& tab : m_tabs) {
        if (tab.id == id) return &tab;
    }
    return nullptr;
}

} // namespace sritec::shell
