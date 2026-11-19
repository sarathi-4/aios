# SRITEC AI OS — Architectural Decision Records (ADRs)

> **Document:** `docs/DECISION_LOG.md`  
> **Status:** Permanent Project Memory  

---

### ADR-001: Standalone Desktop Application Baseline
- **Date:** 2026-11-19
- **Status:** Accepted & Implemented
- **Context:** Building a bare-metal Wayland compositor immediately would require kernel DRM/KMS privileges, display manager replacement, and risk bricking the developer machine.
- **Decision:** Build Phase 1 and 2 as a standalone high-performance Qt 6 / QML desktop window running natively on the existing Ubuntu Wayland session.
- **Consequences:** Safe, non-destructive iteration, fast feedback loops, seamless migration path to a native Wayland compositor later.

### ADR-002: Modular Decoupling (`core/`, `ai/`, `shell/`, `tests/`)
- **Date:** 2026-11-19
- **Status:** Accepted & Implemented
- **Context:** Avoiding monolithic code where UI, AI models, and system utilities are intertwined.
- **Decision:** Strict monorepo boundary separation. Core library has no Qt GUI dependencies; AI library provides abstract provider interfaces; Shell contains only presentation QML and bridges.

### ADR-003: C++20 `std::jthread` & Cancellation
- **Date:** 2026-11-19
- **Status:** Accepted & Implemented
- **Context:** Asynchronous AI streaming and network timeouts must not hang threads or cause race conditions.
- **Decision:** Use C++20 `std::jthread` with cooperative `std::stop_token` cancellation. Threads automatically request stop and join on destruction.

### ADR-004: Whitelist-First Terminal Command Guardrails
- **Date:** 2026-11-19
- **Status:** Accepted & Implemented
- **Context:** Preventing AI agents or hallucinated commands from executing destructive shell operations (`rm -rf`, `mkfs`, `dd`, `sudo`).
- **Decision:** Implement strict whitelist-first evaluation (`AIBridge::evaluateCommand`). Block shell chaining (`;`, `&`, `|`, `>`, `<`, `$`, backticks), reject destructive binaries, and keep direct shell execution disabled.

### ADR-005: Unified AI Provider Gateway with Pluggable `ITransport`
- **Date:** 2026-11-19
- **Status:** Accepted & Implemented
- **Context:** The OS must not be permanently tied to any single AI vendor. Unit tests must run 100% offline without live network or real keys.
- **Decision:** Create abstract `AIProvider` and `ITransport`. Production uses `QtNetworkTransport` (TLS 1.3 `QNetworkAccessManager`), while automated tests use `MockHttpTransport` to simulate SSE chunks and HTTP error codes.

### ADR-006: Zero-Exposure Secret Isolation & Memory Cleansing
- **Date:** 2026-11-19
- **Status:** Accepted & Implemented
- **Context:** API keys must never leak to frontend QML, logs, git commits, or memory dumps.
- **Decision:** Frontend receives only boolean `hasApiKey`. Key setters are write-only. Logs and errors pass through regex and exact-match scrubbers (`Logger::sanitize`, `KeyStore::redact`). Keys are overwritten with volatile memory zeroing before destruction (`KeyStore::secureCleanse`).

### ADR-007: Strict TLS Certificate Enforcement
- **Date:** 2026-11-19
- **Status:** Accepted & Implemented
- **Context:** Outbound requests to cloud AI providers must be protected against MITM attacks.
- **Decision:** Enforce `QSsl::SecureProtocols`. Reject self-signed or untrusted certificates (error code 495). `QNetworkReply::ignoreSslErrors()` is strictly forbidden.

### ADR-008: Nebula Immersive Home Screen (Milestone 3.1)
- **Date:** 2026-11-19
- **Status:** Accepted & Proceeding
- **Context:** Transitioning the shell from a basic window into the full NEBULA visual universe (holographic panels, floating dock, procedural canvas, AI avatar, real app launcher).
- **Decision:** Implement Milestone 3.1 with a responsive full-screen surface, animated neural background, floating dock, system telemetry widgets, universal search bar, and safe child-process application launcher (`AppLauncher`).
