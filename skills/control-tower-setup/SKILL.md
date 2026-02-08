# Control Tower Setup Skill

> Guest onboarding on Substr8 Labs Discord → VPS pairing → customer leaves with their own independent stack.

## The Model

**We host:** Onboarding conversation + community + setup API
**They own:** Their bot, their server, their VPS, their OpenClaw, their data

This is BYOB (Bring Your Own Bot) by design. We never touch their tokens.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SUBSTR8 INFRASTRUCTURE                          │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐  │
│  │  Discord Server  │    │  Setup API       │    │  VPS Template    │  │
│  │  #onboarding     │◄──►│  WebSocket       │◄──►│  (Marketplace)   │  │
│  └──────────────────┘    └──────────────────┘    └──────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
                                    ▲
                                    │ Pairing + Commands
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         CUSTOMER INFRASTRUCTURE                         │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐  │
│  │  Their Discord   │◄──►│  Their OpenClaw  │◄──►│  Their VPS       │  │
│  │  Server          │    │  Gateway         │    │  (Hostinger/DO)  │  │
│  └──────────────────┘    └──────────────────┘    └──────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Flow (Final)

```
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1: WELCOME (Substr8 Labs Discord)                    │
│                                                             │
│  Customer joins via public invite                           │
│  → Bot DMs them or directs to #onboarding                   │
│  → "Hey! Looking to set up your AI Executive Team?"         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 2: DISCOVERY                                         │
│                                                             │
│  Bot learns about their business:                           │
│  - Company name                                             │
│  - What they're building                                    │
│  - Biggest challenge                                        │
│  - Technical comfort level                                  │
│                                                             │
│  This context will personalize their Control Tower.         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 3: VPS DEPLOYMENT                                    │
│                                                             │
│  Bot provides one-click deploy link:                        │
│  → "Click here to deploy your VPS on Hostinger/DO/etc"      │
│  → Customer deploys (takes 1-2 minutes)                     │
│  → VPS boots, shows pairing code: FALCON-7291               │
│  → Customer enters code in Discord                          │
│  → VPS now paired to their Discord identity                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 4: DISCORD BOT CREATION                              │
│                                                             │
│  Bot guides them through:                                   │
│  □ Create Discord app (Developer Portal)                    │
│  □ Create bot, copy token                                   │
│  □ SSH into VPS, paste token (never shared with us)         │
│  □ Create their Discord server                              │
│  □ Invite their bot                                         │
│                                                             │
│  Bot verifies each step via paired VPS connection.          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 5: AUTO-CONFIGURE                                    │
│                                                             │
│  Via VPS tunnel, bot automatically:                         │
│  → Creates channels in their server (#strategy, etc)        │
│  → Writes OpenClaw config with personalized prompts         │
│  → Starts the gateway                                       │
│  → Posts welcome message in #strategy                       │
│                                                             │
│  Customer watches it happen in real-time.                   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 6: LAUNCH                                            │
│                                                             │
│  Customer has independent stack:                            │
│  - Their VPS (they own it)                                  │
│  - Their Discord server with channels                       │
│  - Their bot running on their OpenClaw                      │
│  - Personas personalized for their business                 │
│  - Zero ongoing dependency on us                            │
│                                                             │
│  VPS tunnel enters support mode (dormant).                  │
│  Customer can re-enable for future help.                    │
└─────────────────────────────────────────────────────────────┘
```

## Substr8 Labs Server Setup

### Required Channels

| Channel | Purpose |
|---------|---------|
| #welcome | Landing spot, rules, how to get started |
| #onboarding | Where the setup conversation happens |
| #support | Post-setup help |
| #showcase | Customers share wins |

### Bot Behavior

**On member join:**
- Wait 30 seconds (let them read #welcome)
- DM: "Hey! Welcome to Substr8 Labs. Ready to set up your AI Executive Team?"
- If no DM possible, ping in #onboarding

**In #onboarding:**
- Each customer gets a private thread (Discord threads)
- Conversation is isolated per-user
- Bot guides them through setup

## Conversation Script

### Welcome DM

```
Hey! 👋 Welcome to Substr8 Labs.

I'm here to help you set up **Control Tower** — your AI Executive Team.

Quick question: Are you here to...
1. Learn more about Control Tower
2. Set up Control Tower for my business
3. Just exploring

(Reply with 1, 2, or 3)
```

### Option 2: Setup Flow

#### Step 1: Discovery

```
Awesome! Let's get you set up. First, tell me about your business:

1. **What's your company/project called?**
2. **What are you building?** (SaaS, agency, marketplace, etc.)
3. **What's your #1 challenge right now?**

Just reply naturally — I'll pick out the details.
```

#### Step 2: Technical Check

```
Got it! {company_name} sounds great.

Quick tech check — which best describes you?

1. **Technical founder** — comfortable with command line, can set up a VPS
2. **Semi-technical** — can follow instructions, might need some hand-holding
3. **Non-technical** — need maximum guidance

This helps me adjust the setup instructions.
```

#### Step 3: Create Discord Bot

```
Perfect. Let's create your AI team's brain.

**Step 1: Create a Discord Bot**

1. Go to: https://discord.com/developers/applications
2. Click "New Application"
3. Name it something like "{company_name} AI" or "Control Tower"
4. Go to the "Bot" tab on the left
5. Click "Reset Token" and copy the token

⚠️ **Keep this token secret!** Don't share it with anyone (including me).

When you have the token copied somewhere safe, reply "done" and I'll guide you through the next step.
```

#### Step 4: Bot Settings

```
Great! Now let's configure your bot:

Still in the Discord Developer Portal:

1. **Bot tab** → scroll down to "Privileged Gateway Intents"
2. Enable these:
   - ✅ PRESENCE INTENT
   - ✅ SERVER MEMBERS INTENT  
   - ✅ MESSAGE CONTENT INTENT
3. Click "Save Changes"

Reply "done" when ready.
```

#### Step 5: Create Server

```
Now let's create your workspace:

1. In Discord (the app, not the developer portal)
2. Click the "+" button on the left sidebar
3. Choose "Create My Own"
4. Choose "For me and my friends" (or "For a club")
5. Name it "{company_name} HQ" or whatever you like

Reply with the server name when it's created.
```

#### Step 6: Invite Bot

```
Perfect! Now let's invite your bot to {server_name}:

1. Back in Developer Portal → your app → "OAuth2" tab
2. Click "URL Generator"
3. Under SCOPES, check: `bot`
4. Under BOT PERMISSIONS, check:
   - Manage Channels
   - Send Messages
   - Read Message History
   - Manage Messages
5. Copy the generated URL at the bottom
6. Open that URL in your browser
7. Select {server_name} and authorize

Reply "done" when your bot appears in the server (it'll be offline for now — that's normal).
```

#### Step 7: OpenClaw Setup

**For technical founders:**
```
Now let's get OpenClaw running. Where do you want to host it?

1. **My laptop/desktop** — easiest to start, runs when your computer is on
2. **A VPS** — runs 24/7, I'll help you set one up
3. **I already have a server** — just give me the setup commands

(Reply 1, 2, or 3)
```

**Option 1: Local setup**
```
Let's install OpenClaw on your machine:

# Install OpenClaw
npm install -g openclaw

# Run the setup wizard
openclaw init

When it asks for your Discord bot token, paste the one you saved earlier.

Run through the wizard, then reply "done" when OpenClaw is running.
```

**Option 2: VPS setup**
```
I recommend these VPS providers (cheap, reliable):
- **Hetzner** — €4/month (best value)
- **DigitalOcean** — $6/month
- **Vultr** — $6/month

Once you have a VPS:

# SSH into your server
ssh root@your-server-ip

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install OpenClaw
npm install -g openclaw

# Run setup
openclaw init

Reply when you're at the OpenClaw setup wizard.
```

#### Step 8: Configure Channels

```
Almost there! Let's create your Control Tower channels.

In your Discord server, create these channels:
- #strategy
- #engineering
- #product
- #marketing
- #ops

Then run this in your OpenClaw directory:

openclaw config

Add each channel with these personas... [provide config snippet]
```

#### Step 9: Personalization

```
Last step — let's personalize your AI team.

I'm going to give you a config snippet. This has your company context baked in.

Copy this into your openclaw.json (or run `openclaw config` and paste when prompted):

[Generated config with their company name, business type, etc.]
```

#### Step 10: Launch

```
🎉 **You're live!**

Your Control Tower is running:
- Your bot, your server, your data
- AI Executive Team personalized for {company_name}
- Zero dependency on us

**What to do now:**
1. Go to #strategy in your server
2. Tell your Chief of Staff what's on your mind today
3. Explore the other channels — each has a different specialty

**Need help?** Come back to #support anytime.

**Love it?** Share your setup in #showcase!

Go build something great. 🚀
```

## Implementation

### Files

```
control-tower-setup/
├── SKILL.md              # This file
├── scripts/
│   ├── generate-config.sh    # Generate personalized config
│   └── validate-setup.sh     # Verify customer's setup
├── templates/
│   ├── config/
│   │   └── openclaw.template.json
│   ├── prompts/
│   │   ├── strategy.txt
│   │   ├── engineering.txt
│   │   ├── product.txt
│   │   ├── marketing.txt
│   │   └── ops.txt
│   └── messages/
│       ├── welcome-dm.txt
│       ├── discovery.txt
│       ├── tech-check.txt
│       ├── create-bot.txt
│       ├── bot-settings.txt
│       ├── create-server.txt
│       ├── invite-bot.txt
│       ├── openclaw-local.txt
│       ├── openclaw-vps.txt
│       ├── configure-channels.txt
│       └── launch.txt
└── reference/
    └── discord-api.md
```

### Channel Config for Substr8 Labs

Add to openclaw.json:

```json
{
  "guilds": {
    "1469264343635067018": {
      "channels": {
        "<onboarding-channel-id>": {
          "enabled": true,
          "systemPrompt": "You are the Control Tower Setup Assistant at Substr8 Labs.\n\nYour job: Guide founders through setting up their own Control Tower instance.\n\nYou are friendly, patient, and technical. You can adjust your explanations based on the user's comfort level.\n\nNEVER ask for or store their bot token. Guide them to keep it private.\n\nFollow the setup flow in SKILL.md step by step. Don't skip ahead. Confirm each step before moving on."
        }
      }
    }
  }
}
```

## Testing Checklist

- [ ] New member gets welcome DM
- [ ] Discovery flow captures company info
- [ ] Tech check adjusts instruction detail level
- [ ] Bot creation steps are clear and correct
- [ ] Invite URL generation works
- [ ] OpenClaw install instructions work (local + VPS)
- [ ] Generated config is valid
- [ ] Channels get created with right personas
- [ ] Customer can interact with their AI team
- [ ] Privacy: we never see their token

## Pricing Tiers (Future)

| Tier | Price | Includes |
|------|-------|----------|
| Free | $0 | DIY setup, community support |
| Guided | $49 | Live onboarding session, 30-day support |
| Premium | $149/mo | Managed hosting, priority support, updates |
| Enterprise | Custom | Multi-team, SSO, dedicated instance |

## Success Metrics

- Conversion: Joins → Starts Setup → Completes Setup
- Time to first AI interaction
- 7-day retention (still using Control Tower)
- NPS / satisfaction survey
