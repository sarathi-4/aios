#pragma once

#include <QObject>
#include <QString>
#include "jarvis_types.hpp"

namespace sritec::jarvis {

class IntentRecognizer : public QObject {
    Q_OBJECT

public:
    explicit IntentRecognizer(QObject* parent = nullptr);
    ~IntentRecognizer() override = default;

    // Parses natural language command into structured IntentResult
    IntentResult parseCommand(const QString& rawInput);

    // Strips wake word prefixes ("hey jarvis", "jarvis", etc.)
    QString stripWakeWord(const QString& text) const;

signals:
    void intentRecognized(const IntentResult& result);
    void ambiguousIntentDetected(const QString& query);
};

} // namespace sritec::jarvis
