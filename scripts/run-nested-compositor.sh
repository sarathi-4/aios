#!/usr/bin/env bash
# ==============================================================================
# SRITEC AI OS — Nested Compositor Launch Helper
# Runs the custom Wayland Compositor inside an existing Wayland/X11 session
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BINARY="${PROJECT_ROOT}/build/bin/sritec-compositor"

if [ ! -f "$BINARY" ]; then
    echo "[-] Error: ${BINARY} does not exist."
    echo "    Please run ./scripts/build.sh first."
    exit 1
fi

echo "======================================================"
echo "  Launching SRITEC AI OS Compositor (Nested Mode)"
echo "======================================================"
echo "Host WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-None}"
echo "Host DISPLAY:         ${DISPLAY:-None}"

# Use a distinct socket name for client applications launched inside SRITEC OS
export SRITEC_WAYLAND_SOCKET="wayland-sritec-0"

# Enable Qt Wayland client debugging if requested
export QT_LOGGING_RULES="sritec.*=true;qt.wayland*=warning"

echo "[+] Starting sritec-compositor on socket: ${SRITEC_WAYLAND_SOCKET}"
"${BINARY}" --socket "${SRITEC_WAYLAND_SOCKET}" "$@"
