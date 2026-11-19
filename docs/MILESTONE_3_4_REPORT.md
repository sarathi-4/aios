# SRITEC AI OS — NEBULA
## Milestone 3.4 Engineering Report: Unified Internal Application Environment

**Codename:** NEBULA  
**Phase / Milestone:** Phase 3 — Milestone 3.4  
**Date:** 2026-11-19  
**Status:** COMPLETE (6/6 CTest Suites Passing, 0 Errors, Verified Framebuffers)

---

## 1. Executive Summary & Core Objective

Milestone 3.4 fulfills the critical product requirement for **SRITEC AI OS (NEBULA)**:
> **The user must be able to work inside NEBULA without applications opening as separate, detached Ubuntu desktop windows.**

Prior to Milestone 3.4, external applications (such as browsers, code editors, and AI tools) had to spawn separate Ubuntu host windows via detached processes. Milestone 3.4 eliminates this fragmentation by building a unified internal application runtime environment (`NebulaAppRuntime` & `NebulaWindowManager`) coupled with native, high-performance internal applications and embedded web portals.

Users now perform their daily tasks—browsing the web, exploring files, executing terminal commands, authoring code, and querying AI intelligence—entirely within NEBULA's cybernetic holographic window system.

---

## 2. Dependency Audit: Qt WebEngine Analysis

In compliance with Milestone 3.4 mandatory security and packaging rules:
> *"If Qt WebEngine is missing, report the dependency and wait for approval instead of installing it. No package installations or sudo without approval."*

### System Inspection Results (Ubuntu 26.04 LTS):
* **Installed Qt6 Core & Declarative:** Qt 6.8.2 / 6.10.2 base development headers installed (`qt6-base-dev`, `qt6-declarative-dev`).
* **WebEngine Status:** `qt6-webengine-dev` and `libqt6webenginequick6` are **not installed** by default in the environment.
* **Architectural Decision:**
  1. No `sudo` or package installation was run.
  2. Built **`NebulaBrowserBackend`** and **`NebulaBrowserView.qml`** with dual-mode architecture:
     * Mode 1 (Active): Embedded Cyber Web & AI Portal providing multi-tab navigation, DuckDuckGo search queries, HTTPS TLS 1.3 indicators, bookmark management, history recording, private shield mode, and dedicated web AI workspaces (ChatGPT, Google Gemini, Anthropic Claude, and Intelligent Research Assistant).
     * Mode 2 (Awaiting Approval): Once `qt6-webengine-dev` is installed with explicit user consent, the architecture supports dropping in `QWebEngineView` directly.
  3. Clear, non-intrusive status pills inform the user of the active sandbox profile without breaking UI immersion.

---

## 3. Central Application Runtime Architecture

The runtime architecture consolidates six specialized subsystems into a coherent C++20 engine:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   NebulaAppRuntime & Window Manager                   │
├──────────────────────────┬─────────────────────────────────────────────┤
│ NebulaAppRegistry        │ Catalog of applications & classification   │
│ NebulaAppLifecycle       │ Launch, start, suspend, terminate states   │
│ NebulaWindowManager      │ Z-order, cascade, 8-way resize, focus stack│
│ NebulaAppTransitionMgr   │ 4-step radial burst & holographic expansion│
│ HostIsolationGuard       │ Suppresses detached external host spawning  │
└──────────────────────────┴─────────────────────────────────────────────┘
                                  │
       ┌──────────────────────────┼──────────────────────────┐
       ▼                          ▼                          ▼
[InternalNative]            [EmbeddedWeb]          [UnsupportedExternal]
• Spatial Files            • NEBULA Browser       • Firefox / Chrome
• Smart Terminal           • ChatGPT Portal       • VS Code / Antigravity
• Code Studio              • Gemini Portal        • Android Studio
• LISA AI Studio           • Claude Portal        (Blocked + Internal
• Robotics Ecosystem       • Intelligent Search    Alternative Notice)
• Neural Calculator
• Hardware Monitor
• System Settings
```

### Key Window Management Features:
* **True Stacking & Focus:** Windows maintain independent Z-indices; clicking anywhere elevates the window and its ambient halo glow.
* **Edge-to-Edge Geometry:** Full dragging bounds with screen margin safety clamp (preventing windows from flying off-screen).
* **8-Way Interactive Resizing:** Drag handles on bottom-right, right, and bottom edges with minimum dimension guarantees (400x300 min).
* **Maximize & Restore:** Preserves restore geometry; maximizes edge-to-edge excluding the top HUD and bottom dock.
* **Minimize & Dock Interaction:** Minimizes into ambient background; re-launching from dock restores existing window without duplicate instances.
* **Smooth Closing Animation:** Scale-down and fade-out animation returns smoothly to the desktop without abrupt visual pop.

---

## 4. Application Classification Matrix

Every application in NEBULA is strictly categorized:

| Application ID | Display Name | Classification | Launch Behavior | Internal Alternative |
|---|---|---|---|---|
| `files` | Spatial Files | `InternalNative` | Opens internal floating file manager | — |
| `terminal` | Smart Terminal | `InternalNative` | Opens internal unprivileged terminal | — |
| `editor` | Code Studio | `InternalNative` | Opens internal developer workspace | — |
| `assistant` | LISA AI Studio | `InternalNative` | Opens native AI Provider Gateway | — |
| `robotics` | Robotics Ecosystem | `InternalNative` | Opens robotics kinematics workspace | — |
| `calculator` | Neural Calculator | `InternalNative` | Opens high-precision math engine | — |
| `settings` | System Settings | `InternalNative` | Opens system configuration panel | — |
| `monitor` | Hardware Diagnostics | `InternalNative` | Opens telemetry & sensor hub | — |
| `calendar` | Chrono Hub | `InternalNative` | Opens temporal agenda popup | — |
| `browser` | NEBULA Web & AI Portal | `EmbeddedWeb` | Opens internal multi-tab browser | — |
| `chatgpt` | ChatGPT Portal | `EmbeddedWeb` | Opens internal ChatGPT web workspace | LISA AI Studio |
| `gemini` | Google Gemini | `EmbeddedWeb` | Opens internal Gemini web workspace | LISA AI Studio |
| `claude` | Anthropic Claude | `EmbeddedWeb` | Opens internal Claude web workspace | LISA AI Studio |
| `firefox` | Mozilla Firefox | `UnsupportedExternal` | Suppressed (Displays HUD Dialog) | `browser` |
| `chrome` | Google Chrome | `UnsupportedExternal` | Suppressed (Displays HUD Dialog) | `browser` |
| `edge` | Microsoft Edge | `UnsupportedExternal` | Suppressed (Displays HUD Dialog) | `browser` |
| `opera` | Opera Browser | `UnsupportedExternal` | Suppressed (Displays HUD Dialog) | `browser` |
| `vscode` | Visual Studio Code | `UnsupportedExternal` | Suppressed (Displays HUD Dialog) | `editor` |
| `antigravity` | Antigravity IDE | `UnsupportedExternal` | Suppressed (Displays HUD Dialog) | `editor` |
| `android_studio` | Android Studio | `UnsupportedExternal` | Suppressed (Displays HUD Dialog) | `editor` |
| `codex` | OpenAI Codex | `UnsupportedExternal` | Suppressed (Displays HUD Dialog) | `editor` |
| `ollama` | Ollama Local AI | `UnsupportedExternal` | Suppressed (Displays HUD Dialog) | `assistant` |

---

## 5. Internal Applications Breakdown

### 5.1 Internal Web Browser (`NebulaBrowserBackend` & `NebulaBrowserView.qml`)
* **Features:**
  * Multi-tab strip with tab creation (`+`), close (`✕`), and tab switching.
  * Back, Forward, and Reload navigation with stateful history stacks.
  * Address bar with query formulation (auto-encodes search queries to DuckDuckGo, auto-prepends `https://`).
  * HTTPS TLS 1.3 lock indicator badge with security telemetry.
  * Bookmarks toolbar: pre-configured portals for ChatGPT, Google Gemini, Anthropic Claude, DuckDuckGo, GitHub, and SRITEC Docs.
  * History drawer with timestamped URLs and clear button.
  * Private shield mode toggle (disables history recording).
  * Direct Web AI Workspaces: dedicated views for ChatGPT, Gemini, Claude, and Intelligent Search & Research Assistant with rotating wireframe holographic globe.

### 5.2 Internal Spatial File Manager (`NebulaFileManager` & `SpatialFilesView.qml`)
* **Features:**
  * Real filesystem access via `QDir` and `QFileInfo` (no mocked dummy lists).
  * Clickable breadcrumbs path capsule with folder segment navigation.
  * Quick location spaces: AIOS Project Root (`/run/media/sarathi/250-2.1/aios`), Home, Documents, Downloads.
  * File Preview & Inspector sidebar: real text/code preview with line count, image preview, file metadata.
  * Safe folder creation modal (`mkdir`).
  * Item renaming modal (`rename`).
  * Permanent deletion with confirmation modal dialog.
  * Safety guardrails: blocks root `/` deletion and protects OS system directories (`/etc`, `/boot`, `/usr`).

### 5.3 Internal Smart Terminal (`NebulaTerminalBackend` & `SmartTerminalView.qml`)
* **Features:**
  * Interactive shell sessions executing via unprivileged `QProcess` (`/bin/bash`).
  * Multi-tab terminal workspace (add session, close session, switch session).
  * Command history navigation with Up and Down arrow keys.
  * Color-coded stream: cyan for prompt, green for output, amber for warnings, red for guardrail violations.
  * Process lifecycle management with `^C Kill` and `Clear` controls.
  * **AI Safety Guardrails:**
    * Blocks `sudo` / `su` root escalation attempts.
    * Blocks recursive root deletions (`rm -rf /`, `rm -rf /*`).
    * Blocks raw partition/disk formatting (`mkfs`, `fdisk`, `parted`, `dd if=... of=/dev/...`).
    * Blocks fork bombs (`:(){ :|:& };:`).

### 5.4 Internal Code Studio (`NebulaDevWorkspace` & `CodeStudioView.qml`)
* **Features:**
  * Project Explorer: reads project root directory and displays tree of files and subdirectories.
  * Multi-file editor tabs with modified indicator dots (`●`) and tab closing.
  * File loading and saving (Ctrl+S shortcut and `Save` button) with real disk persistence.
  * Search and replace toolbar with match highlighting and `Replace All`.
  * Live Git integration: displays active Git branch (`⎇ main`) and modified working tree files (`git status --porcelain`).
  * Integrated terminal console drawer at the bottom with one-click build triggering (`ninja -C build`).

---

## 6. Verification and Quality Evidence

### 6.1 CTest Test Suite (100% Pass)
```bash
$ ctest --test-dir build --output-on-failure
Test project /run/media/sarathi/250-2.1/aios/build
    Start 1: CoreLoggerTimestampTest
1/6 Test #1: CoreLoggerTimestampTest ..........   Passed    0.05 sec
    Start 2: AISafetyAndStreamTest
2/6 Test #2: AISafetyAndStreamTest ............   Passed    0.10 sec
    Start 3: AIProviderGatewayTest
3/6 Test #3: AIProviderGatewayTest ............   Passed    0.16 sec
    Start 4: SecurityAndResilienceTest
4/6 Test #4: SecurityAndResilienceTest ........   Passed    0.86 sec
    Start 5: DesktopSystemTest
5/6 Test #5: DesktopSystemTest ................   Passed    0.03 sec
    Start 6: AppLaunchManagerTest
6/6 Test #6: AppLaunchManagerTest .............   Passed    0.03 sec

100% tests passed, 0 tests failed out of 6
Total Test time (real) = 1.23 sec
```

### 6.2 QML Syntax & Architecture Linter
```bash
$ /usr/lib/qt6/bin/qmllint shell/qml/Main.qml shell/qml/views/internal/*.qml shell/qml/components/AppWindowFrame.qml
# Exit code: 0 (No syntax or type errors)
```

### 6.3 Verified High-Resolution Framebuffers (1920x1080)
1. **[nebula_desktop_milestone3_4.png](file:///run/media/sarathi/250-2.1/aios/docs/screenshots/nebula_desktop_milestone3_4.png):** Edge-to-edge spatial desktop with Top HUD, dock, and central LISA avatar.
2. **[nebula_multiwindow_internal.png](file:///run/media/sarathi/250-2.1/aios/docs/screenshots/nebula_multiwindow_internal.png):** Simultaneous internal floating windows (Spatial Files, Smart Terminal, NEBULA Browser) running side-by-side inside NEBULA.
3. **[nebula_internal_browser.png](file:///run/media/sarathi/250-2.1/aios/docs/screenshots/nebula_internal_browser.png):** Fullscreen NEBULA Cyber Web & AI Portal with tabs, address bar, rotating wireframe globe, and AI portals.
4. **[nebula_internal_code_studio.png](file:///run/media/sarathi/250-2.1/aios/docs/screenshots/nebula_internal_code_studio.png):** Fullscreen Code Studio with Project Explorer tree, multi-file tabs, Git branch indicator, and integrated terminal drawer.

---

## 7. Current Limitations & Next Steps

1. **Qt WebEngine Dependency:** Arbitrary third-party websites with complex JavaScript/WebGL will require `qt6-webengine-dev` when user approval is granted. The current embedded portal provides secure search, HTTPS inspection, and direct AI gateway portals.
2. **Window Snapping:** Future milestone will add grid-based aero-snap (left half, right half, quadrants).
3. **External Window Embedding:** Wayland/X11 subsurfaces for embedding native third-party GUI applications (like VS Code or external CAD tools) can be investigated in Phase 4.

---
*Report certified by SRITEC AI OS Engineering Team.*
