# SRITEC AI OS — NEBULA
## UNIVERSAL CINEMATIC APPLICATION LAUNCH EXPERIENCE REPORT

**Feature:** Universal Cinematic Application Launch & Multi-Window Experience  
**Platform:** Ubuntu Linux 26.04.1 LTS (Kernel 7.0.0-43-generic x86_64)  
**Status:** **COMPLETED & VERIFIED (0 Warnings, 6/6 CTests Passing)**  
**Date:** 2026-11-19  

---

## 1. Executive Summary

This milestone implements a **universal, system-wide cinematic application-opening, running, and closing framework** for NEBULA. Inspired by the user-provided holographic visual references, the system replaces abrupt app switching with a unified 4-step kinetic transition: radial particle burst, holographic energy beam, expanding glass acrylic panel, and real-time interface activation.

The architecture enforces a strict, professional separation between:
1. **NEBULA Internal Applications:** Open inside floating, translucent glass window frames (`AppWindowFrame.qml`) with titlebars, minimization to dock, maximization, smooth closing, titlebar dragging, and 8-direction resizing.
2. **External Host Applications:** Launched safely via detached `QProcess` with the cinematic transition and host display server handoff, without ever presenting fake mockups or claiming unsupported Wayland compositor window control.

---

## 2. Reusable Animation & Window Architecture

```
                                  [ User Action ]
           (Desktop Icon Grid / App Dock / App Drawer / Search / Omnibar)
                                         │
                                         ▼
                 ┌───────────────────────────────────────────────┐
                 │       sritec::shell::AppLaunchManager         │
                 │  - App Registry Catalog (Internal/External)   │
                 │  - Origin Coordinates & Geometry Tracking     │
                 │  - State Machine: Burst -> Expand -> Handoff  │
                 │  - Multi-Window State (Stacking, Min, Max)    │
                 └───────┬───────────────────────────────┬───────┘
                         │                               │
        [ Internal App ] │                               │ [ External App ]
                         ▼                               ▼
       ┌──────────────────────────────────┐    ┌──────────────────────────────────┐
       │   AppLaunchTransition.qml        │    │    AppLaunchTransition.qml       │
       │   - AppTransitionEffects.qml     │    │    - Particle Burst & Laser Trail│
       │     (Particle Burst, Beam Trail) │    │    - Handoff Status Readout      │
       │   - Geometry Expansion           │    │    - Clean Screen Fading         │
       └────────────────┬─────────────────┘    └────────────────┬─────────────────┘
                        │                                       │
                        ▼                                       ▼
       ┌──────────────────────────────────┐    ┌──────────────────────────────────┐
       │     AppWindowFrame.qml           │    │   sritec::shell::AppLauncher     │
       │   - Titlebar, Min/Max/Close      │    │   - Validates Host Binary Path   │
       │   - Dragging & 8-Way Resize      │    │   - QProcess::startDetached      │
       │   - Dynamic Internal View:       │    │   - Direct Wayland Host Launch   │
       │     * SpatialFilesView           │    └──────────────────────────────────┘
       │     * SmartTerminalView          │
       │     * NeuralCalculatorView       │
       │     * SystemMonitorView          │
       │     * CodeStudioView             │
       │     * SettingsView               │
       │     * RoboticsWorkspaceView      │
       └──────────────────────────────────┘
```

---

## 3. The 4-Step Universal Launch Sequence

| Step | State | Visual Dynamics & Physics | Duration (Target: ~500–750ms) |
|:---:|:---:|:---|:---:|
| **Step 1** | **Icon Feedback & Particle Burst** | When clicked, icon coordinates `(originX, originY)` are captured. The icon highlights with cyan/violet energy while 24 radial neon particles burst outward with quadratic decay. | $0\text{–}120\text{ ms}$ |
| **Step 2** | **Energy Trail & Glass Expansion** | A holographic laser energy beam connects the origin icon to the expanding panel. The glass acrylic card expands from `(originX, originY)` to target window geometry `(targetX, targetY)` with smooth `Easing.OutCubic`. | $120\text{–}450\text{ ms}$ |
| **Step 3** | **Activation & Loading State** | Displays pulsating `AIIcon` tile with halo ring, app name, category pill, vertical laser scanline sweep, and real-time neural readout: `"ALLOCATING SANDBOX BUFFER..."` $\rightarrow$ `"INITIALIZING RUNTIME..."`. | $450\text{–}650\text{ ms}$ |
| **Step 4** | **Reveal / Host Handoff** | **Internal Apps:** Materializes live interactive `AppWindowFrame` at target geometry and fades out transition overlay.<br>**External Apps:** Displays `"HANDOFF TO HOST DISPLAY SERVER"`, spawns detached host binary, and smoothly fades out. | $\approx 650\text{–}750\text{ ms}$ |

---

## 4. Internal Applications vs External Native Applications

### A. NEBULA Internal Applications (`AppWindowFrame.qml`)
Internal applications run within NEBULA's spatial window manager:
- **Spatial Files (`files`):** Interactive file manager with breadcrumb path navigation, quick access places (Home, AIOS Workspace, Documents, Downloads, Root), folder navigation, search filter, and item metadata inspector.
- **Smart Terminal (`terminal`):** Interactive cyber command console with real interactive prompt `sarathi@nebula:~$`, command execution (`help`, `neofetch`, `status`, `diagnostics`, `ls`, `clear`, `ai <prompt>`), and LISA neural stream integration.
- **Neural Calculator (`calculator`):** Scientific and standard calculator with trigonometric/exponential functions (`sin`, `cos`, `tan`, `√`, `^`, `π`), glowing keypad, and calculation engine.
- **Hardware Diagnostics (`monitor`):** Real-time performance monitor with live gauges for CPU load, RAM allocation, NVMe storage, and active process list.
- **Code Studio (`editor`):** Code editor with line numbers gutter, syntax formatting, and language metadata.
- **System Settings (`settings`):** Personalization, wallpaper, dock configuration, and performance modes.
- **Robotics Ecosystem (`robotics`):** Multi-agent simulation suite with 6-axis kinematics and perception matrix.
- **AI Studio (`assistant`):** Multi-turn conversational AI gateway.

### B. External Native Applications (`AppLauncher::launch()`)
For native host binaries (e.g. `firefox`, `chrome`, `edge`, `opera`, `vscode`, `antigravity`, `android_studio`, `chatgpt`, `gemini`, `claude`, `codex`, `ollama`):
- The cinematic transition plays from the clicked icon coordinates.
- If installed: `QProcess::startDetached()` spawns the host process directly into the Wayland session; the transition displays `"HANDOFF TO HOST DISPLAY SERVER"` and fades out cleanly.
- If not installed: The transition detects availability and displays `"APPLICATION NOT INSTALLED ON HOST"` in amber without crashing or freezing.

---

## 5. Visual Evidence & Framebuffers

| Framebuffer Screenshot | Resolution | Description |
|:---|:---:|:---|
| [nebula_app_launch_transition.png](file:///run/media/sarathi/250-2.1/aios/docs/screenshots/nebula_app_launch_transition.png) | 1920x1080 | Active cinematic launch transition expanding from icon origin with laser energy beam, particle burst, holographic corner brackets, and neural loading badge |
| [nebula_app_window_experience.png](file:///run/media/sarathi/250-2.1/aios/docs/screenshots/nebula_app_window_experience.png) | 1920x1080 | Multi-window desktop experience showing three concurrent floating glass windows: Spatial Files, Smart Terminal, and Neural Calculator with active dock indicators |

---

## 6. Performance & Quality Verification

### Performance Modes
- **Ultra / High:** Full 24-particle radial burst, quadratic laser beam trail, scanline sweep, 60 FPS cubic easing.
- **Balanced:** 12 particles, smooth scale/opacity animations.
- **Reduced Motion:** Expansion and particle canvas disabled; instant positioning with crisp 150ms opacity crossfade.

### Automated Test Results (100% Passing)
```
Test project /run/media/sarathi/250-2.1/aios/build
    Start 1: CoreLoggerTimestampTest
1/6 Test #1: CoreLoggerTimestampTest ..........   Passed    0.06 sec
    Start 2: AISafetyAndStreamTest
2/6 Test #2: AISafetyAndStreamTest ............   Passed    0.11 sec
    Start 3: AIProviderGatewayTest
3/6 Test #3: AIProviderGatewayTest ............   Passed    0.15 sec
    Start 4: SecurityAndResilienceTest
4/6 Test #4: SecurityAndResilienceTest ........   Passed    0.86 sec
    Start 5: DesktopSystemTest
5/6 Test #5: DesktopSystemTest ................   Passed    0.03 sec
    Start 6: AppLaunchManagerTest
6/6 Test #6: AppLaunchManagerTest .............   Passed    0.01 sec

100% tests passed, 0 tests failed out of 6
Total Test time (real) = 1.23 sec
```

---

## 7. Modified & Created Files Summary

| File | Status | Description |
|:---|:---:|:---|
| `shell/src/app_launch_manager.hpp` | Created | Central AppLaunchManager C++ header with registry and window tracking |
| `shell/src/app_launch_manager.cpp` | Created | Central AppLaunchManager C++ implementation |
| `shell/qml/components/AppTransitionEffects.qml` | Created | Particle burst canvas, laser energy trail, and beam effects |
| `shell/qml/components/AppLaunchTransition.qml` | Created | 4-step cinematic transition overlay with expanding holographic panel |
| `shell/qml/components/AppWindowFrame.qml` | Created | Floating glass window container with titlebar, min/max/close, drag, resize |
| `shell/qml/views/internal/SpatialFilesView.qml` | Created | Interactive spatial file manager with breadcrumbs and inspector |
| `shell/qml/views/internal/SmartTerminalView.qml` | Created | Interactive cyber terminal emulator with built-in commands |
| `shell/qml/views/internal/NeuralCalculatorView.qml` | Created | Scientific and standard calculator with glowing keys |
| `shell/qml/views/internal/SystemMonitorView.qml` | Created | Live CPU, RAM, Disk gauges and process table |
| `shell/qml/views/internal/CodeStudioView.qml` | Created | Interactive code studio with line numbers and editor |
| `tests/unit/test_app_launch.cpp` | Created | Automated unit test suite verifying launch manager & window lifecycle |
| `tests/CMakeLists.txt` | Modified | Registered `AppLaunchManagerTest` in CTest suite |
| `shell/CMakeLists.txt` | Modified | Added `app_launch_manager` sources to `sritec-shell` |
| `shell/resources.qrc` | Modified | Registered all new QML components and internal views in RCC |
| `shell/src/main.cpp` | Modified | Instantiated `AppLaunchManager`, wired signals, added screenshot flags |
| `shell/qml/Main.qml` | Modified | Added window stack layer (z: 100), transition (z: 150), and shortcuts |
| `shell/qml/components/DesktopIconGrid.qml` | Modified | Wired icon double-click and context menu to `requestAppLaunch` |
| `shell/qml/components/AppDock.qml` | Modified | Wired dock clicks to `requestAppLaunch` with active running dots |
| `shell/qml/components/AppDrawer.qml` | Modified | Wired drawer card clicks to `requestAppLaunch` |
| `shell/qml/components/UniversalSearchOverlay.qml` | Modified | Wired search result activation to `requestAppLaunch` |
| `shell/qml/views/DesktopHomeView.qml` | Modified | Wired omnibar commands and action chips to `requestAppLaunch` |
| `docs/screenshots/nebula_app_launch_transition.png` | Created | 1920x1080 screenshot of the active launch transition |
| `docs/screenshots/nebula_app_window_experience.png` | Created | 1920x1080 screenshot of multi-window experience |
| `docs/UNIVERSAL_APP_LAUNCH_EXPERIENCE_REPORT.md` | Created | Full technical specification and integration report |
