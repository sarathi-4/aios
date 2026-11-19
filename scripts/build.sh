#!/usr/bin/env bash
# ==============================================================================
# SRITEC AI OS — Build Script
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_ROOT}/build"
BUILD_TYPE="${1:-Debug}"

echo "======================================================"
echo "  Building SRITEC AI OS (${BUILD_TYPE})"
echo "======================================================"

if ! command -v cmake >/dev/null 2>&1; then
    echo "[-] Error: cmake not found. Please run ./scripts/setup-dev-env.sh first."
    exit 1
fi

GENERATOR="Unix Makefiles"
if command -v ninja >/dev/null 2>&1; then
    GENERATOR="Ninja"
fi

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

echo "[+] Configuring with CMake (${GENERATOR})..."
cmake -G "${GENERATOR}" \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    "${PROJECT_ROOT}"

echo "[+] Compiling SRITEC AI OS..."
cmake --build . --parallel "$(nproc)"

echo "======================================================"
echo "  [✓] Build completed successfully!"
echo "  Binaries are located in: ${BUILD_DIR}/bin"
echo "======================================================"
