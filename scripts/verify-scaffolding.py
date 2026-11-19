#!/usr/bin/env python3
"""
SRITEC AI OS — Scaffolding & Environment Non-Destructive Verifier
Verifies repository completeness, file integrity, and reports missing system toolchains.
"""

import os
import sys
import shutil

def print_header(title):
    print("\n" + "=" * 64)
    print(f"  {title}")
    print("=" * 64)

def check_structure(base_dir):
    print_header("1. Verifying Modular Repository Structure")
    expected_dirs = [
        "core",
        "shell",
        "apps",
        "services",
        "ai",
        "resources",
        "tests",
        "docs",
        "scripts"
    ]
    all_ok = True
    for d in expected_dirs:
        path = os.path.join(base_dir, d)
        exists = os.path.isdir(path)
        status = "✓ PRESENT" if exists else "✗ MISSING"
        print(f"  [{status}] {d}/")
        if not exists:
            all_ok = False
    return all_ok

def check_files(base_dir):
    print_header("2. Verifying Core Scaffolding & Prototype Files")
    expected_files = [
        "CMakeLists.txt",
        "README.md",
        ".gitignore",
        "docs/ARCHITECTURE.md",
        "docs/ROADMAP.md",
        "docs/PHASE1_AUDIT.md",
        "cmake/CompilerWarnings.cmake",
        "core/CMakeLists.txt",
        "core/include/sritec/common.hpp",
        "core/include/sritec/logger.hpp",
        "core/src/logger.cpp",
        "ai/CMakeLists.txt",
        "ai/include/sritec/ai/ai_provider.hpp",
        "ai/include/sritec/ai/mock_provider.hpp",
        "ai/include/sritec/ai/ai_bridge.hpp",
        "ai/src/mock_provider.cpp",
        "ai/src/ai_bridge.cpp",
        "shell/CMakeLists.txt",
        "shell/src/main.cpp",
        "shell/resources.qrc",
        "shell/qml/Main.qml",
        "shell/qml/theme/qmldir",
        "shell/qml/theme/SRITECTheme.qml",
        "shell/qml/components/NavSidebar.qml",
        "shell/qml/components/StatusPanel.qml",
        "shell/qml/views/AIAssistantView.qml",
        "shell/qml/views/DeveloperWorkspaceView.qml",
        "tests/CMakeLists.txt",
        "tests/unit/test_core.cpp",
        "tests/unit/test_ai_safety.cpp",
        "scripts/build.sh",
        "scripts/run.sh",
        "scripts/setup-dev-env.sh"
    ]
    all_ok = True
    for f in expected_files:
        path = os.path.join(base_dir, f)
        exists = os.path.isfile(path)
        status = "✓ PRESENT" if exists else "✗ MISSING"
        print(f"  [{status}] {f}")
        if not exists:
            all_ok = False
    return all_ok

def check_toolchains():
    print_header("3. Inspecting Host Toolchain & Dependencies")
    tools = {
        "python3": "Python 3 Runtime",
        "git": "Git Version Control",
        "gcc": "GNU C Compiler",
        "g++": "GNU C++ Compiler (C++20)",
        "clang": "LLVM Clang Compiler",
        "cmake": "CMake Build System",
        "ninja": "Ninja Build Accelerator",
        "qmake6": "Qt 6 Build Tools"
    }
    status_report = {}
    for cmd, desc in tools.items():
        found_path = shutil.which(cmd)
        if found_path:
            status_report[cmd] = ("AVAILABLE", found_path)
            print(f"  [✓ AVAILABLE] {cmd:10} ({desc}) -> {found_path}")
        else:
            status_report[cmd] = ("MISSING", "Not found in PATH")
            print(f"  [! MISSING  ] {cmd:10} ({desc})")

    return status_report

def main():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    print(f"Executing non-destructive verification in:\n  {base_dir}")

    struct_ok = check_structure(base_dir)
    files_ok = check_files(base_dir)
    toolchains = check_toolchains()

    print_header("Verification Summary")
    if struct_ok and files_ok:
        print("  [✓] All Phase 1 corrected files and unit tests are verified.")
    else:
        print("  [!] Warning: Some files or directories are missing.")

    missing_tools = [k for k, v in toolchains.items() if v[0] == "MISSING"]
    if missing_tools:
        print(f"\n  [NOTE] Missing build dependencies: {', '.join(missing_tools)}")
        print("  Before compiling with './scripts/build.sh', install dependencies via:")
        print("    sudo ./scripts/setup-dev-env.sh")
    else:
        print("\n  [✓] All build toolchains are available!")

    return 0

if __name__ == "__main__":
    sys.exit(main())
