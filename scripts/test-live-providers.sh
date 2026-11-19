#!/usr/bin/env bash
# ==============================================================================
# SRITEC AI OS — Phase 2.2 Live Provider Smoke Test Runner
# ==============================================================================
# Securely verifies cloud AI provider connectivity using environment variables.
# Never logs or exposes API keys.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BINARY="${PROJECT_ROOT}/build/bin/test_live_smoke"

show_help() {
    cat << EOF
SRITEC AI OS — Live Provider Smoke Test Runner

Usage:
  ./scripts/test-live-providers.sh [OPTIONS]

Options:
  --dry-run               Check environment variables and endpoint readiness without sending traffic.
  --gemini                Test Google Gemini endpoint only.
  --openai                Test OpenAI endpoint only.
  --claude                Test Anthropic Claude endpoint only.
  --all                   Test all configured providers (default).
  --approve-live-network  Explicitly authorize sending live network requests to cloud AI APIs.
  --help                  Show this help message.

Environment Variables:
  GEMINI_API_KEY          Google Gemini API key
  OPENAI_API_KEY          OpenAI API key
  ANTHROPIC_API_KEY       Anthropic Claude API key

Example (Dry Run):
  ./scripts/test-live-providers.sh --dry-run

Example (Live Execution once credentials configured):
  export GEMINI_API_KEY="AIzaSy..."
  ./scripts/test-live-providers.sh --gemini --approve-live-network
EOF
}

if [ ! -f "$BINARY" ]; then
    echo "[-] Error: Executable not found at ${BINARY}"
    echo "    Please run ./scripts/build.sh first."
    exit 1
fi

TARGET="all"
APPROVED="false"
DRY_RUN="false"

while [ $# -gt 0 ]; do
    case "$1" in
        --gemini)
            TARGET="gemini"
            shift
            ;;
        --openai)
            TARGET="openai"
            shift
            ;;
        --claude)
            TARGET="claude"
            shift
            ;;
        --all)
            TARGET="all"
            shift
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --approve-live-network)
            APPROVED="true"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "[-] Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

echo "======================================================"
echo "  SRITEC AI OS — Live Provider Smoke Test Runner"
echo "======================================================"
echo "Target Provider: ${TARGET}"

if [ "${DRY_RUN}" = "true" ] || [ "${APPROVED}" = "false" ]; then
    echo "[STATUS] Performing Dry-Run Environment Audit (No network requests sent)"
    "${BINARY}"
    if [ "${APPROVED}" = "false" ]; then
        echo ""
        echo "[!] Live network requests require explicit authorization."
        echo "    To authorize live network requests, re-run with:"
        echo "      $0 --approve-live-network"
    fi
    exit 0
fi

echo "[STATUS] Operator authorized live network testing."
"${BINARY}" --live-test-authorized --provider "${TARGET}"
