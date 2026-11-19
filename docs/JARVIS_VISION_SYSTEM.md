# SRITEC AI OS — NEBULA JARVIS Computer Vision & Camera Subsystem
**Module:** Section 25.D — Camera Discovery, Streaming & Landmark Analysis  
**Version:** 1.0.0

---

## 1. Device Discovery & V4L2 Hardware Integration

The `CameraService` performs automated scanning of host video devices on startup and hotplug events:
- Queries `/dev/video*` character devices.
- Discovers hardware model strings, formats, and frame rate caps using Linux V4L2 API.
- If no physical webcams are connected, an internal Synthetic Video Landmark Generator generates smooth sinusoidal 3D hand tracking landmarks for UI responsiveness and offscreen unit testing.

```
       /dev/video0 (Hardware Webcam)
                     │
                     ▼
          [ CameraService Worker ]
                     │
          ├── Frame Resizer (640x480)
          ├── 15/30 FPS Rate Limiter
          └── Local Landmark Extractor (21 3D Points)
                     │
                     ▼
          [ GestureRecognizer ]
```

---

## 2. Adaptive Frame Rate Management

To conserve power and keep CPU/GPU utilization minimal, `CameraService` provides dynamic FPS adaptation:

| Operating Condition | Target FPS | Frame Resolution | Power Mode |
|---|---|---|---|
| Active Hand Interaction | 30 FPS | 640 x 480 | High Performance |
| Static Hand In Frame | 15 FPS | 320 x 240 | Balanced |
| Low-Resource / Battery Mode | 10 FPS | 320 x 240 | Power Saver |
| Camera Disabled (Default) | 0 FPS | Off | Zero Consumption |

---

## 3. Strict Permission Model & Privacy Guard

1. **Default State:** Strictly **OFF** on system startup. No video streams are created until explicit user consent is given via the JARVIS HUD or top status capsule.
2. **Indicator LEDs & UI Feedback:** The top HUD camera icon turns bright cyan with active status text whenever the camera is capturing frames.
3. **Emergency Disconnect:** Calling `emergencyShutdown()` releases device file descriptors immediately without waiting for worker thread cleanup.
