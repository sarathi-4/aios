# SRITEC AI OS — NEBULA JARVIS Hand Gesture Mapping
**Module:** Section 25.E — 9 Spatial Hand Gestures & Interaction  
**Version:** 1.0.0

---

## 1. Complete Hand Gesture Specification Table

| # | Gesture Name | Enum Symbol | Spatial Landmark Description | Desktop Action | Feedback |
|---|---|---|---|---|---|
| 1 | **Open Palm** | `OpenPalm` | All 5 fingers extended outward, palm facing camera | Enables virtual cursor navigation; cursor tracks wrist/palm midpoint | Cyan tracking ring |
| 2 | **Thumb-Index Pinch** | `ThumbIndexPinch` | Thumb tip and index tip touch within Euclidean distance < 35px | Left click at active cursor coordinates | Click sound + pink pulse |
| 3 | **Two-Finger Pinch** | `TwoFingerPinch` | Thumb, index, and middle tips converge | Right click / Context Menu trigger | Violet pulse |
| 4 | **Two-Finger Vertical Move** | `TwoFingerVerticalMove` | Index and middle finger extended moving vertically | Smooth vertical page / list scrolling | Directional wave |
| 5 | **Closed Fist** | `ClosedFist` | All 5 finger tips curled tightly into palm | Pause gesture tracking (prevents accidental clicks) | Amber lock badge |
| 6 | **Swipe Left** | `SwipeLeft` | Open hand moving rapidly toward the left (< 200ms) | Switch to previous workspace | Workspace slide left |
| 7 | **Swipe Right** | `SwipeRight` | Open hand moving rapidly toward the right (< 200ms) | Switch to next workspace | Workspace slide right |
| 8 | **Open Palm Hold** | `OpenPalmHold` | Open palm motionless in frame for > 800ms | Open JARVIS Multimodal Quick Menu | Circular radial menu |
| 9 | **Distance Change** | `ThumbIndexDistanceChange` | Distance between thumb and index expanding / contracting | Zoom in / Zoom out where supported | Magnification scale |

---

## 2. Cursor Smoothing & Calibration

To prevent jitter caused by raw optical sensor noise, `GestureRecognizer` applies an Exponential Moving Average (EMA) smoothing filter:
$$\vec{P}_{smooth}(t) = \alpha \cdot \vec{P}_{raw}(t) + (1 - \alpha) \cdot \vec{P}_{smooth}(t-1)$$
where $\alpha = 0.35$ (configurable between 0.1 and 0.8).

- **Left-Hand Mode:** Flipping `isLeftHandMode` mirrors coordinate tracking and reverses swipe vector calculations.
- **Calibration Routine:** `calibrate()` samples the user's neutral hand position for 1.5 seconds to establish baseline coordinate origins and distance ratios.

---

## 3. Click Debounce Mechanism

To eliminate accidental double-clicking when holding a pinch gesture:
- **Click Debounce Window:** `350 ms`.
- Any subsequent pinch event occurring within 350 ms of the last registered click is discarded.
- Verified in automated unit test `test_hand_gestures_and_debounce()`.
