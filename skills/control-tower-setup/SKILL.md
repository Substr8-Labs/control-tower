---
name: control-tower-setup
description: Set up Control Tower - an AI Executive Team for solo founders. Creates Discord channels with CTO, CPO, CMO personas. Use when user wants to set up Control Tower, create an AI leadership team, or configure executive personas for their business.
---

# Control Tower Setup

Transform your OpenClaw into an AI Executive Team. This skill creates coordinated personas (CTO, CPO, CMO) that think strategically, challenge assumptions, and help you make better decisions.

## What You Get

| Persona | Role | Channel |
|---------|------|---------|
| **Ada ✦** | CTO | #engineering |
| **Grace 🚀** | CPO | #product |
| **Tony 🔥** | CMO | #marketing |

Optional: Val (CFO), Bucky (Research), Sentinel (Ops)

## Prerequisites

- OpenClaw running with Discord connected
- Discord bot token with `Manage Channels` permission
- Discord server where you want Control Tower

## Setup Flow

When user asks to set up Control Tower:

### Step 1: Gather Requirements

Ask the user:
1. "Which Discord server should I set up Control Tower in?" (list their servers if possible)
2. "Which personas do you want? Default is Ada (CTO), Grace (CPO), Tony (CMO). Want all three or different?"
3. "What's your company/project name?" (for persona context)

### Step 2: Create Channels

For each selected persona, create a Discord channel:

```bash
# Use Discord API via curl or the discord skill if available
# Channel names: engineering, product, marketing, finance, research, ops
```

Execute the channel creation script:
```
scripts/create_channels.sh <guild_id> <bot_token> <personas>
```

### Step 3: Deploy Persona Prompts

Update the OpenClaw config to add system prompts for each channel.

Reference the persona templates in `references/personas.md`.

Config structure:
```json
{
  "channels": {
    "discord": {
      "guilds": {
        "<guild_id>": {
          "channels": {
            "<channel_id>": {
              "enabled": true,
              "systemPrompt": "<persona_prompt>"
            }
          }
        }
      }
    }
  }
}
```

### Step 4: Configure Guardrails

Apply default guardrails:
- External actions require confirmation
- Rate limiting for API calls
- Budget awareness

Reference `references/guardrails.md` for defaults.

### Step 5: Test the Setup

Prompt user to test:
1. "Go to #engineering and say hello to Ada"
2. "Ask Grace in #product what to prioritize"
3. "Get Tony in #marketing to draft a tweet"

Confirm all personas respond correctly.

### Step 6: Optional Integrations

If user wants:
- **Notion**: Connect shared memory workspace
- **GitHub**: Link repositories for code context
- **Telegram**: Set up mobile access

## Commands

| Command | Description |
|---------|-------------|
| `setup control tower` | Full guided setup |
| `add persona <name>` | Add a new executive persona |
| `list personas` | Show active personas |
| `configure guardrails` | Adjust safety settings |
| `test board meeting` | Run a test conversation across personas |

## Persona Customization

Users can customize personas:
- "Make Ada more formal"
- "Tony should be less hype-y"
- "Add a CFO named Val"

When customizing, update the channel's systemPrompt in OpenClaw config.

## Troubleshooting

**Bot can't create channels**: Check bot has `Manage Channels` permission.

**Personas not responding**: Verify channel IDs in OpenClaw config match actual Discord channels.

**Wrong persona in channel**: Check systemPrompt is set for the correct channel ID.

## Files

- `scripts/create_channels.sh` — Creates Discord channels via API
- `scripts/generate_config.py` — Generates OpenClaw config snippet
- `references/personas.md` — Full persona prompt templates
- `references/guardrails.md` — Default guardrail settings
