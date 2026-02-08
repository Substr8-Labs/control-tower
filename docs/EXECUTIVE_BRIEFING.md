# Control Tower — Executive Briefing

**Prepared for:** Business Partner Review  
**Date:** 2026-02-08  
**Author:** Ada (CTO) + Raza (CEO)  
**Status:** Active Development — Phase 1 (Template Validation)

---

## Executive Summary

Control Tower is an **AI Executive Team in a Box** — a productized system that gives solo founders a strategic leadership layer powered by AI personas.

**The insight:** Everyone's building AI workers. Nobody's building AI thinkers.

While competitors focus on AI SDRs, recruiters, and task automation, Control Tower provides coordinated AI personas that think strategically, challenge assumptions, and help founders make better decisions — while they live their lives.

**Target Market:** Solo technical founders, post-first-revenue, who need a sounding board, not a task executor.

**Business Model:** Subscription SaaS ($49-$499/mo tiered pricing)

**Current Status:** Template shipped, documentation complete, setup wizard built, preparing for first 50 founder waitlist.

---

## 1. What We're Building

### The Product

A ready-to-deploy system that gives founders:

| Persona | Role | Channel |
|---------|------|---------|
| **Ada ✦** | CTO — Architecture, technical decisions | #engineering |
| **Grace 🚀** | CPO — Product priorities, user focus | #product |
| **Tony 🔥** | CMO — Positioning, content, growth | #marketing |
| **Val 💰** | CFO — Unit economics, pricing | #finance |
| **Bucky 🔮** | Research — Market analysis, competitive intel | #research |
| **Sentinel 🛡️** | SRE — Security, infrastructure | #ops |

**How it works:**
- Discord server = Control Tower UI (one channel per persona)
- OpenClaw = Agent orchestration (memory, tools, coordination)
- Notion = Shared memory (decisions, docs, context)
- Telegram/WhatsApp = Mobile access to primary agent

**Key differentiator:** Personas *collaborate*. They can discuss, disagree, and synthesize — not just respond in isolation.

### The Value Proposition

**Hook:** "Ship while you live your life"

**Problem:** Founders know what to do. The bottleneck is execution — too much to do, only one of them.

**Solution:** An AI leadership team that thinks alongside you, so you can focus on decisions while they handle coordination and execution.

---

## 2. Current Status

### What's Built

| Component | Status | Location |
|-----------|--------|----------|
| Template foundation | ✅ Complete | `control-tower` repo |
| 4 persona prompts | ✅ Complete | `/personas/` |
| OpenClaw config | ✅ Complete | `/openclaw/` |
| Setup guide | ✅ Complete | `/docs/SETUP.md` |
| Guardrails | ✅ Complete | `/docs/GUARDRAILS.md` |
| Notion integration docs | ✅ Complete | `/docs/NOTION.md` |
| Business plan v0.2 | ✅ Complete | `/docs/BUSINESS_PLAN.md` |
| Architecture doc | ✅ Complete | `/docs/ARCHITECTURE.md` |
| Founder story | ✅ Complete | `/docs/FOUNDER_STORY.md` |
| VPS hardening guide | ✅ Complete | `/docs/HARDENING.md` |
| Landing page copy | ✅ Complete | `/docs/LANDING_COPY.md` |
| Test plan | ✅ Complete | `/docs/TEST_PLAN.md` |
| CLI setup script | ✅ Complete | `/setup.sh` |
| Web setup wizard | ✅ Complete | `/setup-wizard/` |

### Infrastructure

| Resource | Details |
|----------|---------|
| VPS | Hostinger (72.61.7.108) |
| Domain | substr8labs.com |
| GitHub Org | Substr8-Labs |
| Discord | Substr8 HQ (internal testing) |
| X/Twitter | @substr8labs |
| Email | hello@substr8labs.com |

### Repositories

| Repo | Purpose | Visibility |
|------|---------|------------|
| `control-tower` | Template + docs | Public |
| `AutoBuildr` | Code generation factory | Private |
| `openclaw` | Orchestration fork | Public |
| `Substr8` | Future kernel | Private |

---

## 3. Technical Architecture

### Three-Layer Model

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

### Technology Stack

| Layer | Technology |
|-------|------------|
| Agent Orchestration | OpenClaw (Node.js) |
| LLM Provider | Anthropic Claude |
| UI | Discord (primary), Telegram (mobile) |
| Memory | Notion API |
| Hosting | VPS (Hostinger), Tailscale Funnel |
| Code Factory | AutoBuildr (Python, Claude Agent SDK) |

### Security Model

| Layer | Protection |
|-------|------------|
| Network | Tailscale (private mesh), no public SSH |
| OS | Hardened SSH, non-root user, auto-updates |
| Runtime | Docker isolation, tool policies |
| Agent | Guardrails, human confirmation for external actions |
| Audit | Event recording, action logging |

---

## 4. Go-to-Market Strategy

### Phase 1: Template Validation (Current)

**Goal:** Prove demand before building infrastructure.

- Open-source template on GitHub
- Self-hosters provide feedback
- Iterate on personas and workflows
- Build credibility and early advocates

**Rollout sequence:**
1. Landing page (tower.substr8labs.com)
2. Waitlist with strategic question
3. Twitter thread + Indie Hackers post
4. Early access: 50 founders, personal invites
5. Public launch with testimonials (Week 4)

### Phase 2: Hosted MVP

**Goal:** First paying customers.

- 10-20 paid pilot users
- Single-tenant hosted instances
- Stripe billing
- Tight feedback loop

### Phase 3: Multi-Tenant Platform

**Goal:** Self-serve scale.

- Kubernetes orchestration
- Automated provisioning
- Self-serve signup
- Tiered pricing

---

## 5. Competitive Landscape

### The Market

| Player | What They Do | Gap |
|--------|--------------|-----|
| **Lindy** | AI workers (SDR, recruiter) | Workers, not thinkers |
| **11x** | AI SDR | Single function |
| **Artisan** | AI employees | Task execution, not strategy |
| **ChatGPT/Claude** | Raw LLM | No memory, no coordination |

### Our Positioning

**"Not workers — thinkers."**

- Strategic coordination, not task grinding
- Multiple perspectives, not single-point answers
- Memory and context, not stateless chat
- Built for founders who want a *team*, not a tool

### Pricing Gap

- Enterprise AI teams: $50K+/year
- SMB/solo pricing: Wide open ($500-2K/mo)

We own the affordable leadership tier.

---

## 6. Key Design Decisions

### Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| UI Platform | Discord | Founders already use it, real-time, channels = personas |
| Orchestration | OpenClaw | Open-source, flexible, we maintain a fork |
| LLM Provider | Anthropic Claude | Best reasoning, tool use, safety |
| Initial Model | BYOB (Bring Your Own Bot) | Privacy-first, user owns their data |
| Setup | Web wizard + CLI script | Reduces friction, multiple options |
| Pricing | Tiered SaaS | Standard, scalable, predictable |

### Decisions Pending

| Decision | Options | Considerations |
|----------|---------|----------------|
| **Managed Bot Option** | Offer single shared bot | Simpler onboarding (2 steps vs 4), but we see their messages. Privacy trade-off. |
| **Mobile Setup Flow** | QR code + mobile wizard | Bucky researched: reduces steps from 9 → 4. Worth building? |
| **Discord vs Native** | Build our own UI later | Discord = fast to market. Native = full control. Sequence? |
| **Notion Required?** | Make it optional | Some founders don't use Notion. Add Supabase/other options? |
| **Pricing Tiers** | $49 / $149 / $499 | Need validation. Too high? Too low? |
| **White-Label** | Offer to agencies | Revenue opportunity, but complexity. When? |

### Technical Debt / Known Issues

| Issue | Impact | Mitigation |
|-------|--------|------------|
| Gateway memory leak | ~1.3GB after 20h | Daily restart cron (2am Sydney) |
| Discord bot token friction | Onboarding dropout | Web wizard helps, managed bot would eliminate |
| No centralized logging | Debugging harder | Using journalctl for now |

---

## 7. Roadmap

### February 2026 (Now)

- [x] Template v1 shipped
- [x] Documentation complete
- [x] Setup wizard built
- [ ] Landing page live
- [ ] First 50 waitlist signups
- [ ] First 10 external template users

### March 2026

- [ ] Hosted MVP (10-20 paying users)
- [ ] Pricing validated
- [ ] Core integrations stable
- [ ] First case studies

### Q2 2026

- [ ] Multi-tenant platform
- [ ] Self-serve signup
- [ ] Custom persona builder
- [ ] 100+ paying users

---

## 8. Financial Projections (Draft)

### Assumptions

| Metric | Value |
|--------|-------|
| LTV:CAC Target | 3:1 |
| Churn Target | <5%/month |
| Time to Revenue | 4-6 weeks |

### Revenue Scenarios (Month 6)

| Scenario | Users | ARPU | MRR |
|----------|-------|------|-----|
| Conservative | 50 | $99 | $4,950 |
| Base | 100 | $149 | $14,900 |
| Optimistic | 200 | $149 | $29,800 |

### Cost Structure

| Category | Monthly |
|----------|---------|
| VPS (Hostinger) | ~$20 |
| Anthropic API | Variable (per-user) |
| Domain/Email | ~$10 |
| Tools/Services | ~$50 |

**Note:** API costs are the main variable. Need per-user metering to understand unit economics.

---

## 9. Founder Story (Summary)

Raza built Control Tower from lived experience:

- Years of learning tech, marketing, infrastructure in isolation
- Went through mentorship programs that taught *what* but not *how to execute*
- Realized the bottleneck was always execution friction
- AI provided the abstraction to move from *laborer* to *architect*
- Built Control Tower in 48 hours while working his day job as a bus driver

**The tagline that captures it:**

> "I was being taught what to do, but I still had to do everything myself."

Control Tower removes that friction — for founders like him.

---

## 10. Questions for Discussion

1. **Managed Bot vs BYOB:** Should we offer both? Which first?

2. **Pricing Validation:** How do we test pricing before launch? Survey? Stripe checkout experiments?

3. **Discord Dependency:** Comfortable building on Discord long-term, or should we plan for native UI sooner?

4. **First 50 Founders:** Where do we find them? Personal network? Communities? Cold outreach?

5. **AutoBuildr Integration:** When does the code factory become part of the product?

6. **Team Expansion:** When do we need help? Engineering? Marketing? Support?

---

## Appendix A: Repository Links

- **Control Tower:** https://github.com/Substr8-Labs/control-tower
- **AutoBuildr:** https://github.com/Substr8-Labs/AutoBuildr (private)
- **OpenClaw Fork:** https://github.com/Substr8-Labs/openclaw
- **X/Twitter:** https://twitter.com/substr8labs

## Appendix B: Key Documents

| Document | Purpose |
|----------|---------|
| `BUSINESS_PLAN.md` | Strategy and GTM |
| `ARCHITECTURE.md` | Technical design |
| `FOUNDER_STORY.md` | Messaging foundation |
| `HARDENING.md` | Security checklist |
| `LANDING_COPY.md` | Website copy |
| `TEST_PLAN.md` | Validation scenarios |

---

*This document is current as of 2026-02-08. For the latest, check the control-tower repository.*
