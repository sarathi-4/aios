# SRITEC AI OS — Milestone 3.2 Engineering Report
## Codename: NEBULA — Complete Desktop Experience

> **Document:** `docs/MILESTONE_3_2_REPORT.md`  
> **Date:** 2026-11-19  
> **Target Platform:** Ubuntu Linux 26.04.1 LTS (Kernel 7.0.0-43-generic x86_64)  
> **Repository:** `/run/media/sarathi/250-2.1/aios`  
> **Milestone Status:** **[COMPLETED & VERIFIED]** (5/5 CTest suites passing, 100% test pass rate)  

---

## 1. Executive Summary

Milestone 3.2 transitions the SRITEC AI OS (NEBULA) home screen from a visual showcase into a genuinely usable, persistent, high-performance desktop operating environment. All 10 functional domains specified in the engineering roadmap have been implemented, verified, and integrated into the native C++20 and Qt 6/QML application architecture.

### Verification Baseline & Test Results

```
Test project /run/media/sarathi/250-2.1/aios/build
    Start 1: CoreLoggerTimestampTest
1/5 Test #1: CoreLoggerTimestampTest ..........   Passed    0.05 sec
    Start 2: AISafetyAndStreamTest
2/5 Test #2: AISafetyAndStreamTest ............   Passed    0.10 sec
    Start 3: AIProviderGatewayTest
3/5 Test #3: AIProviderGatewayTest ............   Passed    0.15 sec
    Start 4: SecurityAndResilienceTest
4/5 Test #4: SecurityAndResilienceTest ........   Passed    0.86 sec
    Start 5: DesktopSystemTest
5/5 Test #5: DesktopSystemTest ................   Passed    0.03 sec

100% tests passed, 0 tests failed out of 5
Total Test time (real) = 1.20 sec
```

- **Compiler & Linker:** 0 warnings, 0 errors under GCC 15.2 with `-std=c++20 -Wall -Wextra -Wpedantic`.
- **QML Lint & Runtime:** 0 syntax errors, 0 binding loops, 0 runtime warnings on startup.
- **Offscreen Execution:** Clean startup and shutdown verified via `QT_QPA_PLATFORM=offscreen`.

---

## 2. Functional Domains Implementation Matrix

### Domain 1: Desktop Icon System (`DesktopIconGrid.qml`, `desktop_manager.cpp`)
- **Real Desktop Items:** Manages application shortcuts, folder shortcuts, and project links.
- **Interactive Repositioning:** Drag-and-drop repositioning with automatic 20px grid snapping.
- **Context Menus:**
  - *Item Context Menu:* Open, Rename (with inline editor), Pin to Dock, Delete.
  - *Desktop Surface Context Menu:* New Folder, New Application Shortcut, Change Wallpaper, Desktop Settings, Reset Default Icons.
- **State Persistence:** All item coordinates, custom folders, and shortcuts persist across sessions via `QSettings` (`sritec::shell::DesktopManager`).

### Domain 2: Application Launcher (`AppDrawer.qml`)
- **Dynamic Drawer:** Accessible via the dock launcher button (9-dot icon `▦`) with fluid slide-up animation.
- **Category Filtering:** Filter by `All`, `Productivity`, `Development`, `System`, `Utilities`, and `Recent`.
- **Real Executable Detection:** Scans host paths via `AppLauncher::isAvailable()`:
  - Installed apps (`/usr/bin/firefox`, `/usr/bin/ptyxis`, `/usr/bin/nautilus`, `/usr/bin/gnome-text-editor`, `/usr/bin/gnome-control-center`, `/usr/bin/gnome-calculator`) display `INSTALLED` badge and active launch trigger.
  - Uninstalled apps clearly display `UNAVAILABLE` badge with disabled launch triggers.
- **Dock Pinning:** 1-click pin/unpin toggle button directly on every application card.

### Domain 3: Wallpaper Engine (`NeuralBackground.qml`, `SettingsView.qml`)
- **Procedural Animated Canvas:** Mathematical harmonic sinusoidal wave generator with interactive mouse deflection and particle field.
- **Intensity Control:** Live slider controlling wave amplitude and particle speed (0.1x to 1.5x) via `DesktopManager::wallpaperIntensity`.
- **Static Image Support:** Allows selecting a local image file with aspect ratio scaling: `Fill` (PreserveAspectCrop), `Fit` (PreserveAspectFit), `Stretch`, and `Tile`.
- **Performance Modes:** Dynamically toggles between `Ultra` (60fps + particles), `Balanced` (30fps), `Low`, and `Reduced Motion` (static CSS grid).

### Domain 4: Top System Panel (`StatusPanel.qml`)
- **Workspace Breadcrumb:** Live active workspace title indicator.
- **Unified AI Gateway Pill:** Displays current provider, model, streaming status, and latency.
- **Real Hardware Mini-Indicators:** Wired Ethernet status (`🖧`), volume/mute status (`🔊`/`🔇`), desktop AC power (`🔌`).
- **Interactive Live Clock:** Clicking date/time opens the month calendar popup.
- **Notification Bell:** Live unread count badge counter that opens the Notification Center.
- **Quick Settings Trigger:** Fast flyout button for hardware status.
- **Fullscreen Mode:** F11 / window button toggle between maximized desktop and windowed view.

### Domain 5: Quick Settings Panel (`QuickSettingsPanel.qml`)
- **Strict Hardware Honesty (Zero Fake Controls):**
  - *Network:* Wired Ethernet (`eno1`) active (1 Gbps); Wi-Fi explicitly marked `Unavailable`.
  - *Bluetooth:* Explicitly marked `Not Supported (No Bluetooth Adapter)`.
  - *Audio:* Real functional volume slider (0–100%) and mute toggle.
  - *Display Brightness:* Explicitly marked `Not Supported (External Desktop Display)`.
  - *Power:* Explicitly marked `Desktop AC Power (No Battery Detected)`.
- **Performance Profile Selector:** 1-click toggles between `Low`, `Balanced`, `Ultra`, and `Reduced Motion`.
- **Settings Shortcut:** Direct navigation link to the full System Settings workspace.

### Domain 6: Notification Center (`NotificationCenter.qml`)
- **Slide-out Drawer:** Smooth right-edge slide-over drawer with backdrop blur.
- **Categorized Cards:** Real-time alert cards with type-colored accents:
  - `security` (Crimson `#FF3B5C`)
  - `warning` (Amber `#FFB800`)
  - `success` (Emerald `#00F5A0`)
  - `info` (Cyan `#00E5FF`)
- **Management:** Individual dismiss button per card, "Clear All" button, and Do Not Disturb (DND) toggle.
- **Empty State:** High-tech hologram graphic when no notifications are pending.

### Domain 7: Interactive Calendar Popup (`CalendarPopup.qml`)
- **Header:** Full current date formatting and live digital clock.
- **Navigation:** Previous/Next month controls.
- **Day Grid:** 7-column weekday layout with automatic day computation and today highlighted in Cyan.
- **Milestone Tracker:** Banner displaying verified engineering milestones.

### Domain 8: Universal Search Engine (`UniversalSearchOverlay.qml`)
- **Global Shortcut:** Instant activation via `Ctrl+Space` or search icons.
- **Multi-Source Indexing:**
  - Installed system applications (`AppLauncher`)
  - Desktop shortcuts and user folders (`DesktopManager`)
  - Project workspace files scanned recursively via `QDirIterator`
- **Keyboard Navigation:** Arrow Up/Down navigation, Enter to open, Esc to dismiss.
- **Strict Truth:** Zero hallucinations; only returns genuine filesystem paths and registered binaries.

### Domain 9: Application Dock Customization (`AppDock.qml`)
- **Launcher Integration:** Built-in 9-dot button `▦` opening `AppDrawer`.
- **Dynamic Sizing:** Supports `small` (36px), `medium` (44px), and `large` (52px) item dimensions.
- **Multi-Edge Positioning:** Re-anchors smoothly to `bottom`, `left`, or `right` screen edge via Qt Quick `AnchorChanges`.
- **Right-Click Actions:** Context menu on pinned dock items to unpin or launch.
- **Auto-Hide:** Configurable auto-hide option saved in `QSettings`.

### Domain 10: System Settings Application (`SettingsView.qml`)
- **Dedicated Preferences Workspace (Tab 3):**
  - *Appearance:* 5 cyberpunk accent colors (Cyan, Violet, Emerald, Amber, Pink), glass opacity slider, font scale slider (80%–150%).
  - *Wallpaper Engine:* Procedural wave intensity slider, custom image file path, scaling mode selector.
  - *Application Dock:* Screen position, icon size, auto-hide toggle.
  - *Desktop & Icons:* Folder creation, shortcut creation, icon layout reset.
  - *Hardware & Diagnostics:* Ubuntu 26.04 identity, Linux kernel 7.0, CPU/RAM/Disk stats, hardware capability matrix.
  - *AI Gateway Configuration:* Instant provider switching between Mock, Google Gemini, OpenAI, Anthropic Claude, and Ollama.
  - *Factory Reset:* "Reset Defaults" restoring default NEBULA preferences.

### Domain 11: Multi-Workspace System (`Main.qml`, `NavSidebar.qml`)
- **Preserved State Switching:**
  - Workspace 0: `Desktop Space` (Nebula Desktop + Icon Grid + Telemetry)
  - Workspace 1: `AI Neural Hub` (LISA Neural Assistant + Multi-Provider Gateway)
  - Workspace 2: `Dev Workspace` (Developer Studio + Whitelist Command Guardrail)
  - Workspace 3: `System Settings` (SettingsView personalization & hardware controls)
  - Workspace 4: `System Telemetry` (Real-time sensor diagnostics)
  - Workspace 5: `Security & Policy` (Strict sandbox & guardrail rules)

---

## 3. Host Hardware Profile & Telemetry Audit

During testing on the development host, the hardware probing logic in `DesktopManager::detectHardwareCapabilities()` reported the following hardware matrix:

| Hardware Component | Kernel / System Path | Detected Value | UI Presentation Strategy |
|--------------------|----------------------|----------------|--------------------------|
| **Power / Battery** | `/sys/class/power_supply` | Empty | Displayed as `Desktop AC Power (No Battery Detected)` |
| **Display Backlight** | `/sys/class/backlight` | Empty | Explicitly disabled; marked `Not Supported (External Desktop Display)` |
| **Network Interface** | `/sys/class/net/eno1` | Active (1 Gbps) | Displayed as `Wired Network • eno1 Active` |
| **Wireless Adapter** | `/sys/class/net/wl*` | None | Explicitly disabled; marked `Unavailable (Using Wired Ethernet eno1)` |
| **Bluetooth Controller** | `rfkill list` | Empty | Explicitly disabled; marked `Not Supported (No Bluetooth Adapter)` |
| **Audio Output** | PulseAudio / ALSA | Active (75%) | Functional volume slider and mute toggle |

**Architectural Integrity (ADR-008):** Under no circumstances does NEBULA simulate non-existent hardware. Laptop controls (battery gauges, screen backlight sliders, Wi-Fi toggles) are accurately reported as unavailable when running on a desktop workstation.

---

## 4. Security & Safety Compliance

1. **Zero Shell Command Execution in QML:**
   - All executable launches flow exclusively through `QProcess::startDetached()` in C++ (`AppLauncher::launch()`), using structured argument lists. No raw shell (`sh -c`) is invoked.
2. **Command Whitelist Guardrails:**
   - The developer workspace terminal enforces whitelist-only execution (`ls`, `pwd`, `date`, `uptime`, `whoami`, `uname`, `cat /etc/os-release`, `echo`). Redirection, chaining (`&&`, `||`, `;`), pipes (`|`), and substitutions (`$(...)`) are strictly rejected.
3. **Secret Isolation:**
   - No API keys exist in QML properties, settings files, logs, or UI trees. Only a boolean `hasApiKey` flag is exposed to the frontend.
4. **Host OS & Partition Protection:**
   - No root mutations, package modifications, or partition operations are permitted.

---

## 5. Next Steps — Phase 4 Preparation

With Milestone 3.2 completed, verified, and audited:
- **Phase 4 Goal:** Native Application Architecture & Package Management Adapters (APT, Flatpak, Snap).
- **Core Requirements:**
  - Create native sandboxed application runner abstractions.
  - Implement read-only package search and status inspection without modifying system packages.
  - Design application lifecycle management (start, monitor, terminate).
