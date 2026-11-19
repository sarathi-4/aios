# SRITEC AI OS — 11-Layer Quality Engineering & Testing Strategy

> **Document:** `docs/TEST_STRATEGY.md`  
> **Policy:** ZERO FAKE TESTS. No feature is marked complete without empirical test validation.  

---

## 1. The 11 Verification Layers

```
Layer 11: User Acceptance Tests (Interactive human validation)
Layer 10: Hardware Compatibility Tests (CPU/GPU detection, device limits)
Layer 09: Upgrade & Migration Tests (Schema migrations, state persistence)
Layer 08: Disaster Recovery & Fallback Tests (Offline recovery to Mock)
Layer 07: Performance & Latency Tests (Startup < 1s, <50MB RAM, <1% idle CPU)
Layer 06: Accessibility Tests (Contrast ratios, reduced motion, keyboard navigation)
Layer 05: UI & QML Layout Tests (qmllint validation, scene rendering)
Layer 04: Security & Redaction Tests (Key isolation, TLS validation, sanitization)
Layer 03: API & Protocol Tests (SSE event streaming, payload parsing)
Layer 02: Integration Tests (Bridge dispatch, history retention, signal flows)
Layer 01: Unit Tests (C++ isolated functions, thread safety, timestamps)
```

---

## 2. Test Execution & Automation Suite

All automated tests are integrated into CMake and executed via `ctest`:

```bash
ctest --test-dir build --output-on-failure
```

### Current Test Suites:
1. **`CoreLoggerTimestampTest` (`test_core`):**
   - Validates POSIX `localtime_r` timestamp formatting.
   - Validates thread-safe concurrent logging across 8 parallel threads without race conditions.
2. **`AISafetyAndStreamTest` (`test_ai_safety`):**
   - Validates whitelist-first command safety classification.
   - Validates stream cancellation using C++20 `std::jthread` and `std::stop_token`.
   - Validates thread re-entrancy under 10 rapid repeated queries.
3. **`AIProviderGatewayTest` (`test_provider_gateway`):**
   - Validates provider registry and model switching.
   - Validates mock HTTP SSE streaming across Gemini, OpenAI, Claude, and Ollama payload formats.
   - Validates error handling for 401 Unauthorized, 429 Rate Limit, and 504 Timeout.
   - Validates API key isolation and multi-turn history retention.
4. **`SecurityAndResilienceTest` (`test_security_and_resilience`):**
   - Validates pattern-based secret redaction in logger and exact-match key scrubbing.
   - Validates memory cleansing (`KeyStore::secureCleanse`).
   - Validates strict TLS certificate error handling (code 495).
   - Validates network disconnect / connection refused handling (code 503).
   - Validates graceful offline fallback to Mock provider.
