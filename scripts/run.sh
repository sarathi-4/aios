#!/usr/bin/env bash
# ==============================================================================
# SRITEC AI OS — Desktop Application Runner
# Launches the standalone SRITEC digital workspace in the current desktop window
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BINARY="${PROJECT_ROOT}/build/bin/sritec-shell"

if [ ! -f "$BINARY" ]; then
    echo "[-] Error: Executable not found at ${BINARY}"
    echo "    Please run ./scripts/build.sh first."
    exit 1
fi

echo "======================================================"
echo "  Launching SRITEC AI OS Digital Workspace (Phase 2.1)"
echo "======================================================"
echo "Host Display:  ${WAYLAND_DISPLAY:-${DISPLAY:-None}}"
echo "Binary Target: ${BINARY}"

if [ -z "${WAYLAND_DISPLAY:-}" ] && [ -z "${DISPLAY:-}" ] && [ -z "${QT_QPA_PLATFORM:-}" ]; then
    echo "[!] Notice: No graphical display detected (WAYLAND_DISPLAY and DISPLAY unset)."
    echo "    If running in a headless or sandbox environment, run:"
    echo "      QT_QPA_PLATFORM=offscreen ./scripts/run.sh"
fi

exec "${BINARY}" "$@"
