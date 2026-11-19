# SRITEC AI OS — Architecture Specification

> **Codename:** NEBULA  
> **System Class:** AI-Native Intelligent Operating Environment  
> **Target Platform:** Linux Desktop (Wayland / X11), expanding to multi-platform adapters  
> **Primary Frameworks:** C++20, Qt 6 (Core, Gui, Qml, Quick, QuickControls2, Network), Native Platform Bridges  
> **Execution Model:** Standalone Native Desktop Shell with clean modular decoupling for full Wayland compositor transition  

---

## 1. Architectural Principles & 100-Year Vision

SRITEC AI OS is engineered as an adaptable, living operating environment. Rather than tying the operating system to volatile vendor APIs, it enforces strict layer isolation, abstract interfaces, and portable open data standards:

1. **Replaceable Implementations:** UI rendering, window management, AI models, and storage engines are decoupled behind abstract interfaces.
2. **AI-Native Integration with Human Primacy:** Neural assistance, intent parsing, semantic search, and workflow automation are available across the desktop, but AI agents are strictly bounded by human-in-the-loop authorization.
3. **Zero-Exposure Credential Security:** Credentials and API keys exist strictly in secure memory or OS keyrings; frontend QML components and logs never receive or display secrets.
4. **Offline Autonomy:** Complete functional resilience when disconnected from the internet. Local inference (Ollama, local mock models) and deterministic offline utilities are first-class peers to cloud services.
5. **Decoupled Compositor Migration:** The desktop environment executes as a standalone client window during initial phases, designed so the same UI components and system services migrate into a custom Wayland compositor without re-architecture.

---

## 2. High-Level Subsystem Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                     NEBULA PRESENTATION LAYER (shell/)                 │
│                                                                        │
│   ┌──────────────────────────────────────────────────────────────┐     │
│   │  Immersive Desktop Surface (Full-Screen Responsive Canvas)    │     │
│   │  • Procedural Neural Wave & Particle Engine                  │     │
│   │  • Interactive Cursor Glow & Dynamics                        │     │
│   │  • Floating Holographic Application Dock                     │     │
│   │  • Universal Search & Command Bar ("Ask anything...")        │     │
│   │  • Holographic AI Presence (Avatar / Telemetry)              │     │
│   │  • System Gauges: Clock, CPU, RAM, Disk, Network             │     │
│   │  • Workspace Views: AI Assistant, Developer Studio, Settings │     │
│   └──────────────────────────────┬───────────────────────────────┘     │
└──────────────────────────────────┼─────────────────────────────────────┘
                                   │ Q_PROPERTY, Q_INVOKABLE & Signals
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   INTEGRATION & PLATFORM LAYER                         │
│                                                                        │
│   ┌──────────────────────────────┐ ┌───────────────────────────────┐   │
│   │ sritec::ai::AIBridge         │ │ sritec::platform::AppLauncher │   │
│   │ • Multiplexes AI models      │ │ • Discovers installed apps    │   │
│   │ • Whitelist Command Safety   │ │ • Safe unprivileged execution │   │
│   │ • Telemetry & State Binding  │ │ • Process lifecycle & status  │   │
│   └──────────────┬───────────────┘ └───────────────┬───────────────┘   │
└──────────────────┼─────────────────────────────────┼───────────────────┘
                   ▼                                 ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   UNIFIED AI PROVIDER GATEWAY (ai/)                    │
│                                                                        │
│   ┌──────────────────────────────────────────────────────────────┐     │
│   │ sritec::ai::ProviderManager                                  │     │
│   │ • Multi-turn conversation buffer                             │     │
│   │ • Dynamic model switching & health monitoring                │     │
│   └──────┬───────────────┬───────────────┬───────────────┬───────┘     │
│          ▼               ▼               ▼               ▼             │
│   ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│   │MockProvider │ │GeminiProvide│ │OpenAIProvide│ │ClaudeProvide│      │
│   │(C++20 Local)│ │(REST / SSE) │ │(REST / SSE) │ │(Anthropic)  │      │
│   └─────────────┘ └──────┬──────┘ └──────┬──────┘ └──────┬──────┘      │
│                          └───────────────┼───────────────┘             │
│                                          ▼                             │
│                           ┌─────────────────────────────┐              │
│                           │  ITransport (Network Layer) │              │
│                           │  • QtNetworkTransport (Live)│              │
│                           │  • MockHttpTransport (Test) │              │
│                           └─────────────────────────────┘              │
├────────────────────────────────────────────────────────────────────────┤
│                       SECURE STORAGE SUBSYSTEM                         │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │ sritec::ai::KeyStore                                           │   │
│   │ • In-Memory Write-Only secret storage                          │   │
│   │ • Automated regex & exact-match secret redaction               │   │
│   │ • Volatile memory cleansing (`secureCleanse`)                  │   │
│   └────────────────────────────────────────────────────────────────┘   │
├────────────────────────────────────────────────────────────────────────┤
│                       CORE UTILITIES & LOGGING (core/)                 │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │ sritec::Logger                                                 │   │
│   │ • Thread-safe POSIX `localtime_r` logging                      │   │
│   │ • Automated token & credential redaction                       │   │
│   └────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Subsystem Breakdown

### 3.1 Shell & Immersive Desktop (`shell/`)
- **`Main.qml`:** Root desktop environment. Supports normal windowed and full-screen immersive modes.
- **`SRITECTheme.qml`:** Design token singleton defining the NEBULA visual identity (Deep Space Void `#070A0F`, Surface `#0D111A`, Elevated `#131A28`, Electric Cyan `#00E5FF`, Neon Blue `#2563EB`, Emerald `#00F5A0`, Amber `#FFB800`, Crimson `#FF3B5C`).
- **`AIAssistantView.qml`:** Multi-model neural assistant view supporting streaming chat, provider and model selection pills, write-only API key configuration, and error recovery actions.
- **`DeveloperWorkspaceView.qml`:** Smart terminal console with whitelist-first command safety validation, simulated execution, and project module tree.
- **`StatusPanel.qml`:** System telemetry header bar tracking workspace mode, active AI model, latency, sandbox status, and real-time clock.

### 3.2 Unified AI Gateway (`ai/`)
- **`AIProvider`:** Pure virtual interface requiring `streamChat`, `cancel`, `health`, and model capability discovery.
- **`ProviderManager`:** Coordinates provider registration, model selection, multi-turn conversation memory, and asynchronous dispatch.
- **`KeyStore`:** Mutex-protected key storage with automatic environment ingestion (`GEMINI_API_KEY`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`), volatile zeroing on key replacement, and automated string redaction.
- **`ITransport` / `QtNetworkTransport`:** Network abstraction enforcing TLS 1.2+ certificate validation and a 15-second transfer timeout.

### 3.3 Platform & Application Launcher (`platform/`)
- **`AppLauncher`:** Discovers installed desktop applications on the host Linux system (browsers, editors, terminals) and executes them using `QProcess` with argument tokenization without invoking a shell.

### 3.4 Core Engine (`core/`)
- **`Logger`:** Thread-safe logger formatting timestamps via `localtime_r` and scrubbing credentials via `Logger::sanitize()`.
- **`Common`:** Version constants, platform flags, and global type aliases.
