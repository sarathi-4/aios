# SRITEC AI OS — Security Policy & Guardrail Standard

> **Document:** `docs/SECURITY_POLICY.md`  
> **Status:** Active & Enforced  
> **Classification:** Enterprise Security Architecture  

---

## 1. Foundational Security Principles

SRITEC AI OS enforces **Defense-in-Depth** and **Least Privilege** across all software layers:

1. **Human Primacy & Explicit Authorization:**
   - Autonomous agents and AI assistants are strictly prohibited from performing destructive, mutating, or privilege-escalating actions without explicit, interactive human confirmation.
   - Every sensitive action must show: (a) what action will happen, (b) affected files/services, (c) required permissions, and (d) expected consequences.

2. **Zero API Key Leakage (Frontend Isolation):**
   - API keys and cloud tokens are stored strictly in backend memory or OS keyrings.
   - Frontend QML code **never receives raw API key strings**. QML only receives boolean status flags (`hasApiKey: true/false`).
   - Logging facilities automatically scrub API keys matching known patterns or configured secrets.

3. **Whitelist-First Terminal Guardrails:**
   - Empty or unvetted command strings are rejected.
   - Shell metacharacters (`;`, `&`, `|`, `>`, `<`, `$`, backticks, newlines) are rejected to eliminate shell injection vulnerabilities.
   - Destructive binaries (`rm`, `dd`, `mkfs`, `fdisk`, `format`, `shutdown`, `chmod`, `sudo`, `su`, etc.) and dangerous flags (`-rf`, `--force`) are strictly blocked.
   - Read-only inspection commands (`pwd`, `whoami`, `uptime`, `date`, `uname -a`, `git status`, `git log`, `ls`) are classified as `Safe` for simulation, but direct unrestricted shell execution remains disabled in the prototype.

4. **Cryptographic Integrity & Strict TLS:**
   - All network traffic to cloud AI endpoints enforces TLS 1.2 or TLS 1.3 with system CA validation.
   - `QNetworkReply::ignoreSslErrors()` is strictly forbidden in production code.

5. **Volatile Memory Sanitization:**
   - When keys or credentials are replaced or destroyed, memory buffers are explicitly cleansed using volatile memory zeroing (`KeyStore::secureCleanse`).

---

## 2. Security Invariants Verification Matrix

The 7 security invariants proven in Phase 2.2:
1. API keys never appear in logs.
2. API keys never appear in QML properties.
3. API keys never appear in error messages.
4. HTTPS certificate verification is enabled without bypass.
5. No secrets are committed to Git (`.gitignore` enforcement).
6. No secrets are written to plain-text files on disk.
7. Key replacement and cleanup operations are mutex-protected and thread-safe.
