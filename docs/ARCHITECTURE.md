# Control Tower — Architecture

**Version:** 0.1  
**Date:** 2026-02-08

---

## Overview

Control Tower is a three-layer system:

```
┌─────────────────────────────────────────────────────────────┐
│                     STRATEGY LAYER                          │
│           (Control Tower — AI Executive Team)               │
│  Ada, Grace, Tony, Val, Bucky, Sentinel                     │
│  Discord + Telegram + Notion                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     EXECUTION LAYER                         │
│              (AutoBuildr — The Factory)                     │
│  Spec → AgentSpecs → HarnessKernel → Tested Code           │
│  Point at repo, get production-ready artifacts              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   INFRASTRUCTURE LAYER                      │
│                (Hardened VPS + OpenClaw)                    │
│  SSH hardening, Tailscale, Docker, systemd                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer 1: Strategy (Control Tower)

**What it does:** Provides strategic thinking and coordination.

**Components:**
- AI personas (Ada, Grace, Tony, Val, Bucky, Sentinel)
- Discord server (one channel per persona)
- OpenClaw gateway (orchestration, memory, tools)
- Notion workspace (shared context, decisions, docs)
- Mobile access (Telegram/WhatsApp to primary agent)

**Key behaviors:**
- Personas discuss and synthesize (not just respond)
- Memory persists across sessions
- Actions require human confirmation (guardrails)
- Coordination via sessions_send between personas

---

## Layer 2: Execution (AutoBuildr — The Factory)

**What it does:** Transforms specifications into tested, documented code.

**The Factory Model:**
```
Input:  Repo URL + App Spec
        ↓
        AutoBuildr
        ↓
        1. Maestro analyzes context, plans agents
        2. Octo generates AgentSpecs for each capability
        3. HarnessKernel executes agents with tool policies
        4. Event recorder captures every action
        5. Validators verify acceptance criteria
        ↓
Output: Tested code + docs + audit trail
```

**Why AutoBuildr:**
- Spec-driven (not prompt-driven)
- Least-privilege tool policies
- Event-sourced execution (replayable, auditable)
- Multi-agent orchestration (parallel coding + testing)
- Continuous until done (multi-session persistence)

**Integration with Control Tower:**
- Strategy layer produces specs
- AutoBuildr consumes specs, produces artifacts
- Audit trail feeds back into strategy discussions

---

## Layer 3: Infrastructure (Hardened VPS)

**What it does:** Provides secure, reliable foundation.

**Pre-Install Hardening:**
- SSH: No root login, no password auth, pubkey only
- Firewall: Restrictive ingress rules
- Tailscale: Funnel for secure HTTPS exposure
- Non-root user for all services
- Unattended security updates

**OpenClaw Runtime:**
- Docker containers (isolation)
- systemd services (reliability)
- Per-user service management
- Memory monitoring + daily restart (leak mitigation)

**See:** [HARDENING.md](./HARDENING.md) for full checklist.

---

## Data Flow

```
User (Telegram/Discord)
        │
        ▼
   OpenClaw Gateway
        │
        ├──▶ Persona Session (Ada, Grace, etc.)
        │         │
        │         ▼
        │    Tool Calls (GitHub, web, exec, etc.)
        │         │
        │         ▼
        │    Response → User
        │
        └──▶ AutoBuildr (when execution needed)
                  │
                  ▼
             HarnessKernel
                  │
                  ▼
             Repo artifacts (code, docs, tests)
```

---

## Security Model

**Defense in Depth:**

| Layer | Protection |
|-------|------------|
| Network | Tailscale (private mesh), no public SSH |
| OS | Hardened SSH, non-root, updates |
| Runtime | Docker isolation, tool policies |
| Agent | Guardrails, confirmation requirements |
| Audit | Event recording, action logging |

**Principle:** Assume breach at any layer; contain blast radius.

---

## Deployment Topologies

### Solo Founder (Current)

```
Single VPS
├── OpenClaw Gateway
├── Discord Bot
├── All Personas (same gateway)
└── AutoBuildr (on-demand)
```

### Hosted MVP (Phase 2)

```
Per-User VPS
├── Isolated OpenClaw instance
├── User's Discord server
├── Dedicated resources
└── Managed by Substr8
```

### Multi-Tenant Platform (Phase 3)

```
Kubernetes Cluster
├── Shared control plane
├── Per-user namespaces
├── Autoscaling
└── Self-serve provisioning
```

---

## Repository Map

| Repo | Purpose |
|------|---------|
| `Substr8-Labs/control-tower` | Template, personas, docs |
| `Substr8-Labs/AutoBuildr` | Factory engine (private) |
| `Substr8-Labs/openclaw` | Orchestration fork |
| `Substr8-Labs/Substr8` | Future kernel (private) |

---

*Last updated: 2026-02-08*
