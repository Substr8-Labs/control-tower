# Control Tower

> Your AI executive team. Not workers — thinkers.

Control Tower gives solo founders an AI leadership team that debates decisions, challenges assumptions, and helps you think strategically.

## What You Get

| Persona | Role | Channel |
|---------|------|---------|
| **Ada** ✦ | CTO | #engineering |
| **Grace** 🚀 | CPO | #product |
| **Tony** 🔥 | CMO | #marketing |
| **Val** 💰 | CFO | #finance |

Each persona lives in their own Discord channel. They have specialties, personalities, and opinions. They reference each other but defer to their lanes.

## Quick Start

**Time required:** ~25 minutes

1. **Clone this repo**
   ```bash
   git clone https://github.com/Substr8-Labs/control-tower.git
   cd control-tower
   ```

2. **Set up Discord** — [Full guide](docs/SETUP.md#discord)
   - Create a Discord server
   - Create channels: #general, #engineering, #product, #marketing, #finance
   - Create a Discord bot and get the token

3. **Set up OpenClaw** — [Full guide](docs/SETUP.md#openclaw)
   - Install OpenClaw
   - Copy `openclaw/openclaw.example.json` to `~/.openclaw/openclaw.json`
   - Fill in your Discord credentials and channel IDs

4. **Customize your team** — [Full guide](docs/CUSTOMIZATION.md)
   - Edit `openclaw/COMPANY.md` with your context
   - Adjust persona prompts in `personas/` if needed

5. **Launch**
   ```bash
   openclaw gateway start
   ```

## How It Works

1. **Post a question** in any persona's channel
2. **That persona responds** with their perspective
3. **They reference other personas** when relevant ("Check with Ada on feasibility")
4. **You make the decision** — they advise, you decide

## Example

**You in #product:**
> Should we launch with one feature or three?

**Grace (CPO):**
> One. Always one. What's the smallest thing that validates your core assumption? Ship that. Learn. Then decide on feature two.
>
> Before you pick, check with Ada — is there a technical reason to bundle them?

**You in #engineering:**
> @Ada — is there a technical reason to launch all three features together?

**Ada (CTO):**
> Not really. Features 2 and 3 share some backend, but they're not coupled. Ship feature 1, I'll prep the shared infrastructure for 2+3 in parallel.
>
> Grace is right — one feature, tight feedback loop. Fewer variables.

## Guardrails

Control Tower ships with safety defaults:

- **No external actions** — personas advise only, never send emails/tweets/etc.
- **Human approval required** — all decisions flow through you
- **Clear AI framing** — personas identify as AI, not human
- **Scope boundaries** — each persona stays in their lane

See [GUARDRAILS.md](docs/GUARDRAILS.md) for details.

## Customization

- **Personas:** Edit prompts in `personas/` to adjust personality/focus
- **Company context:** Edit `openclaw/COMPANY.md` with your specifics
- **Add personas:** Create new `.md` files and add channels to config

See [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for details.

## Requirements

- [OpenClaw](https://github.com/openclaw/openclaw) v2026.2+
- Discord account + bot token
- Anthropic API key (or other LLM provider)

## Support

- [OpenClaw Docs](https://docs.openclaw.ai)
- [Discord Community](https://discord.com/invite/clawd)
- [GitHub Issues](https://github.com/Substr8-Labs/control-tower/issues)

---

**Built by [Substr8 Labs](https://substr8labs.com)** — Provable agent infrastructure.
