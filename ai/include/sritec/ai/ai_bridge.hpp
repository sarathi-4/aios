#pragma once

#include "provider_manager.hpp"
#include <QObject>
#include <QString>
#include <QStringList>
#include <QPointer>
#include <memory>

namespace sritec::ai {

enum class CommandSafetyLevel {
    Invalid,
    Dangerous,
    Sensitive,
    Safe
};

class AIBridge : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isGenerating READ isGenerating NOTIFY isGeneratingChanged)
    Q_PROPERTY(QString currentResponse READ currentResponse NOTIFY currentResponseChanged)
    Q_PROPERTY(QString modelName READ modelName NOTIFY modelNameChanged)
    Q_PROPERTY(int tokenCount READ tokenCount NOTIFY tokenCountChanged)

    // Phase 2.1 Provider Gateway Properties
    Q_PROPERTY(QString selectedProvider READ selectedProvider WRITE setSelectedProvider NOTIFY selectedProviderChanged)
    Q_PROPERTY(QString selectedModel READ selectedModel WRITE setSelectedModel NOTIFY selectedModelChanged)
    Q_PROPERTY(QStringList availableProviders READ availableProviders CONSTANT)
    Q_PROPERTY(QStringList availableModels READ availableModels NOTIFY availableModelsChanged)
    Q_PROPERTY(QString connectionState READ connectionState NOTIFY connectionStateChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(bool hasApiKey READ hasApiKey NOTIFY hasApiKeyChanged)

public:
    explicit AIBridge(QObject* parent = nullptr, std::shared_ptr<ITransport> transport = nullptr);
    ~AIBridge() override;

    bool isGenerating() const { return m_isGenerating; }
    QString currentResponse() const { return m_currentResponse; }
    QString modelName() const;
    int tokenCount() const { return m_tokenCount; }

    QString selectedProvider() const;
    void setSelectedProvider(const QString& name);

    QString selectedModel() const;
    void setSelectedModel(const QString& model);

    QStringList availableProviders() const;
    QStringList availableModels() const;

    QString connectionState() const;
    QString statusMessage() const;
    bool hasApiKey() const;

    // Invocables
    Q_INVOKABLE void sendQuery(const QString& prompt);
    Q_INVOKABLE void cancel();
    Q_INVOKABLE void clear();
    Q_INVOKABLE QString checkCommandSafety(const QString& command);

    Q_INVOKABLE void selectProvider(const QString& name);
    Q_INVOKABLE void selectModel(const QString& model);
    Q_INVOKABLE void setApiKey(const QString& provider, const QString& key);
    Q_INVOKABLE void clearHistory();
    Q_INVOKABLE void retry();

    // Whitelist-first command safety evaluator
    static CommandSafetyLevel evaluateCommand(const QString& command, QString* reasonOut = nullptr);

    // Direct access to manager for C++ unit tests
    ProviderManager& manager() { return *m_manager; }

signals:
    void isGeneratingChanged();
    void currentResponseChanged();
    void modelNameChanged();
    void tokenCountChanged();
    void selectedProviderChanged();
    void selectedModelChanged();
    void availableModelsChanged();
    void connectionStateChanged();
    void statusMessageChanged();
    void hasApiKeyChanged();
    void tokenReceived(const QString& token);
    void generationFinished(const QString& fullResponse);
    void errorOccurred(int code, const QString& message);

private slots:
    void handleToken(const QString& token, bool finished);
    void handleError(int code, const QString& message);

private:
    std::unique_ptr<ProviderManager> m_manager;
    bool m_isGenerating{false};
    QString m_currentResponse;
    int m_tokenCount{0};
    QString m_lastPrompt;
    QString m_lastError;
};

} // namespace sritec::ai
