# NEBULA Design System Specification

> **Document:** `docs/NEBULA_DESIGN_SYSTEM.md`  
> **Aesthetic:** Robotics-Inspired, Spatial, Futuristic, Immersive & Professional  
> **Color Spectrum:** Deep Space Void, Graphite, Electric Cyan, Neon Blue, Radiant Violet, Controlled Emerald, Subtle Silver  

---

## 1. Visual Philosophy & Inspiration

The NEBULA design system transforms the operating environment from a static flat window into an intelligent, spatial digital world.

Inspired by cybernetic robotics laboratories and spatial holographic computing:
- **Translucent Holographic Surfaces:** Multi-layered depth with subtle borders (`#172033`), translucent glass panels (`rgba(19, 26, 40, 0.85)`), and background blur.
- **Dynamic Lighting & Energy Streams:** Pulsing light waves, glowing connection tracks, and particle fields that react to user activity and system telemetry.
- **Natural AI Presence:** Central holographic assistant avatar (inspired by the holographic AI presence "LISA"), with reactive status halos and audio/visual synthesis indicators.
- **Readable & Professional:** High contrast text (`#F0F4FC`), zero excessive eye-straining bloom, clean typography with Ubuntu / Inter for UI and JetBrains Mono for telemetry/code.

---

## 2. Design Tokens

### 2.1 Color Palette
| Token Name | Hex Code | Purpose |
|------------|----------|---------|
| `backgroundVoid` | `#070A0F` | Deepest background substrate (abyssal black) |
| `backgroundSurface` | `#0D111A` | Secondary surface / container panels |
| `backgroundElevated`| `#131A28` | Translucent cards, floating popovers, active tabs |
| `backgroundHover` | `#1B2438` | Interactive hover states |
| `backgroundInput` | `#0A0E17` | Input field text areas |
| `borderSubtle` | `#172033` | Restful structural borders |
| `borderAccent` | `#00E5FF` | Active focus, neural synthesis glow |
| `borderFocused` | `#3B82F6` | Primary focus outline |
| `accentCyan` | `#00E5FF` | Primary neural energy, stream activity |
| `accentBlue` | `#2563EB` | Core accent, buttons, links |
| `accentViolet` | `#8B5CF6` | Secondary neural depth, avatar halos |
| `accentEmerald` | `#00F5A0` | Safe guardrails, healthy status |
| `accentAmber` | `#FFB800` | Sensitive action warnings, caution |
| `accentCrimson` | `#FF3B5C` | Blocked commands, fatal errors, alerts |
| `textPrimary` | `#F0F4FC` | High-contrast body text, headings |
| `textSecondary` | `#8E9EB5` | Subtitles, labels, descriptions |
| `textTertiary` | `#506078` | Placeholder text, timestamps, captions |

### 2.2 Spatial Metrics & Radii
- `radiusSmall`: 6px (buttons, input fields, badges)
- `radiusMedium`: 10px (floating cards, toolbars, widget panels)
- `radiusLarge`: 14px (main application windows, dialogs)
- `radiusDock`: 20px (floating application dock)

### 2.3 Motion & Performance Profiles
- **Ultra / High:** Particle engine at 60fps, cursor particle trail, animated canvas waves, smooth spring transitions.
- **Balanced (Default):** Smooth CSS/QML transitions, lightweight canvas waves, static particle background.
- **Low / Battery Saver:** Static wallpaper, CSS transitions disabled, zero canvas redraw loops.
- **Reduced Motion:** Accessibility mode enforcing zero kinetic animations.
