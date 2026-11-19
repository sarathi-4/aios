#include "sritec/ai/key_store.hpp"
#include "sritec/ai/transport.hpp"
#include "sritec/ai/gemini_provider.hpp"
#include "sritec/ai/openai_provider.hpp"
#include "sritec/ai/claude_provider.hpp"
#include "sritec/logger.hpp"

#include <QCoreApplication>
#include <iostream>
#include <string>
#include <vector>
#include <memory>

using namespace sritec::ai;

int main(int argc, char* argv[]) {
    QCoreApplication app(argc, argv);

    std::cout << "======================================================\n";
    std::cout << "  SRITEC AI OS — Live Provider Smoke Test Suite\n";
    std::cout << "======================================================\n";

    bool authorized = false;
    std::string targetProvider = "all";

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--live-test-authorized") {
            authorized = true;
        } else if (arg == "--provider" && i + 1 < argc) {
            targetProvider = argv[++i];
        }
    }

    // Inspect environment keys without printing them
    bool hasGemini = KeyStore::instance().hasKey(ProviderType::Gemini);
    bool hasOpenAI = KeyStore::instance().hasKey(ProviderType::OpenAI);
    bool hasClaude = KeyStore::instance().hasKey(ProviderType::Claude);

    std::cout << "[ENV AUDIT]\n";
    std::cout << "  • GEMINI_API_KEY:    " << (hasGemini ? "[CONFIGURED IN ENVIRONMENT]" : "[NOT SET]") << "\n";
    std::cout << "  • OPENAI_API_KEY:    " << (hasOpenAI ? "[CONFIGURED IN ENVIRONMENT]" : "[NOT SET]") << "\n";
    std::cout << "  • ANTHROPIC_API_KEY: " << (hasClaude ? "[CONFIGURED IN ENVIRONMENT]" : "[NOT SET]") << "\n";

    if (!authorized) {
        std::cout << "\n[SAFETY NOTICE]\n";
        std::cout << "  Live network requests are BLOCKED by default.\n";
        std::cout << "  To run live tests once credentials are configured, execute:\n";
        std::cout << "    ./scripts/test-live-providers.sh --approve-live-network\n";
        std::cout << "======================================================\n";
        return 0;
    }

    std::cout << "\n[LIVE SMOKE TEST AUTHORIZED BY OPERATOR]\n";

    auto transport = std::make_shared<QtNetworkTransport>();

    auto runSmoke = [&](AIProvider& provider, const std::string& name, bool hasKey) {
        std::cout << "\n>>> Testing " << name << " (" << provider.currentModel() << ")... \n";
        if (!hasKey) {
            std::cout << "    [-] Skipped: No API key found in environment for " << name << ".\n";
            return;
        }

        std::vector<ChatMessage> history = {
            {MessageRole::User, "Reply with 'SRITEC_AI_VALIDATED'"}
        };

        bool received = false;
        std::string fullResponse;

        provider.streamChat(
            history,
            [&](const std::string& token, bool finished) {
                fullResponse += token;
                if (!token.empty()) received = true;
                if (finished) app.quit();
            },
            [&](int code, const std::string& err) {
                std::cout << "    [-] Error (" << code << "): " << KeyStore::instance().redact(err) << "\n";
                app.quit();
            },
            [&]() {
                app.quit();
            }
        );

        app.exec();

        if (received) {
            std::cout << "    [✓] " << name << " Live Stream Succeeded!\n";
            std::cout << "        Sample Response: " << fullResponse.substr(0, 60) << "...\n";
        } else {
            std::cout << "    [-] " << name << " Live Stream did not complete.\n";
        }
    };

    if (targetProvider == "all" || targetProvider == "gemini") {
        GeminiProvider gemini(transport);
        runSmoke(gemini, "Google Gemini", hasGemini);
    }

    if (targetProvider == "all" || targetProvider == "openai") {
        OpenAIProvider openai(transport);
        runSmoke(openai, "OpenAI", hasOpenAI);
    }

    if (targetProvider == "all" || targetProvider == "claude") {
        ClaudeProvider claude(transport);
        runSmoke(claude, "Anthropic Claude", hasClaude);
    }

    std::cout << "\n======================================================\n";
    std::cout << "  Live Provider Smoke Test Complete\n";
    std::cout << "======================================================\n";
    return 0;
}
