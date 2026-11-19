# SRITEC AI OS — Intelligent Digital Workspace

> **An original, AI-native operating system workspace built on Ubuntu Linux, Qt 6, QML, and C++.**

---

## 🌟 Project Vision

SRITEC AI OS re-imagines digital productivity through an AI-first operating system workspace. In Version 0.1 (Phase 1), the OS experience is delivered as a high-performance native desktop window running on Ubuntu Wayland/X11, featuring an original futuristic visual identity, a central AI assistant, and a developer workspace with safety guardrails.

---

## 🏛️ Architecture Highlights (Phase 1 & Phase 2.1)

1. **Standalone Desktop Application:** Runs natively inside standard Ubuntu desktop sessions without replacing the display manager or modifying system files.
2. **Modular Monorepo Architecture:** Decoupled architecture (`core/`, `ai/`, `shell/`, `apps/`, `services/`, `resources/`, `docs/`, `scripts/`, `tests/`) ready to transition to a full Wayland compositor in future phases.
3. **Unified AI Provider Gateway (Phase 2.1):** Abstract provider gateway supporting Google Gemini, OpenAI, Anthropic Claude, Local Ollama, and local Mock AI with SSE streaming, model switching, and offline testability.
4. **Zero-Exposure Key Isolation:** API keys are never exposed in frontend QML code. Keys are held exclusively in backend C++ memory or auto-detected from environment variables.
5. **Whitelist-First Command Guardrails:** Shell commands require safety evaluation against a strict read-only whitelist before simulation. Dangerous utilities and metacharacters are strictly rejected.

---

## 📁 Repository Structure

```text
aios/
├── core/               # Shared C++ libraries: Common types, Logger, Config
├── ai/                 # AI provider abstraction, Mock provider, and Qt AI Bridge
├── shell/              # Qt 6 / QML Standalone Desktop Workspace application
│   ├── src/            # C++ entrypoint and QML registration
│   ├── qml/            # Main window and responsive layout
│   │   ├── theme/      # Original SRITEC dark futuristic palette & styling
│   │   ├── components/ # Sidebar, Status panel, buttons, meters
│   │   └── views/      # AI Assistant & Developer Workspace views
│   └── resources.qrc   # Embedded QML and styling resources
├── apps/               # Modular application blueprints (Terminal, Files, etc.)
├── services/           # Background system service blueprints (Daemons)
├── resources/          # Icons, vector graphics, and visual assets
├── docs/               # ARCHITECTURE.md, ROADMAP.md, and specifications
├── scripts/            # Build, run, and non-destructive verification scripts
└── tests/              # Unit and integration test suites
```

---

## 🚀 Getting Started

### 1. Requirements
- Ubuntu 24.04 or 26.04 LTS
- C++20 compiler (`g++` or `clang`)
- `cmake` (>= 3.25) and `ninja-build`
- `qt6-base-dev`, `qt6-declarative-dev`, `qml6-module-qtquick*`

### 2. Verify Scaffolding (Non-Destructive)
Run the automated validation script to verify the workspace structure:
```bash
python3 scripts/verify-scaffolding.py
```

### 3. Build & Run
When dependencies are installed:
```bash
./scripts/build.sh
./scripts/run.sh
```

---
© 2026 SRITEC AI OS Team. All Rights Reserved.
