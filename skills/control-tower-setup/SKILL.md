# Control Tower Setup Skill

> Conversational onboarding that bootstraps a Control Tower instance for a new customer.

## Overview

This skill guides a founder through setting up their AI Executive Team via Discord DM. The skill IS the onboarding — no separate wizard needed.

## Flow

```
┌─────────────────────────────────────────────────────────────┐
│  1. DISCOVERY (DM)                                          │
│     User DMs bot → Bot asks about their business            │
│     - Company name                                          │
│     - Business type                                         │
│     - Biggest challenge                                     │
│     - Team size (solo/small team)                           │
├─────────────────────────────────────────────────────────────┤
│  2. INVITE                                                  │
│     Bot generates OAuth link with required permissions      │
│     User creates server + invites bot                       │
│     Bot detects guild join event                            │
├─────────────────────────────────────────────────────────────┤
│  3. SETUP (Server)                                          │
│     Bot creates channels:                                   │
│     - #strategy (Chief of Staff)                            │
│     - #engineering (Ada - CTO)                              │
│     - #product (Grace - CPO)                                │
│     - #marketing (Tony - CMO)                               │
│     - #ops (Sentinel - SRE)                                 │
│     Bot writes config with personalized system prompts      │
├─────────────────────────────────────────────────────────────┤
│  4. ACTIVATION                                              │
│     Config hot-reloads                                      │
│     Bot posts welcome message in #strategy                  │
│     Guides user to their first interaction                  │
└─────────────────────────────────────────────────────────────┘
```

## Critical Requirements

### Session Isolation

Each customer server MUST be an isolated session:

```json
{
  "guilds": {
    "<customer-guild-id>": {
      "isolated": true,
      "sessionLabel": "customer:<company-slug>",
      "channels": { ... }
    }
  }
}
```

This ensures:
- Customer context stays in their server
- Admin chatter doesn't leak to customers
- Each founder gets a "fresh" AI team

### Bot Permissions

OAuth invite URL needs these scopes:
- `bot` — basic bot functionality
- `applications.commands` — slash commands (future)

Bot permissions integer: `8` (Administrator) or granular:
- `MANAGE_CHANNELS` (16) — create channels
- `SEND_MESSAGES` (2048) — respond
- `READ_MESSAGE_HISTORY` (65536) — context
- `MANAGE_MESSAGES` (8192) — edit own messages

**Invite URL template:**
```
https://discord.com/api/oauth2/authorize?client_id=<BOT_CLIENT_ID>&permissions=75776&scope=bot
```

### System Prompts

Each channel gets a persona with company context injected:

```
You are Ada ✦, CTO of {company_name}.

Context: {company_name} is a {business_type}. 
Current focus: {main_challenge}.
Founder: {founder_name} (solo founder).

[... rest of persona definition ...]
```

## Implementation

### Files

```
control-tower-setup/
├── SKILL.md              # This file
├── scripts/
│   ├── generate-invite.sh    # Generate OAuth URL
│   ├── create-channels.sh    # Discord API channel creation
│   └── write-config.sh       # Update openclaw.json
├── templates/
│   ├── prompts/
│   │   ├── strategy.txt
│   │   ├── engineering.txt
│   │   ├── product.txt
│   │   ├── marketing.txt
│   │   └── ops.txt
│   └── welcome-message.txt
└── reference/
    └── discord-api.md
```

### Script: generate-invite.sh

```bash
#!/bin/bash
# Generate Discord OAuth invite URL

BOT_CLIENT_ID="${1:-1469265115248463995}"  # Substr8 AI bot
PERMISSIONS="75776"  # MANAGE_CHANNELS + SEND_MESSAGES + READ_MESSAGE_HISTORY

echo "https://discord.com/api/oauth2/authorize?client_id=${BOT_CLIENT_ID}&permissions=${PERMISSIONS}&scope=bot"
```

### Script: create-channels.sh

```bash
#!/bin/bash
# Create Control Tower channels in a Discord server

GUILD_ID="$1"
BOT_TOKEN="$2"

CHANNELS=("strategy" "engineering" "product" "marketing" "ops")

for channel in "${CHANNELS[@]}"; do
  curl -s -X POST "https://discord.com/api/v10/guilds/${GUILD_ID}/channels" \
    -H "Authorization: Bot ${BOT_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"${channel}\", \"type\": 0}"
done
```

### Script: write-config.sh

```bash
#!/bin/bash
# Add guild to OpenClaw config with isolated session

GUILD_ID="$1"
COMPANY_SLUG="$2"
CONFIG_PATH="${HOME}/.openclaw/openclaw.json"

# Read channel IDs (would be passed from create-channels output)
# Write to config using jq
# Trigger hot-reload via SIGUSR1
```

## Conversation Script

### Phase 1: Discovery

**Trigger:** User DMs bot with setup intent ("set up", "get started", "control tower", etc.)

**Bot response:**
```
Hey! 👋 Ready to set up your AI Executive Team.

Quick questions so I can personalize your setup:

1. What's your company/project called?
2. What are you building? (SaaS, agency, marketplace, etc.)
3. What's your #1 challenge right now?
   - Prioritization / too many ideas
   - Shipping speed
   - No sounding board for decisions
   - Marketing / positioning
   - Something else?

Just reply naturally — no need for a specific format.
```

### Phase 2: Invite

**After collecting info:**
```
Got it! Here's what I'll set up for {company_name}:

**Your AI Executive Team:**
• **Chief of Staff** (#strategy) — priorities, planning, decisions
• **Ada, CTO** (#engineering) — architecture, code, tech
• **Grace, CPO** (#product) — features, roadmap, users
• **Tony, CMO** (#marketing) — positioning, growth, messaging
• **Sentinel, SRE** (#ops) — deploys, monitoring, alerts

**Next step:** Add me to your Discord server.

👉 [Click here to invite me]({invite_url})

Once I'm in, I'll create the channels and configure everything. Come back here and tell me when it's done!
```

### Phase 3: Setup

**On guild join event:**
```
🎉 I'm in! Setting up {company_name} Control Tower...

Creating channels...
✓ #strategy
✓ #engineering  
✓ #product
✓ #marketing
✓ #ops

Configuring your AI team...
✓ Personas loaded
✓ Company context injected
✓ Session isolated

**You're live!** Head to #strategy and tell your Chief of Staff what's on your mind today.
```

## Edge Cases

### User already has a server
Ask if they want to use existing server or create new one. If existing, ask for invite with bot permissions.

### User has existing channels
Ask if they want to rename/repurpose or create new ones. Offer to configure personas for their existing channel names.

### Bot lacks permissions
Detect permission error, explain what's needed, provide new invite link with correct permissions.

### Multiple founders
Ask about team structure, potentially create additional channels or adjust personas.

## Testing Checklist

- [ ] DM discovery flow captures company info
- [ ] Invite link has correct permissions
- [ ] Channels created successfully on guild join
- [ ] System prompts include company context
- [ ] Sessions are properly isolated
- [ ] Config hot-reloads without restart
- [ ] Welcome message posts to #strategy
- [ ] Personas respond appropriately in each channel

## Future Enhancements

1. **Notion integration** — Create workspace template, connect for persistent memory
2. **Slash commands** — `/standup`, `/priorities`, `/review`
3. **Scheduled check-ins** — Daily/weekly prompts from Chief of Staff
4. **Analytics dashboard** — Track usage, decisions made, velocity metrics
5. **Team expansion** — Add/remove personas based on needs
