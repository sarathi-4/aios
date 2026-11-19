# SRITEC AI OS — NEBULA JARVIS Voice Subsystem
**Module:** Section 25.B — Voice, Wake-Word, VAD & Multilingual Speech  
**Version:** 1.0.0

---

## 1. Wake-Word Detection Engine

The JARVIS wake-word detector runs locally in a dedicated low-resource audio loop. It continuously monitors an in-memory 1.5-second circular audio buffer using local Voice Activity Detection (VAD).

### Supported Wake Phrases
| Language | Script | Phonetic Keywords | Sensitivity Target |
|---|---|---|---|
| English | Latin | `Hey Jarvis`, `Jarvis`, `Hello Jarvis` | 0.70 – 0.85 (Configurable) |
| Tamil | தமிழ் | `ஹே ஜார்விஸ்`, `ஜார்விஸ்` | 0.75 |
| Hindi | देवनागरी | `हे जार्विस`, `जार्विस` | 0.75 |

### Low-Resource Mode
When the system is on battery power or idle for > 3 minutes, `WakeWordDetector` enters Low-Resource Mode:
- Audio frame sampling reduces from 44.1 kHz continuous to 16 kHz windowed decimation.
- CPU consumption is kept strictly under 1.5% single-core on typical host hardware.

---

## 2. Voice Activity Detection (VAD) & Audio Metering

The `VoiceSystem` calculates root-mean-square (RMS) energy levels normalized from `0.0` to `1.0`:
$$RMS = \sqrt{\frac{1}{N}\sum_{i=1}^{N} x_i^2}$$

- **Speech Threshold:** Signals above `0.25` trigger speech segmentation.
- **Silence Timeout:** 1200 ms of contiguous silence triggers automatic utterance end and transitions state from `Listening` to `Processing`.
- **Waveform HUD Binding:** The calculated energy level is streamed live to QML at 30 Hz for circular avatar pulsing and HUD spectrum visualizer bars.

---

## 3. Multilingual Speech Synthesis (TTS)

JARVIS features a multi-tiered speech synthesis subsystem:
1. **Primary Backend:** Linux Speech Dispatcher (`spd-say`) with language and pitch modulation.
2. **Secondary Fallback:** `espeak-ng` with multi-language voice models (`ta` for Tamil, `hi` for Hindi, `en-us` for English).
3. **Tertiary Simulation Fallback:** Text visual display capsule for low-resource headless or silent operation.

### Speed & Pitch Control
- User configurable via `JarvisSettings`:
  - Speed: 0.5x to 2.0x (Default: 1.05x for natural pacing)
  - Preferred Language: `en` (English), `ta` (Tamil), `hi` (Hindi)
