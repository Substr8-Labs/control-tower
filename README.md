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

---

## Quick Start (Docker)

**Time required:** ~15 minutes

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- A Discord account
- An [Anthropic API key](https://console.anthropic.com)

### Step 1: Clone and run setup

```bash
git clone https://github.com/Substr8-Labs/control-tower.git
cd control-tower
./setup.sh
```

The setup wizard will:
- Check that Docker is installed and running
- Collect your API keys and Discord IDs
- Generate your configuration
- Build and start the container

### Step 2: Test it

Post in your #engineering channel:

> Hi Ada, what's your role on this team?

You should get a response from Ada explaining her CTO perspective.

---

## Discord Setup (if you haven't already)

### Create Your Server

1. Open Discord → click `+` → "Create My Own" → "For me and my friends"
2. Create text channels: `#engineering`, `#product`, `#marketing`, `#finance`

### Create a Bot

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Click "New Application" → name it (e.g., "Control Tower")
3. Go to "Bot" → "Add Bot"
4. Enable under **Privileged Gateway Intents**:
   - ✅ Message Content Intent
   - ✅ Server Members Intent
5. Click "Reset Token" → copy and save it
6. Go to "OAuth2" → "URL Generator":
   - Scopes: `bot`
   - Permissions: `Send Messages`, `Read Message History`, `View Channels`
7. Copy the URL → open in browser → add bot to your server

### Get IDs

Enable Developer Mode: Discord Settings → Advanced → Developer Mode

- **Server ID:** Right-click server name → Copy Server ID
- **Channel IDs:** Right-click each channel → Copy Channel ID

---

## Commands

```bash
# View logs
docker compose logs -f

# Stop
docker compose down

# Restart
docker compose restart

# Rebuild after changes
docker compose up -d --build
```

---

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

---

## Customization

### Change Company Context

Edit `.env` and set `COMPANY_NAME`, then restart:

```bash
docker compose restart
```

For deeper context, mount a custom company file:

```yaml
# In docker-compose.yml, add under volumes:
- ./my-company.md:/home/tower/.openclaw/workspace/COMPANY.md:ro
```

### Modify Personas

Edit files in `personas/`, then rebuild:

```bash
docker compose up -d --build
```

See [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for details.

---

## Guardrails

Control Tower ships with safety defaults:

- **No external actions** — personas advise only, never send emails/tweets/etc.
- **Human approval required** — all decisions flow through you
- **Clear AI framing** — personas identify as AI, not human
- **Scope boundaries** — each persona stays in their lane

See [GUARDRAILS.md](docs/GUARDRAILS.md) for details.

---

## Troubleshooting

### Bot doesn't respond

```bash
# Check if container is running
docker compose ps

# Check logs for errors
docker compose logs --tail 50

# Verify bot is in server and has permissions
```

Common issues:
- Message Content Intent not enabled in Discord Developer Portal
- Bot not invited to server (check OAuth URL again)
- Wrong channel IDs in .env

### Container won't start

```bash
# Check what's wrong
docker compose logs

# Rebuild from scratch
docker compose down
docker compose up -d --build
```

### Reset everything

```bash
docker compose down -v  # -v removes volumes too
./setup.sh              # Start fresh
```

---

## Manual Installation

If you prefer not to use Docker, see [docs/SETUP.md](docs/SETUP.md) for manual installation instructions.

**Note:** Manual setup is more complex and requires familiarity with:
- Node.js and npm
- systemd services (Linux)
- OpenClaw configuration

---

## Support

- [OpenClaw Docs](https://docs.openclaw.ai)
- [Discord Community](https://discord.com/invite/clawd)
- [GitHub Issues](https://github.com/Substr8-Labs/control-tower/issues)

---

**Built with [OpenClaw](https://github.com/openclaw/openclaw)** — Powered by open-source AI infrastructure.

**[Substr8 Labs](https://substr8labs.com)** — Provable agent infrastructure.
