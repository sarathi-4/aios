# SRITEC AI OS — Phase 1 Code Quality & Security Audit

> **Audit Date:** 2026-11-19  
> **Target:** Phase 1 Scaffolding, Core Libraries, Mock AI Subsystem, Desktop Shell & Scripts  
> **Auditor:** Antigravity AI Engineering Engine  
> **Audit Status:** COMPLETED — Action Required Before Compilation & Phase 2

---

## 1. Executive Summary

A comprehensive code quality, concurrency, security, and build readiness audit was performed across all Phase 1 source files, build configurations, and scripts. 

### Key Findings Overview:
- **Build Readiness:** **BLOCKED**. The host development environment lacks basic C++ compilers (`gcc`/`g++`), build tools (`cmake`, `ninja`), and Qt 6 development libraries. The project cannot compile until these packages are installed.
- **CMake & Qt Meta-Object Compilation:** **3 Critical Deficiencies**. `CMAKE_AUTOMOC` and `CMAKE_AUTORCC` are missing. Without them, Qt MOC and resource compilation will fail immediately during build.
- **QML Runtime Architecture:** **1 Critical Blocker**. `SRITECTheme.qml` declares `pragma Singleton` without an accompanying `qmldir` or C++ registration, which causes a fatal QML engine runtime crash at startup.
- **Concurrency & Thread Safety:** **2 Significant Issues**. `MockAIProvider` spawns detached threads capturing `this`, risking Use-After-Free crashes during object destruction or re-entrant queries.
- **Security & Command Guardrails:** **1 Major Vulnerability**. The command safety classifier relies on a simple keyword blacklist with a `SAFE` fallback, allowing command injection and evasion via shell chaining, argument reordering, or interpreter invocation.

---

## 2. Files Inspected

| Category | File Path | Status |
| :--- | :--- | :--- |
| **Build System** | `CMakeLists.txt` | Missing `AUTOMOC`, `AUTORCC`, and modern Qt6 component checks |
| **Compiler Config** | `cmake/CompilerWarnings.cmake` | Incompatible `-Wold-style-cast` with Qt6 headers |
| **Core Module** | `core/CMakeLists.txt` | Passed |
| **Core Headers** | `core/include/sritec/common.hpp` | Passed |
| **Core Logging** | `core/include/sritec/logger.hpp` | Minor non-thread-safe `std::localtime` warning |
| **Core Impl** | `core/src/logger.cpp` | Needs POSIX `localtime_r` |
| **AI Module** | `ai/CMakeLists.txt` | Missing `AUTOMOC` for `AIBridge` |
| **AI Headers** | `ai/include/sritec/ai/ai_provider.hpp` | Clean interface |
| **Mock Provider** | `ai/include/sritec/ai/mock_provider.hpp` | Thread management needs `std::jthread` |
| **Mock Impl** | `ai/src/mock_provider.cpp` | Detached thread Use-After-Free risk |
| **AI Bridge** | `ai/include/sritec/ai/ai_bridge.hpp` | Clean QObject interface |
| **AI Bridge Impl** | `ai/src/ai_bridge.cpp` | Flawed command safety blacklist; queued method safety |
| **Shell App** | `shell/CMakeLists.txt` | Missing `AUTOMOC` and `AUTORCC` |
| **Shell Main** | `shell/src/main.cpp` | Missing singleton registration for `SRITECTheme` |
| **Resources** | `shell/resources.qrc` | Missing `qmldir` entry |
| **QML Main** | `shell/qml/Main.qml` | Clean layout; depends on theme resolution |
| **QML Theme** | `shell/qml/theme/SRITECTheme.qml` | Missing `qmldir` definition |
| **QML Components**| `shell/qml/components/NavSidebar.qml` | Clean |
| **QML Telemetry** | `shell/qml/components/StatusPanel.qml` | Clean |
| **QML Views** | `shell/qml/views/AIAssistantView.qml` | Minor ScrollView contentWidth binding loop risk |
| **QML Views** | `shell/qml/views/DeveloperWorkspaceView.qml` | Terminal log auto-scroll missing; empty command safety |
| **Tests** | `tests/CMakeLists.txt` & `tests/unit/test_core.cpp`| Clean smoke test |
| **Dev Scripts** | `scripts/build.sh` | Clean |
| **Dev Scripts** | `scripts/run.sh` | Clean |
| **Dev Scripts** | `scripts/setup-dev-env.sh` | Contains unnecessary Phase 6 ISO creation packages |
| **Dev Scripts** | `scripts/verify-scaffolding.py` | Verified non-destructive execution |

---

## 3. Bugs & Deficiencies Found

### Bug 3.1: Missing Qt MOC and Resource Processing in CMake (Build Breaker)
- **Location:** `CMakeLists.txt`, `ai/CMakeLists.txt`, `shell/CMakeLists.txt`
- **Issue:** In `ai/include/sritec/ai/ai_bridge.hpp`, `class AIBridge : public QObject` contains the `Q_OBJECT` macro, properties, signals, and slots. In `shell/resources.qrc`, embedded QML resources must be compiled by `rcc`. However, neither `set(CMAKE_AUTOMOC ON)` nor `set(CMAKE_AUTORCC ON)` is enabled in CMake.
- **Impact:** Compiling the project will fail with linker errors:
  ```text
  undefined reference to `vtable for sritec::ai::AIBridge'
  undefined reference to `sritec::ai::AIBridge::staticMetaObject'
  ```
- **Correction:** Enable `CMAKE_AUTOMOC`, `CMAKE_AUTORCC`, and `CMAKE_AUTOUIC` globally in the root `CMakeLists.txt` or per target.

---

### Bug 3.2: QML Singleton Crash: `pragma Singleton` without `qmldir` (Runtime Breaker)
- **Location:** `shell/qml/theme/SRITECTheme.qml`, `shell/resources.qrc`, `shell/src/main.cpp`
- **Issue:** `SRITECTheme.qml` begins with `pragma Singleton`. In Qt 6 QML, a QML file with `pragma Singleton` cannot be resolved simply via `import "../theme"` or `import "theme"` without a corresponding `qmldir` file that explicitly declares:
  ```text
  singleton SRITECTheme 1.0 SRITECTheme.qml
  ```
  Additionally, this `qmldir` must be listed in `resources.qrc`.
- **Impact:** When `engine.load("qrc:/qml/Main.qml")` executes, the QML engine will abort with:
  ```text
  QQmlApplicationEngine failed to load component
  qrc:/qml/theme/SRITECTheme.qml: pragma Singleton: Singletons must be declared in a qmldir file
  ```
- **Correction:** Add `shell/qml/theme/qmldir` declaring the singleton, include it in `resources.qrc`, or register `SRITECTheme` via `qmlRegisterSingletonType` in `shell/src/main.cpp`.

---

### Bug 3.3: Use-After-Free in Asynchronous Thread in `MockAIProvider` (Crash / UB)
- **Location:** `ai/src/mock_provider.cpp` (lines 48–60)
- **Issue:** `MockAIProvider::streamQuery` executes:
  ```cpp
  std::thread([this, fullResponse, onToken]() {
      // reads m_cancelled
  }).detach();
  ```
  The thread is detached and captures `this`. If the user cancels the generation, switches views, or closes the application, the `MockAIProvider` (and its parent `AIBridge`) will be destroyed while the thread is sleeping (`std::this_thread::sleep_for(25ms)`). When the thread wakes up, accessing `this->m_cancelled` triggers a Use-After-Free memory fault.
- **Impact:** Intermittent segmentation faults upon rapid cancellation or application exit.
- **Correction:** Replace detached threads with a joinable `std::jthread` (C++20) that uses `std::stop_token` and is joined during `MockAIProvider` destruction.

---

### Bug 3.4: Re-entrancy Stream Interleaving in `MockAIProvider`
- **Location:** `ai/src/mock_provider.cpp`
- **Issue:** Calling `streamQuery` resets `m_cancelled = false` globally. If a query is already running, starting a second query un-cancels the active loop, causing two concurrent background threads to simultaneously pump tokens into `onToken`.
- **Impact:** Garbled, interleaved token streams in the UI.
- **Correction:** Automatically cancel and join any active worker thread before starting a new streaming session.

---

### Bug 3.5: Compiler Warning Noise: `-Wold-style-cast` on Qt Headers
- **Location:** `cmake/CompilerWarnings.cmake`
- **Issue:** `-Wold-style-cast` is applied to targets including Qt headers. Qt's internal templates and macros (`Q_OBJECT`, `Q_PROPERTY`, `Q_ARG`) contain numerous C-style casts.
- **Impact:** Hundreds of non-actionable compiler warnings will flood build logs.
- **Correction:** Mark Qt include directories as `SYSTEM` or remove `-Wold-style-cast` from targets linking to Qt.

---

### Bug 3.6: Non-Thread-Safe `std::localtime` in `Logger`
- **Location:** `core/src/logger.cpp` (line 19)
- **Issue:** `std::localtime(&in_time_t)` uses a static, non-thread-safe internal buffer. While the call is currently guarded by `Logger::m_mutex`, any future extraction or parallel log formatting can cause race conditions.
- **Correction:** Replace with POSIX `localtime_r(&in_time_t, &timeStruct)` or C++20 standard chrono formatting.

---

## 4. Security Review & Analysis

### 4.1 Terminal Command Safety Classifier Flaw (HIGH RISK)
- **Location:** `ai/src/ai_bridge.cpp` (`checkCommandSafety`)
- **Vulnerability:** The current implementation uses a naive keyword blacklist:
  ```cpp
  if (cmd.contains("rm -rf") || cmd.contains("mkfs") || ...) return "DANGEROUS...";
  if (cmd.startsWith("sudo") || cmd.contains("chmod") || ...) return "SENSITIVE...";
  return "SAFE...";
  ```
- **Attack Vectors / Evasion Scenarios:**
  1. **Flag Permutations:** `rm -r -f /` or `rm --recursive --force /` does not contain `"rm -rf"` and is classified as **SAFE**.
  2. **Alternative Destructive Binaries:** `shred -u /file`, `wipefs -a /dev/sda`, `truncate -s 0`, `blkdiscard /dev/nvme0n1` are classified as **SAFE**.
  3. **Shell Chaining & Metacharacters:** `echo "test" && rm -rf /` or `ls; rm -rf /` or `eval $(echo cm0gLXJmIC8= | base64 -d)` or `python3 -c "import os; os.system('rm -rf /')"` are not properly parsed.
  4. **Empty Command Fallthrough:** Passing an empty string returns **SAFE**.
- **Security Mandate:**
  - **Invert the paradigm: Default to SENSITIVE/UNVETTED, not SAFE.**
  - An explicit **whitelist** must be used for `SAFE` operations (purely read-only developer commands without pipes, redirections, or substitutions: `git status`, `git log`, `pwd`, `ls`, `whoami`, `uptime`, `date`).
  - Any command containing shell chaining characters (`;`, `&&`, `||`, `|`, `&`, `>`, `<`, `$`, `` ` ``, `\n`) or invoking language interpreters (`sh`, `bash`, `python`, `perl`) must be marked as `SENSITIVE` or `DANGEROUS`.
  - Destructive filesystem commands must be flagged `DANGEROUS: BLOCKED`.

---

### 4.2 API Key Exposure Check (PASSED)
- **Audit:** Searched all files across `shell/`, `ai/`, and `core/` for hardcoded API keys, tokens, or network endpoints.
- **Result:** **PASSED**. No API keys exist. The frontend communicates exclusively with the local `AIBridge`.

---

### 4.3 Unrestricted AI Shell Execution Check (PASSED IN PROTOTYPE)
- **Audit:** Verified whether the smart terminal in `DeveloperWorkspaceView.qml` executes commands directly.
- **Result:** **PASSED**. The terminal prototype only simulates execution by appending formatted logs to the console window. No `QProcess`, `system()`, or `popen()` calls exist in the codebase.

---

## 5. Build Readiness & Host Environment Status

```text
Toolchain Inspection (Host: Ubuntu 26.04.1 LTS x86_64):
-------------------------------------------------------
  python3   : /usr/bin/python3 (v3.14.4)  [AVAILABLE]
  git       : /usr/bin/git (v2.48.1)      [AVAILABLE]
  gcc       : NOT INSTALLED               [MISSING]
  g++       : NOT INSTALLED               [MISSING]
  clang     : NOT INSTALLED               [MISSING]
  cmake     : NOT INSTALLED               [MISSING]
  ninja     : NOT INSTALLED               [MISSING]
  qmake6    : NOT INSTALLED               [MISSING]
```

### Build Readiness Verdict:
**BLOCKED.** The application cannot compile in the current environment because the C++ compiler (`g++`), build system (`cmake`, `ninja`), and Qt 6 SDK packages are absent.

### Review of `scripts/setup-dev-env.sh`:
- **Issue:** The script currently includes ISO generation packages (`debootstrap`, `xorriso`, `squashfs-tools`, `grub-pc-bin`, `mtools`).
- **Correction:** Per the user's rule (*"Do not create the bootable ISO yet. Do not install unnecessary software"*), these packages should be decoupled and removed from the Phase 1 setup script.
- **Recommendation:** `setup-dev-env.sh` should be streamlined strictly to Phase 1 dependencies:
  - `build-essential`, `g++`, `cmake`, `ninja-build`, `pkg-config`
  - `qt6-base-dev`, `qt6-declarative-dev`, `qml6-module-qtquick*`

---

## 6. Required Corrections Checklist (For Approval)

Before proceeding to compilation or Phase 2, the following fixes are prepared and awaiting user approval:

- [ ] **Fix 1 (CMake):** Add `set(CMAKE_AUTOMOC ON)`, `set(CMAKE_AUTORCC ON)`, and `set(CMAKE_AUTOUIC ON)` in root `CMakeLists.txt`.
- [ ] **Fix 2 (CMake Warnings):** Adjust `-Wold-style-cast` in `cmake/CompilerWarnings.cmake` to avoid warnings from Qt headers.
- [ ] **Fix 3 (QML Singleton):** Create `shell/qml/theme/qmldir` declaring `SRITECTheme`, register it in `shell/resources.qrc`, and export it in `main.cpp`.
- [ ] **Fix 4 (Threading):** Refactor `MockAIProvider::streamQuery` to use joinable `std::jthread` with cancellation tokens, eliminating the detached thread Use-After-Free risk.
- [ ] **Fix 5 (Security Guardrail):** Invert `checkCommandSafety` to a whitelist-first model; flag all shell metacharacters, pipes, and interpreters as sensitive/dangerous.
- [ ] **Fix 6 (Logging):** Use `localtime_r` in `core/src/logger.cpp`.
- [ ] **Fix 7 (Setup Script):** Remove unnecessary Phase 6 ISO creation tools from `scripts/setup-dev-env.sh`.

---

*Audit completed strictly in read-only inspection mode. No host modifications, package installations, or automatic file fixes were applied.*
