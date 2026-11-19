# SRITEC AI OS — Multi-Platform Strategy

> **Document:** `docs/PLATFORM_STRATEGY.md`  
> **Primary Target:** Linux Desktop (Ubuntu 26.04 LTS / Wayland)  
> **Future Targets:** Windows, macOS, Embedded & Edge Nodes  

---

## 1. Primary Strategy: Linux First

The primary development and verification platform for SRITEC AI OS is **Linux** (specifically Ubuntu 26.04 LTS). 

The reasons for this prioritization are:
1. **System Sovereignty:** Linux provides complete visibility into the graphics stack (Wayland, DRM/KMS, Mesa, Vulkan), process lifecycle, and kernel namespaces.
2. **Path to Native OS:** The ultimate vision includes bootable custom Linux media (UEFI live-build ISO with Plymouth animation and systemd services).
3. **Enterprise & Robotics Readiness:** Modern robotics ecosystems (ROS 2, industrial sensors) and cloud-native development tools (Docker, Kubernetes) run natively on Linux.

---

## 2. Platform Abstraction Layer (`sritec::platform`)

To ensure long-term adaptability and prevent vendor lock-in to any single operating system, all system-interacting subsystems sit behind pure virtual platform interfaces:

```
┌──────────────────────────────────────────────────────────────┐
│                    NEBULA DESKTOP SHELL                      │
└──────────────────────────────┬───────────────────────────────┘
                               │
                ┌──────────────┴──────────────┐
                ▼                             ▼
   ┌──────────────────────────┐  ┌───────────────────────────┐
   │    sritec::platform      │  │     sritec::platform      │
   │    IWindowAdapter        │  │     IAppLauncher          │
   └────────────┬─────────────┘  └─────────────┬─────────────┘
                │                              │
     ┌──────────┴──────────┐        ┌──────────┴──────────┐
     ▼                     ▼        ▼                     ▼
┌──────────────┐    ┌────────────┐┌──────────────┐ ┌────────────┐
│ LinuxWayland │    │ Win32/macOS││ LinuxProcess │ │ Windows/Mac│
│ Adapter      │    │ Adapters   ││ (XDG Desktop)│ │ Process    │
└──────────────┘    └────────────┘└──────────────┘ └────────────┘
```

### Key Abstract Interfaces:
1. **`IAppLauncher`:** Discovers installed applications (`.desktop` entries on Linux, registry/Start Menu on Windows, `/Applications` on macOS) and launches them as unprivileged child processes without invoking a raw shell.
2. **`ISecretStore`:** Interfaces with native credential storage (libsecret / KWallet on Linux, DPAPI / Credential Manager on Windows, Keychain on macOS) with in-memory fallback.
3. **`INotificationManager`:** Bridges OS-native notification banners (org.freedesktop.Notifications on Linux, Windows Action Center, macOS Notification Center).
4. **`ITelemetrySensor`:** Queries real-time hardware telemetry (CPU, RAM, GPU, battery, disk, network throughput) via `/proc` and `sysfs` on Linux, WMI / PDH on Windows, and `sysctl` / IOKit on macOS.

---

## 3. Platform Verification Rules

- **Zero Host Mutation:** Development and testing on the host workstation must never modify disk partitions, alter the host bootloader, overwrite system files, or require `sudo`.
- **Native Platform Integrity:** Do not attempt to force non-native shell commands (e.g. running Windows PowerShell scripts directly on Linux without PowerShell installed, or executing Linux bash scripts on Windows without WSL). Detect and gracefully report platform capability.
