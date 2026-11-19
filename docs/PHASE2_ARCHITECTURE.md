# SRITEC AI OS — Phase 2 Architecture: Unified AI Provider Gateway

> **Document:** `docs/PHASE2_ARCHITECTURE.md`  
> **Date:** 2026-11-19  
> **Scope:** Phase 2.1 Unified AI Provider Gateway  
> **Framework:** C++20, Qt 6 (Core, Network, Qml, Quick), QML  
> **Design Pattern:** Abstract Provider Factory with Pluggable Network Transports & Secure Key Isolation

---

## 1. Architectural Vision

Phase 2 transitions SRITEC AI OS from a single-provider mock demonstrator to a **Unified AI Provider Gateway**. This gateway provides an extensible, asynchronous, streaming communication layer capable of multiplexing queries across local and multi-cloud AI backends while enforcing strict enterprise security boundaries.

### Core Principles
1. **Provider Agnostic UI:** The chat interface, developer workspace, and system services interact with an abstract gateway (`AIProvider`). Adding new models or vendors (e.g., DeepSeek, Groq, custom fine-tuned on-premise models) requires zero modifications to the UI layer.
2. **Strict Secret Isolation (Zero API Key Leakage):**
   - API keys and tokens are stored exclusively in the C++ backend / OS secure store.
   - Frontend QML code **never receives, reads, or caches** raw API keys. QML only receives boolean status flags (`hasApiKey: true/false`).
   - Network requests are generated and dispatched strictly in C++ worker threads.
3. **Pluggable Transports & Testability:**
   - Network interactions are decoupled behind an `ITransport` abstraction.
   - Production uses `QtNetworkTransport` (`QNetworkAccessManager` with TLS 1.3).
   - Unit testing uses `MockHttpTransport` to verify SSE streaming, cancellation, token parsing, and HTTP error handling (401, 429, 500, 504 timeouts) completely offline without internet or real API keys.
4. **Resilience & Thread Safety:**
   - Full cancellation support via C++20 `std::stop_token` and `QNetworkReply::abort()`.
   - Thread-safe message history tracking (`ChatMessage` struct with role, content, and token counts).
   - Health and connection telemetry (`Ready`, `Streaming`, `Error`, `NeedsKey`, `Disconnected`).

---

## 2. High-Level Gateway Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                        QML PRESENTATION LAYER                          │
│                                                                        │
│   ┌──────────────────────────────────────────────────────────────┐     │
│   │  AIAssistantView.qml                                         │     │
│   │  • Provider Selector: [Mock ▾] [Gemini ▾] [OpenAI ▾] [Claude]│     │
│   │  • Model Selector:    [gemini-2.0-flash / gpt-4o / sonnet]   │     │
│   │  • Status Pill:       [READY (4ms) / STREAMING / ERROR]      │     │
│   │  • Key Configuration: [Enter Key Modal (Write-Only to C++)]  │     │
│   └──────────────────────────────┬───────────────────────────────┘     │
└──────────────────────────────────┼─────────────────────────────────────┘
                                   │ Q_PROPERTY & Q_INVOKABLE
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   C++ INTEGRATION LAYER (ai/)                          │
│                                                                        │
│   ┌──────────────────────────────────────────────────────────────┐     │
│   │  sritec::ai::AIBridge (QObject)                              │     │
│   │  • Translates QML calls to ProviderManager                   │     │
│   │  • Dispatches signals (tokenReceived, stateChanged, error)   │     │
│   │  • Exposes active conversation context and telemetry         │     │
│   └──────────────────────────────┬───────────────────────────────┘     │
│                                  ▼                                     │
│   ┌──────────────────────────────────────────────────────────────┐     │
│   │  sritec::ai::ProviderManager                                 │     │
│   │  • Registry of active and available AI providers             │     │
│   │  • Conversation memory & history buffer                      │     │
│   │  • KeyStore integration (loads from env/secure store)        │     │
│   └──────┬───────────────────────┼───────────────────────┬───────┘     │
│          │                       │                       │             │
│          ▼                       ▼                       ▼             │
│   ┌───────────────┐       ┌───────────────┐       ┌───────────────┐    │
│   │MockAIProvider │       │GeminiProvider │       │OpenAIProvider │    │
│   │(C++20 Thread) │       │(REST/SSE)     │       │(REST/SSE)     │    │
│   └───────────────┘       └───────┬───────┘       └───────┬───────┘    │
│                                   │                       │            │
│   ┌───────────────┐       ┌───────┴───────┐               │            │
│   │ClaudeProvider │       │OllamaProvider │               │            │
│   │(Anthropic SSE)│       │(Local REST)   │               │            │
│   └──────┬────────┘       └───────┬───────┘               │            │
│          │                        │                       │            │
│          └────────────────────────┼───────────────────────┘            │
│                                   ▼                                    │
│                 ┌───────────────────────────────────┐                  │
│                 │      ITransport (Abstraction)     │                  │
│                 └─────────┬───────────────┬─────────┘                  │
│                           ▼               ▼                            │
│                 ┌─────────────────┐ ┌─────────────────┐                │
│                 │QtNetworkTransport│ │MockHttpTransport│                │
│                 │(Production HTTP)│ │(Unit Testing)   │                │
│                 └─────────────────┘ └─────────────────┘                │
├────────────────────────────────────────────────────────────────────────┤
│                       SECURE STORAGE SUBSYSTEM                         │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │ sritec::ai::SecureKeyStore                                     │   │
│   │ • Reads OS Environment Variables (GEMINI_API_KEY, etc.)        │   │
│   │ • Reads ~/.config/sritec/keys.json (0600 mode)                 │   │
│   │ • In-memory encrypted buffer (Write-Only to Frontend)          │   │
│   └────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Data Structures & Interfaces

### 3.1 Chat Message & Context
```cpp
enum class MessageRole {
    System,
    User,
    Assistant
};

struct ChatMessage {
    MessageRole role;
    std::string content;
    std::string timestamp;
    int estimatedTokens{0};
};
```

### 3.2 Provider Types & Health States
```cpp
enum class ProviderType {
    Mock,
    Gemini,
    OpenAI,
    Claude,
    Ollama
};

enum class ConnectionState {
    Disconnected,
    Ready,
    Connecting,
    Streaming,
    Error
};

struct ProviderHealth {
    ConnectionState state{ConnectionState::Ready};
    std::string statusMessage{"Ready"};
    int latencyMs{0};
    bool hasKey{false};
};
```

### 3.3 Abstract `AIProvider` Interface
```cpp
class AIProvider {
public:
    virtual ~AIProvider() = default;

    virtual ProviderType type() const = 0;
    virtual std::string providerName() const = 0;
    virtual std::string currentModel() const = 0;
    virtual std::vector<std::string> availableModels() const = 0;
    virtual void setModel(const std::string& modelId) = 0;

    virtual void streamChat(
        const std::vector<ChatMessage>& history,
        TokenCallback onToken,
        ErrorCallback onError,
        CompleteCallback onComplete
    ) = 0;

    virtual void cancel() = 0;
    virtual ProviderHealth health() const = 0;
};
```

---

## 4. Provider Implementation Details

### 4.1 Mock AI Provider (Preserved & Enhanced)
- **Engine:** C++20 `std::jthread` with `std::stop_token`.
- **Purpose:** 100% offline development, CI/CD testing, instant feedback.
- **Latency:** Configurable (default 15–25ms per token).
- **Credentials:** Zero keys required.

### 4.2 Google Gemini Provider
- **Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/{model}:streamGenerateContent?alt=sse`
- **Models:** `gemini-2.0-flash`, `gemini-1.5-pro`, `gemini-1.5-flash`.
- **Format:** Server-Sent Events (SSE), JSON payload containing `contents` with `role: "user" | "model"` and `parts: [{"text": ...}]`.
- **Auth Header:** `x-goog-api-key: {KEY}` (isolated in C++).

### 4.3 OpenAI Provider
- **Endpoint:** `https://api.openai.com/v1/chat/completions`
- **Models:** `gpt-4o`, `gpt-4o-mini`, `o1-mini`.
- **Format:** SSE chunks `data: {"choices":[{"delta":{"content":"..."}}]}`, terminated by `data: [DONE]`.
- **Auth Header:** `Authorization: Bearer {KEY}`.

### 4.4 Anthropic Claude Provider
- **Endpoint:** `https://api.anthropic.com/v1/messages`
- **Models:** `claude-3-5-sonnet-20241022`, `claude-3-5-haiku-20241022`, `claude-3-opus-20240229`.
- **Format:** SSE events `event: content_block_delta`, `data: {"delta":{"text":"..."}}`.
- **Headers:** `x-api-key: {KEY}`, `anthropic-version: 2023-06-01`.

### 4.5 Local Ollama Provider
- **Endpoint:** `http://localhost:11434/api/chat`
- **Models:** `llama3`, `mistral`, `codellama`, `qwen2.5-coder`.
- **Format:** Ndjson / streaming JSON response `{"message":{"content":"..."},"done":false}`.
- **Credentials:** Local unauthenticated loopback.

---

## 5. Security & Secret Isolation Model

```
                ┌───────────────────────────────────┐
                │          QML Frontend             │
                │  • Has key? -> true/false         │
                │  • Set key("sk-...") -> write-only│
                └─────────────────┬─────────────────┘
                                  │ (No read-back API)
                                  ▼
                ┌───────────────────────────────────┐
                │       SecureKeyStore (C++)        │
                │  • In-memory std::string          │
                │  • Never logged or serialized     │
                │  • Read-only to HTTP headers      │
                └─────────────────┬─────────────────┘
                                  ▼
                ┌───────────────────────────────────┐
                │        Outgoing HTTP Header       │
                │  Authorization: Bearer [REDACTED] │
                └───────────────────────────────────┘
```

1. **No QML Reflection:** `AIBridge` provides `hasKey(provider)` as a boolean. There is no property or method that returns the secret key to JavaScript/QML.
2. **Environment Variable Precedence:** Checks `GEMINI_API_KEY`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY` before checking user configurations.
3. **Guardrail Protection:** Even with live models, AI-generated terminal commands remain strictly intercepted by the Phase 1 whitelist-first guardrail before any potential execution.
