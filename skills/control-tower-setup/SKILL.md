---
name: control-tower-setup
description: Set up Control Tower - an AI Executive Team for your business. Creates CTO, CPO, CMO, CFO personas with Discord channels, shared Notion workspace, and guardrails. Use when someone wants to set up Control Tower, create AI executive personas, build an AI leadership team, or configure multi-agent business coordination.
metadata:
  openclaw:
    emoji: "🗼"
    requires:
      config: ["channels.discord"]
---

# Control Tower Setup

Transform your OpenClaw into an AI Executive Team. Creates specialized personas (CTO, CPO, CMO, CFO) with their own Discord channels, shared context, and intelligent guardrails.

## What You Get

- **Executive Personas** — AI C-suite with specialized expertise
- **Discord Channels** — Dedicated channel per persona
- **Shared Knowledge** — Notion workspace for decisions, goals, context
- **Guardrails** — Cost controls, rate limits, loop prevention
- **Board Meetings** — Cross-persona strategic discussions

## Quick Setup

When user asks to set up Control Tower:

1. **Ask which personas they want:**
   - CTO (Chief Technology Officer) — Architecture, technical decisions
   - CPO (Chief Product Officer) — Roadmap, features, user insights
   - CMO (Chief Marketing Officer) — Positioning, growth, content
   - CFO (Chief Financial Officer) — Budget, metrics, runway
   - Custom persona (user-defined)

2. **Collect prerequisites:**
   - Discord server (must have Manage Channels permission)
   - Guild ID from Discord (right-click server → Copy Server ID)
   - Notion API key (optional, for knowledge base)

3. **Create the infrastructure:**
   - Discord category: "🗼 Control Tower"
   - Channel per persona: #engineering, #product, #marketing, #finance
   - Deploy persona-specific system prompts

4. **Configure guardrails** (see references/guardrails.md)

5. **Test with a board meeting prompt**

## Creating Discord Channels

Use the discord tool to create the structure:

```json
{
  "action": "categoryCreate",
  "guildId": "<GUILD_ID>",
  "name": "🗼 Control Tower"
}
```

Then create channels under the category:

```json
{
  "action": "channelCreate",
  "guildId": "<GUILD_ID>",
  "name": "engineering",
  "type": 0,
  "parentId": "<CATEGORY_ID>",
  "topic": "Ada's lab — architecture, technical decisions, code"
}
```

Repeat for each persona channel. See references/channel-config.md for full specs.

## Persona System Prompts

Each persona needs a unique system prompt. The base structure:

```
You are [NAME], the [ROLE] of [COMPANY].

Your expertise: [DOMAIN AREAS]
Your communication style: [TRAITS]
Your decision framework: [APPROACH]

You collaborate with other executives:
- [OTHER PERSONA 1] in #[CHANNEL]
- [OTHER PERSONA 2] in #[CHANNEL]

When you need expertise outside your domain, tag the relevant exec.
When decisions require consensus, call for a board meeting.
```

See references/personas.md for complete prompts.

## Guardrails Configuration

Control Tower requires guardrails to prevent runaway costs:

```yaml
guardrails:
  maxA2AHops: 5          # Kill runaway loops
  dailyTokenBudget: 100000
  alertAt: 0.8           # Alert at 80% budget
  sessionRateLimit: 20/min
  approvalThreshold: 10000  # Tokens requiring approval
```

Apply via gateway config. See references/guardrails.md for implementation.

## Notion Integration (Optional)

If user provides Notion API key, create the knowledge workspace:

1. Company Context database
2. Decisions Log database
3. Strategic Questions database
4. Board Meetings database

See references/notion-template.md for database schemas.

## Testing the Setup

After setup, run a test board meeting:

> "Call a board meeting to discuss our Q1 priorities"

Each persona should:
- Respond in their channel
- Stay in their expertise lane
- Reference shared context if available
- Tag other execs when needed

## Troubleshooting

**Personas not responding:**
- Check Discord channel permissions
- Verify bot has access to channels
- Confirm channel routing in openclaw config

**Loops between personas:**
- Check maxA2AHops guardrail is active
- Review session logs for loop patterns

**Cost overruns:**
- Verify dailyTokenBudget is set
- Check if alertAt threshold is firing
- Review which persona is burning tokens

## Capabilities

This skill provides:

- `setup_control_tower` — Full guided setup flow
- `add_persona` — Add a new executive persona
- `remove_persona` — Remove an executive persona
- `configure_guardrails` — Set cost/rate limits
- `connect_notion` — Link Notion knowledge base
- `run_board_meeting` — Trigger cross-persona discussion
- `show_status` — Display Control Tower health

## References

- [Persona Prompts](references/personas.md) — System prompts for each executive
- [Channel Config](references/channel-config.md) — Discord channel specifications
- [Guardrails](references/guardrails.md) — Safety configuration
- [Notion Template](references/notion-template.md) — Knowledge base schema
