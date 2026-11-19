# SRITEC AI OS — Phase 2.2 Live Provider Smoke Test Plan

> **Document:** `docs/PHASE2_2_LIVE_TEST_PLAN.md`  
> **Date:** 2026-11-19  
> **Scope:** Google Gemini, OpenAI, Anthropic Claude, Local Ollama  
> **Safety Level:** STRICT OPERATOR APPROVAL REQUIRED BEFORE NETWORK TRANSMISSION  

---

## 1. Safety Principles & Zero-Exposure Policy

1. **Zero Secret Hardcoding:** Never paste API keys into source files, QML code, documentation, scripts, or Git commits.
2. **Environment Ingestion:** Secrets must be provided strictly through temporary environment variables in your personal terminal session or via the write-only settings drawer in the desktop UI.
3. **Opt-In Network Execution:** No live network calls will be made unless the `--approve-live-network` flag is explicitly passed to the smoke test runner.

---

## 2. Pre-Flight Verification (Dry-Run)

Before exporting any credentials, verify that the smoke test runner binary and script are ready:

```bash
./scripts/test-live-providers.sh --dry-run
```

**Expected Output:**
```text
======================================================
  SRITEC AI OS — Live Provider Smoke Test Runner
======================================================
Target Provider: all
[STATUS] Performing Dry-Run Environment Audit (No network requests sent)
======================================================
  SRITEC AI OS — Live Provider Smoke Test Suite
======================================================
[ENV AUDIT]
  • GEMINI_API_KEY:    [NOT SET]
  • OPENAI_API_KEY:    [NOT SET]
  • ANTHROPIC_API_KEY: [NOT SET]

[SAFETY NOTICE]
  Live network requests are BLOCKED by default.
  To run live tests once credentials are configured, execute:
    ./scripts/test-live-providers.sh --approve-live-network
======================================================
```

---

## 3. Step-by-Step Smoke Test Procedures

### Test 1: Google Gemini Live Smoke Test

1. **Configure Credential in your terminal:**
   ```bash
   export GEMINI_API_KEY="AIzaSyYourActualGeminiKeyHere"
   ```
2. **Execute Smoke Test:**
   ```bash
   ./scripts/test-live-providers.sh --gemini --approve-live-network
   ```
3. **Verification Criteria:**
   - [ ] HTTP status 200 returned.
   - [ ] SSE chunks parsed successfully (`candidates[0].content.parts[0].text`).
   - [ ] No API keys printed in terminal output.
   - [ ] Token received successfully.

---

### Test 2: OpenAI Live Smoke Test

1. **Configure Credential in your terminal:**
   ```bash
   export OPENAI_API_KEY="sk-proj-YourActualOpenAIKeyHere"
   ```
2. **Execute Smoke Test:**
   ```bash
   ./scripts/test-live-providers.sh --openai --approve-live-network
   ```
3. **Verification Criteria:**
   - [ ] HTTP status 200 returned.
   - [ ] SSE chunks parsed successfully (`choices[0].delta.content`).
   - [ ] Stream terminates cleanly on `[DONE]` signal.
   - [ ] No API keys printed in terminal output.

---

### Test 3: Anthropic Claude Live Smoke Test

1. **Configure Credential in your terminal:**
   ```bash
   export ANTHROPIC_API_KEY="sk-ant-api03-YourActualClaudeKeyHere"
   ```
2. **Execute Smoke Test:**
   ```bash
   ./scripts/test-live-providers.sh --claude --approve-live-network
   ```
3. **Verification Criteria:**
   - [ ] HTTP status 200 returned.
   - [ ] SSE event `content_block_delta` parsed successfully.
   - [ ] Header `anthropic-version: 2023-06-01` accepted.
   - [ ] No API keys printed in terminal output.

---

### Test 4: All Configured Providers at Once

```bash
./scripts/test-live-providers.sh --all --approve-live-network
```

---

### Test 5: Local Ollama Live Smoke Test (Optional)

1. **Start Ollama Daemon (in a separate terminal):**
   ```bash
   ollama serve
   ```
2. **Ensure target model is pulled:**
   ```bash
   ollama pull llama3.2
   ```
3. **Launch Desktop UI and select Ollama:**
   ```bash
   ./scripts/run.sh
   ```
   Select `Local AI (Ollama)` in the Provider bar and send a query.
4. **Verification Criteria:**
   - [ ] Streaming response received from `localhost:11434`.
   - [ ] If Ollama daemon is stopped, UI gracefully reports `Connection refused` (error 503) and offers "Switch to Offline Mock" button.

---

## 4. Post-Test Credential Cleanliness

After testing in your terminal session, clear the environment variables:
```bash
unset GEMINI_API_KEY
unset OPENAI_API_KEY
unset ANTHROPIC_API_KEY
```
