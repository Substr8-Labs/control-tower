# Setup Guide

Complete setup takes about 25 minutes.

## Prerequisites

- A computer with Node.js 20+
- A Discord account
- An Anthropic API key (get one at [console.anthropic.com](https://console.anthropic.com))

---

## Step 1: Install OpenClaw (5 min)

```bash
npm install -g openclaw
```

Verify installation:
```bash
openclaw --version
```

Run the setup wizard:
```bash
openclaw wizard
```

This will prompt you for your Anthropic API key.

---

## Step 2: Discord Setup (10 min)

### Create Your Server

1. Open Discord
2. Click the `+` button to create a new server
3. Choose "Create My Own" → "For me and my friends"
4. Name it something like "{{COMPANY}} HQ"

### Create Channels

Create these text channels:
- `#general` — General discussion
- `#engineering` — Ada (CTO)
- `#product` — Grace (CPO)
- `#marketing` — Tony (CMO)
- `#finance` — Val (CFO)

### Create a Bot

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Click "New Application" → name it (e.g., "Control Tower")
3. Go to "Bot" section → click "Add Bot"
4. Under "Privileged Gateway Intents", enable:
   - ✅ Message Content Intent
   - ✅ Server Members Intent
5. Click "Reset Token" → copy and save the token securely
6. Go to "OAuth2" → "URL Generator"
   - Scopes: `bot`
   - Bot Permissions: `Send Messages`, `Read Message History`, `View Channels`
7. Copy the generated URL → open in browser → add bot to your server

### Get Channel IDs

1. In Discord, go to Settings → Advanced → enable "Developer Mode"
2. Right-click each channel → "Copy Channel ID"
3. Save these IDs — you'll need them for config

---

## Step 3: Configure OpenClaw (5 min)

### Copy the example config

```bash
cp openclaw/openclaw.example.json ~/.openclaw/openclaw.json
```

### Edit the config

Open `~/.openclaw/openclaw.json` and replace:

| Placeholder | Replace With |
|-------------|--------------|
| `${DISCORD_BOT_TOKEN}` | Your bot token from Step 2 |
| `${DISCORD_GUILD_ID}` | Your server ID (right-click server → Copy Server ID) |
| `${ENGINEERING_CHANNEL_ID}` | #engineering channel ID |
| `${PRODUCT_CHANNEL_ID}` | #product channel ID |
| `${MARKETING_CHANNEL_ID}` | #marketing channel ID |
| `${FINANCE_CHANNEL_ID}` | #finance channel ID |

### Set up personas

The config references persona prompts. You can either:

**Option A:** Inline the prompts in the config (copy from `personas/*.md`)

**Option B:** Reference files (if your OpenClaw version supports it)

---

## Step 4: Add Company Context (5 min)

Copy and customize the company context file:

```bash
cp openclaw/COMPANY.example.md ~/.openclaw/workspace/COMPANY.md
```

Edit `COMPANY.md` with your specifics:
- Company name and stage
- What you're building
- Target customer
- Current focus and constraints

This context is read by all personas.

---

## Step 5: Launch (1 min)

```bash
openclaw gateway start
```

Test by posting in #engineering:
> Hi Ada, what's your role on this team?

You should get a response from Ada explaining her CTO perspective.

---

## Troubleshooting

### Bot doesn't respond

1. Check that the bot is online in Discord (green dot)
2. Verify Message Content Intent is enabled
3. Check `openclaw gateway status` for errors

### Wrong persona responds

Check that channel IDs in config match the actual channels.

### Rate limits

If you hit API rate limits, add delays between messages or upgrade your API tier.

---

## Next Steps

- [Customize your personas](CUSTOMIZATION.md)
- [Understand the guardrails](GUARDRAILS.md)
- [Add Notion integration](NOTION.md) (optional)
