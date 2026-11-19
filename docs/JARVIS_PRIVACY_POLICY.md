# SRITEC AI OS — NEBULA JARVIS Privacy & Security Policy
**Module:** Section 25.C / Section 25.H — Privacy, Local Processing & Sensor Security  
**Version:** 1.0.0

---

## 1. Zero Cloud Upload Principle

1. **Local-First Processing:**
   - Wake-word detection is performed **100% locally** in volatile memory using local mathematical audio analysis.
   - Hand gesture landmark detection is performed **100% locally** on the user's CPU/GPU. Video frames never leave the device.
   - Raw microphone audio and camera frames are **NEVER** transmitted to any external cloud, server, telemetry pipeline, or third party.

2. **Cloud AI Gateway Boundaries:**
   - Only when the user explicitly issues an open-ended conversational instruction (e.g., "Ask Gemini to explain quantum computing") is the text prompt dispatched through the **Unified AI Provider Gateway**.
   - No audio streams or raw camera footage are ever uploaded to AI providers.

---

## 2. Sensor State & Default Policies

| Hardware Sensor | Default State | Permission Requirement | Background Ingestion |
|---|---|---|---|
| **Camera (`/dev/video*`)** | **STRICTLY OFF** | Explicit User Toggle via HUD | Zero |
| **Microphone** | **Wake-Word Only** | Muteable with 1-click toggle | Only local ring buffer |

---

## 3. Emergency Sensor Kill Switch

A physical and software kill switch (`emergencyShutdown()`) is wired directly to all sensor drivers:
- **Immediate Disconnect:** Forces instant termination of microphone capture threads and releases `/dev/video*` file handles.
- **Hardware Blackout:** Sets state to `Offline` and informs the user via visual alert badge.
- **Revocation of Permissions:** Resets active session grants, requiring deliberate re-approval by the user before any sensor can be reopened.
