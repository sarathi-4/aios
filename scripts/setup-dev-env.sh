#!/usr/bin/env bash
# ==============================================================================
# SRITEC AI OS — Phase 1 Development Environment Setup Script
# Ubuntu 24.04 / 26.04 LTS Compatible
# Strictly installs Phase 1 Standalone Desktop Application dependencies
# ==============================================================================

set -euo pipefail

echo "======================================================"
echo "  SRITEC AI OS: Phase 1 Toolchain Setup"
echo "======================================================"

# Ensure script is executed with superuser privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "[-] Error: This script must be run as root (or via sudo) to install system packages."
    echo "    Usage: sudo ./scripts/setup-dev-env.sh"
    exit 1
fi

echo "[+] Updating apt package index..."
apt-get update -y

echo "[+] Installing core C++20 build toolchain and compilers..."
apt-get install -y --no-install-recommends \
    build-essential \
    g++ \
    cmake \
    ninja-build \
    pkg-config

echo "[+] Installing Qt 6 framework and QML modules for Phase 1 desktop..."
apt-get install -y --no-install-recommends \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-tools-dev \
    qt6-tools-dev-tools \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-templates \
    qml6-module-qtquick-layouts \
    qml6-module-qtquick-window \
    qml6-module-qtquick-shapes

echo "[+] Installing graphics and system runtime libraries..."
apt-get install -y --no-install-recommends \
    libxkbcommon-dev \
    libgl1-mesa-dev \
    libegl1-mesa-dev \
    libdbus-1-dev \
    libsystemd-dev

echo "======================================================"
echo "  [✓] Phase 1 development dependencies successfully configured!"
echo "  Note: ISO build packages (debootstrap, xorriso) are deferred to Phase 6."
echo "  You can now build SRITEC AI OS using: ./scripts/build.sh"
echo "======================================================"
