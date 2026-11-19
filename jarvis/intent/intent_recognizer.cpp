#include "intent_recognizer.hpp"
#include "sritec/logger.hpp"

#include <QStringList>

namespace sritec::jarvis {

IntentRecognizer::IntentRecognizer(QObject* parent)
    : QObject(parent)
{
    sritec::Logger::instance().info("INTENT_REC", "IntentRecognizer initialized with English, Tamil-English, and Hindi grammar mappings.");
}

QString IntentRecognizer::stripWakeWord(const QString& text) const {
    QString clean = text.trimmed();
    static const QStringList prefixes = {
        "hey jarvis,", "hey jarvis", "hi jarvis,", "hi jarvis",
        "jarvis,", "jarvis", "hello jarvis,", "hello jarvis",
        "ஹே ஜார்விஸ்,", "ஹே ஜார்விஸ்", "ஜார்விஸ்,", "ஜார்விஸ்",
        "हे जार्विस,", "हे जार्विस", "जार्विस,", "जार्विस"
    };

    for (const auto& p : prefixes) {
        if (clean.toLower().startsWith(p)) {
            clean = clean.mid(p.length()).trimmed();
            if (clean.startsWith(",") || clean.startsWith(".")) {
                clean = clean.mid(1).trimmed();
            }
            break;
        }
    }
    return clean;
}

IntentResult IntentRecognizer::parseCommand(const QString& rawInput) {
    IntentResult result;
    result.rawQuery = rawInput;

    QString stripped = stripWakeWord(rawInput);
    QString lower = stripped.toLower().trimmed();

    // 1. Language Detection heuristic
    if (lower.contains("pannu") || lower.contains("kaatu") || lower.contains("moodu") ||
        rawInput.contains("ஜார்விஸ்") || rawInput.contains("திற") || rawInput.contains("மூடு")) {
        result.detectedLanguage = "ta";
    } else if (lower.contains("kholo") || lower.contains("chalu") || lower.contains("band") ||
               lower.contains("dikhao") || rawInput.contains("जार्विस") || rawInput.contains("खोलो")) {
        result.detectedLanguage = "hi";
    } else {
        result.detectedLanguage = "en";
    }

    // 2. Camera Controls
    if (lower.contains("turn on camera") || lower.contains("enable camera") ||
        lower.contains("start camera") || lower.contains("camera on") ||
        lower.contains("camera on pannu") || lower.contains("camera chalu karo")) {
        result.type = IntentType::CameraControl;
        result.action = "turn_on";
        result.target = "camera";
        result.confidence = 0.98;
        emit intentRecognized(result);
        return result;
    }

    if (lower.contains("turn off camera") || lower.contains("disable camera") ||
        lower.contains("stop camera") || lower.contains("camera off") ||
        lower.contains("camera off pannu") || lower.contains("camera moodu") ||
        lower.contains("camera band karo")) {
        result.type = IntentType::CameraControl;
        result.action = "turn_off";
        result.target = "camera";
        result.confidence = 0.98;
        emit intentRecognized(result);
        return result;
    }

    // 3. Stop Listening / Pause Command
    if (lower == "stop listening" || lower == "stop" || lower == "pause" ||
        lower == "silence" || lower == "shut up" || lower.contains("pesatha") ||
        lower.contains("chup raho")) {
        result.type = IntentType::StopListening;
        result.action = "stop_listening";
        result.target = "assistant";
        result.confidence = 0.99;
        emit intentRecognized(result);
        return result;
    }

    // 4. Window Controls
    if (lower.contains("close this window") || lower.contains("close window") ||
        lower.contains("window close pannu") || lower.contains("window moodu") ||
        lower.contains("window band karo")) {
        result.type = IntentType::WindowControl;
        result.action = "close";
        result.target = "active_window";
        result.confidence = 0.95;
        emit intentRecognized(result);
        return result;
    }

    if (lower.contains("minimize this window") || lower.contains("minimize window") ||
        lower.contains("window minimize pannu")) {
        result.type = IntentType::WindowControl;
        result.action = "minimize";
        result.target = "active_window";
        result.confidence = 0.95;
        emit intentRecognized(result);
        return result;
    }

    if (lower.contains("maximize this window") || lower.contains("maximize window") ||
        lower.contains("fullscreen window") || lower.contains("window maximize pannu")) {
        result.type = IntentType::WindowControl;
        result.action = "maximize";
        result.target = "active_window";
        result.confidence = 0.95;
        emit intentRecognized(result);
        return result;
    }

    // 5. Workspace Switching
    if (lower.contains("switch to developer workspace") || lower.contains("switch to dev workspace") ||
        lower.contains("open developer workspace") || lower.contains("developer workspace switch pannu")) {
        result.type = IntentType::WorkspaceSwitch;
        result.action = "switch_workspace";
        result.target = "developer";
        result.confidence = 0.96;
        result.parameters["workspaceIndex"] = 2;
        emit intentRecognized(result);
        return result;
    }

    if (lower.contains("switch to desktop") || lower.contains("go home") || lower.contains("home screen")) {
        result.type = IntentType::WorkspaceSwitch;
        result.action = "switch_workspace";
        result.target = "home";
        result.confidence = 0.96;
        result.parameters["workspaceIndex"] = 0;
        emit intentRecognized(result);
        return result;
    }

    // 6. System Status / Telemetry
    if (lower.contains("show system status") || lower.contains("system status") ||
        lower.contains("system health") || lower.contains("diagnostics") ||
        lower.contains("system status kaatu") || lower.contains("status dikhao")) {
        result.type = IntentType::SystemStatus;
        result.action = "open";
        result.target = "monitor";
        result.confidence = 0.97;
        emit intentRecognized(result);
        return result;
    }

    // 7. Search Project Files
    if (lower.contains("search for my project files") || lower.contains("find project files") ||
        lower.contains("search files") || lower.contains("open my last project")) {
        result.type = IntentType::SearchFiles;
        result.action = "search";
        result.target = "files";
        result.confidence = 0.92;
        emit intentRecognized(result);
        return result;
    }

    // Shell Injection & Command Execution Guardrails
    // Malicious shell strings or raw bash execution attempts must NEVER be treated as safe app launches
    if (lower.contains("-c ") || lower.contains("&&") || lower.contains("||") ||
        lower.contains(";") || lower.contains("|") || lower.contains("rm -") ||
        lower.contains("sudo ") || lower.contains("chmod ") || lower.contains("curl ")) {
        result.type = IntentType::GeneralQuery;
        result.action = "query";
        result.target = "ai_gateway";
        result.confidence = 0.50;
        emit intentRecognized(result);
        return result;
    }

    // 8. Application Launch Commands
    // Match specific apps
    auto checkApp = [&](const QStringList& patterns, const QString& appId) -> bool {
        for (const auto& p : patterns) {
            if (lower.contains(p)) {
                result.type = IntentType::AppLaunch;
                result.action = "open";
                result.target = appId;
                result.confidence = 0.95;
                return true;
            }
        }
        return false;
    };

    if (checkApp({"file manager", "files", "spatial files", "file explorer"}, "files") ||
        checkApp({"vs code", "vscode", "visual studio code", "code studio", "code editor"}, "vscode") ||
        checkApp({"android studio", "android ide", "android sdk"}, "android_studio") ||
        checkApp({"antigravity", "antigravity ide", "google antigravity", "agy"}, "antigravity") ||
        checkApp({"browser", "firefox", "chrome", "edge", "opera", "web browser", "internet"}, "browser") ||
        checkApp({"open terminal", "launch terminal", "smart terminal", "open console", "open shell", "terminal open", "console open"}, "terminal") ||
        checkApp({"calculator", "calc"}, "calculator") ||
        checkApp({"settings", "preferences", "config"}, "settings") ||
        checkApp({"robotics", "robot", "robotics space", "fleet"}, "robotics")) {
        emit intentRecognized(result);
        return result;
    }

    // 9. Fallback to General AI Query
    result.type = IntentType::GeneralQuery;
    result.action = "query";
    result.target = "ai_gateway";
    result.confidence = 0.80;
    emit intentRecognized(result);
    return result;
}

} // namespace sritec::jarvis
