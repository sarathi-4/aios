# SRITEC AI OS — Engineering Roadmap

> **Lifecycle:** v0.1 Initial Prototype through Bootable Appliance  
> **Status:** Phase 1 Active

---

## Roadmap Phases

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   PHASE 1    │     │   PHASE 2    │     │   PHASE 3    │
│  Scaffolding │ ──> │ AI Provider  │ ──> │  Integrated  │
│  & Prototype │     │ Daemon & IPC │     │  Apps Suite  │
└──────────────┘     └──────────────┘     └──────────────┘
       │                                         │
       ▼                                         ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   PHASE 6    │     │   PHASE 5    │     │   PHASE 4    │
│ Bootable ISO │ <── │  Security &  │ <── │ Wayland Shell│
│ Distribution │     │ Sandboxing   │     │  Compositor  │
└──────────────┘     └──────────────┘     └──────────────┘
```

---

### Phase 1: Modular Scaffolding & Desktop Workspace Prototype (CURRENT)
- [x] Inspect host environment and verify unprivileged execution boundaries.
- [x] Scaffold clean modular monorepo structure (`core/`, `shell/`, `apps/`, `services/`, `ai/`, `resources/`, `tests/`, `docs/`, `scripts/`).
- [x] Implement C++ Mock AI Provider interface and streaming bridge (`AIBridge`).
- [x] Build standalone Qt 6 / QML desktop workspace window featuring:
  - Original cybernetic dark theme (`SRITECTheme`).
  - Navigation sidebar with view switching.
  - Central AI assistant view with simulated token streaming.
  - Developer workspace view with safe terminal preview.
  - Real-time status and telemetry header.
- [x] Create non-destructive verification scripts and comprehensive documentation.
- [ ] **Gate:** User review and approval before proceeding to Phase 2.

---

### Phase 2: Core AI Daemon & IPC Bus
- Implement `sritec-ai-daemon` background system service via D-Bus / Unix domain sockets.
- Implement pluggable cloud providers (Gemini, Claude, OpenAI) in backend service only.
- Implement token-budgeting and provider fallback logic.
- Connect desktop workspace to backend daemon over IPC.
- Ensure strict zero-credential exposure in frontend UI.

---

### Phase 3: Native Applications Suite
- **Smart Terminal (`sritec-terminal`):** Natural language command generation, syntax highlighting, and explicit execution guardrails.
- **Semantic File Manager (`sritec-files`):** Vector-indexed metadata, instant search, and automated file summarization.
- **Developer Hub (`sritec-workspace`):** Git integration, project scratchpads, container views.
- **Browser Hub (`sritec-browser-hub`):** Sandboxed web environment with corporate filtering.

---

### Phase 4: Wayland Compositor Integration (Optional Desktop Shell)
- Transition from standalone window application to full Wayland Compositor (`QtWaylandCompositor`).
- Implement window management, multi-monitor tiling, and fractional scaling.
- Global AI HUD overlay accessible via `Super+Space`.

---

### Phase 5: Enterprise Governance & Sandboxing
- Implement `sritec-security` service using Linux `bwrap` (Bubblewrap) and `cgroups v2`.
- DNS-based website filtering and corporate policy engine.
- Employee profile management and access auditing.

---

### Phase 6: Custom Bootable ISO Image
- Package SRITEC AI OS components into Debian packages.
- Build custom `sritec-session.target` systemd unit and custom login greeter.
- Implement automated `live-build` / `debootstrap` recipe producing bootable ISO.
- Test in QEMU / KVM virtualized sandbox.
