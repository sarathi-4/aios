# SRITEC AI OS — Phase 1 Build Preparation & Toolchain Readiness

> **Document:** `docs/BUILD_PREPARATION.md`  
> **Status:** Verified & Ready for Installation Approval  
> **Host OS:** Ubuntu 26.04.1 LTS (`resolute`), x86_64, Linux Kernel 7.0.0-43-generic  
> **Execution Model:** Standalone Native Desktop Window (Wayland / X11 Session)

---

## 1. Executive Summary

This document serves as the pre-flight verification report before installing build dependencies and compiling the **SRITEC AI OS Phase 1 Digital Workspace**.

### Key Verification Highlights:
- **Zero Destructive Actions:** `setup-dev-env.sh` contains zero disk formatting, partitioning, or package removal operations. A dry-run simulation confirmed: `0 upgraded, 160 newly installed, 0 to remove`.
- **Package Name Validity:** Every package in the streamlined installation list was checked against Ubuntu 26.04's package database and verified present.
- **ISO Creation Packages Excluded:** All Phase 6 ISO creation tools (`debootstrap`, `xorriso`, `squashfs-tools`, `grub-pc-bin`, `mtools`) have been stripped from the Phase 1 setup script.
- **Source Tree Integrity:** The workspace is clean. CMake outputs will be compiled strictly into the isolated `build/` directory, ensuring zero existing source or doc files will be overwritten.

---

## 2. Verified Package List

The following packages are verified in Ubuntu 26.04 (`resolute`) and required for Phase 1 compilation and execution:

| Category | Package Name | Verified Purpose |
| :--- | :--- | :--- |
| **C++20 Toolchain** | `build-essential` | GCC compiler collection, libc-dev, make |
| | `g++` | GNU C++ compiler supporting `-std=c++20` and `std::jthread` |
| | `cmake` | Project build orchestrator (v3.25+) |
| | `ninja-build` | Multi-threaded build accelerator |
| | `pkg-config` | Package flags and dependency resolver |
| **Qt 6 Framework** | `qt6-base-dev` | Core Qt 6 runtime headers, MOC, and libraries |
| | `qt6-declarative-dev`| QML engine, QtQuick, and QML meta-object tools |
| | `qt6-tools-dev` | Qt resource compiler (`rcc`) and UI tools |
| | `qt6-tools-dev-tools`| Standalone Qt development executables |
| **QML Modules** | `qml6-module-qtquick` | Core QML visual element primitives |
| | `qml6-module-qtquick-controls` | Cybernetic UI controls, buttons, text fields |
| | `qml6-module-qtquick-templates` | Base style templates required by Controls |
| | `qml6-module-qtquick-layouts` | `RowLayout`, `ColumnLayout`, and `StackLayout` |
| | `qml6-module-qtquick-window` | Top-level `ApplicationWindow` host |
| | `qml6-module-qtquick-shapes` | Custom vector geometry and status badges |
| **Graphics & System** | `libxkbcommon-dev` | Keyboard mapping engine for Wayland/X11 |
| | `libgl1-mesa-dev` | Mesa OpenGL rendering interface |
| | `libegl1-mesa-dev` | EGL native platform interface |
| | `libdbus-1-dev` | System IPC headers for daemon communication |
| | `libsystemd-dev` | Systemd service lifecycle headers |

> [!NOTE]
> `git`, `curl`, `wget`, and `ca-certificates` are already installed on your host system and were omitted from the setup script to eliminate redundant apt transactions.

---

## 3. Package Safety & System Integrity Confirmation

1. **No Disk or Partition Modifications:** The script does not invoke `fdisk`, `parted`, `mkfs`, `mount`, or raw disk devices.
2. **No Package Removals:** An apt dry-run simulation verified that installing these development libraries does not conflict with or remove any existing software:
   ```text
   0 upgraded, 160 newly installed, 0 to remove and 36 not upgraded.
   ```
3. **No Bootloader or System Setting Changes:** The script does not touch `/boot`, GRUB configurations, PAM security modules, or system-wide display manager settings.
4. **Unprivileged Application Execution:** The compiled binary will execute as an unprivileged client application (`uid=1000`) within your current desktop session.

---

## 4. Resource & Disk Space Estimates

| Metric | Estimated Requirement | Current Host Availability | Status |
| :--- | :--- | :--- | :--- |
| **Package Download Archive** | ~260 MiB | High-speed cache | ✅ Sufficient |
| **Installed System Packages** | ~1.05 GiB on `/usr` | 16 GiB available on `/` | ✅ Plenty of headroom (93% free) |
| **Workspace Compilation (`build/`)** | ~80–120 MiB | 217 GiB free on `/run/media/...` | ✅ Massive capacity (>99% free) |
| **RAM Footprint (Build & Runtime)** | ~350 MiB RAM | 23 GiB available | ✅ Ample headroom |

---

## 5. Potential Compatibility Issues & Mitigations

1. **Wayland Client Window Rendering:**
   - **Environment:** The host session is `WAYLAND_DISPLAY: wayland-0` under GNOME.
   - **Behavior:** Qt 6 automatically chooses the `wayland` QPA (Qt Platform Abstraction) plugin. If hardware acceleration is restricted inside a sandbox or VM, Qt 6 will automatically fall back to software rendering (`QT_QUICK_BACKEND=software`) without crashing.
2. **QML Controls Styling:**
   - **Mitigation:** The application explicitly sets `QQuickStyle::setStyle("Basic")` in `shell/src/main.cpp`. Installing `qml6-module-qtquick-templates` ensures all base control templates are present, preventing missing style warnings.
3. **Theme Singleton Resolution:**
   - **Mitigation:** `shell/qml/theme/qmldir` is embedded directly into the Qt resource system (`shell/resources.qrc`), and `qmlRegisterSingletonType` is registered in `main.cpp`. This guarantees that `SRITECTheme` is available across all views regardless of relative import depth.

---

## 6. Execution Commands (Awaiting Your Review)

Per your instructions, **no installation or build commands have been executed**. When you review and approve this document, the sequence to build and run the prototype is:

### Step 1: Install Build Dependencies (Requires sudo approval)
```bash
sudo ./scripts/setup-dev-env.sh
```

### Step 2: Build the Standalone Workspace
```bash
./scripts/build.sh
```

### Step 3: Run the Automated Unit Tests
```bash
ctest --test-dir build --output-on-failure
```

### Step 4: Launch the SRITEC Desktop Application Window
```bash
./scripts/run.sh
```
