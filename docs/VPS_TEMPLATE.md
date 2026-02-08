# Control Tower VPS Template

> One-click deploy template for Hostinger / DigitalOcean / Vultr marketplaces.

## What's Pre-Installed

```
Ubuntu 24.04 LTS
├── Node.js 20 LTS
├── OpenClaw (latest)
├── Tailscale (for tunnel)
├── control-tower-agent (setup helper)
├── nginx (reverse proxy)
├── certbot (SSL)
└── ufw (firewall, configured)
```

## Boot Sequence

```
┌─────────────────────────────────────────────────────────────┐
│  1. FIRST BOOT                                              │
│     - System updates                                        │
│     - Generate unique instance ID                           │
│     - Generate pairing code (e.g., FALCON-7291)            │
│     - Start control-tower-agent                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  2. AGENT CONNECTS                                          │
│     - WebSocket to wss://api.substr8labs.com/setup          │
│     - Sends: instance_id, pairing_code, status              │
│     - Waits for pairing                                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  3. CONSOLE OUTPUT                                          │
│                                                             │
│  ╔═══════════════════════════════════════════════════════╗  │
│  ║                                                       ║  │
│  ║   🏗️  CONTROL TOWER                                   ║  │
│  ║                                                       ║  │
│  ║   Your instance is ready for setup!                   ║  │
│  ║                                                       ║  │
│  ║   1. Join Discord: https://discord.gg/substr8         ║  │
│  ║   2. Go to #onboarding                                ║  │
│  ║   3. Enter your pairing code:                         ║  │
│  ║                                                       ║  │
│  ║              🔑  FALCON-7291                          ║  │
│  ║                                                       ║  │
│  ║   Waiting for pairing...                              ║  │
│  ║                                                       ║  │
│  ╚═══════════════════════════════════════════════════════╝  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  4. PAIRED (via Discord)                                    │
│     - Agent receives: discord_user_id, company_context      │
│     - Console updates: "Paired with @username!"             │
│     - Ready to receive commands                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  5. SETUP COMMANDS (from Discord AI)                        │
│     - Create Discord bot (guided in Discord)                │
│     - Receive bot token (entered locally, not transmitted)  │
│     - Create channels (API call from VPS)                   │
│     - Write OpenClaw config                                 │
│     - Start gateway                                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  6. COMPLETE                                                │
│     - Agent enters "support mode" (optional re-enable)      │
│     - Console shows: "✓ Control Tower is live!"            │
│     - Customer redirected to their own Discord server       │
└─────────────────────────────────────────────────────────────┘
```

## Files on Template

### /opt/control-tower/agent.js

```javascript
// Control Tower Setup Agent
// Connects to Substr8 setup API, executes commands locally

const WebSocket = require('ws');
const { execSync } = require('child_process');
const fs = require('fs');

const SETUP_API = 'wss://api.substr8labs.com/setup';
const INSTANCE_ID = fs.readFileSync('/etc/control-tower/instance-id', 'utf8').trim();
const PAIRING_CODE = fs.readFileSync('/etc/control-tower/pairing-code', 'utf8').trim();

let ws;
let paired = false;

function connect() {
  ws = new WebSocket(SETUP_API);
  
  ws.on('open', () => {
    console.log('Connected to setup API');
    ws.send(JSON.stringify({
      type: 'register',
      instanceId: INSTANCE_ID,
      pairingCode: PAIRING_CODE
    }));
  });
  
  ws.on('message', (data) => {
    const msg = JSON.parse(data);
    handleMessage(msg);
  });
  
  ws.on('close', () => {
    console.log('Disconnected, reconnecting...');
    setTimeout(connect, 5000);
  });
}

function handleMessage(msg) {
  switch (msg.type) {
    case 'paired':
      paired = true;
      console.log(`Paired with ${msg.discordUser}!`);
      updateConsole('paired', msg.discordUser);
      break;
      
    case 'command':
      executeCommand(msg);
      break;
      
    case 'config':
      writeConfig(msg.config);
      break;
      
    case 'complete':
      console.log('Setup complete!');
      updateConsole('complete');
      enterSupportMode();
      break;
  }
}

function executeCommand(msg) {
  const { id, command, safe } = msg;
  
  // Only allow whitelisted commands
  const ALLOWED = [
    'openclaw',
    'systemctl --user',
    'mkdir',
    'cat',
  ];
  
  if (!safe && !ALLOWED.some(a => command.startsWith(a))) {
    ws.send(JSON.stringify({ type: 'result', id, error: 'Command not allowed' }));
    return;
  }
  
  try {
    const output = execSync(command, { encoding: 'utf8', timeout: 30000 });
    ws.send(JSON.stringify({ type: 'result', id, output }));
  } catch (err) {
    ws.send(JSON.stringify({ type: 'result', id, error: err.message }));
  }
}

function writeConfig(config) {
  const configPath = `${process.env.HOME}/.openclaw/openclaw.json`;
  fs.mkdirSync(`${process.env.HOME}/.openclaw`, { recursive: true });
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  ws.send(JSON.stringify({ type: 'config-written' }));
}

function updateConsole(state, data) {
  // Update /etc/control-tower/status for MOTD display
  fs.writeFileSync('/etc/control-tower/status', JSON.stringify({ state, data, ts: Date.now() }));
}

function enterSupportMode() {
  // Reduce connection frequency, only reconnect on-demand
  ws.close();
  // Support mode: customer can re-enable via `control-tower support`
}

connect();
```

### /etc/control-tower/instance-id

Generated on first boot:
```
ct_a1b2c3d4e5f6
```

### /etc/control-tower/pairing-code

Generated on first boot (human-readable):
```
FALCON-7291
```

Format: `WORD-NNNN` from wordlist + 4 digits

### /usr/local/bin/control-tower

CLI helper:
```bash
#!/bin/bash

case "$1" in
  status)
    cat /etc/control-tower/status | jq .
    ;;
  support)
    systemctl start control-tower-agent
    echo "Support mode enabled. Agent reconnecting..."
    ;;
  logs)
    journalctl -u control-tower-agent -f
    ;;
  *)
    echo "Usage: control-tower {status|support|logs}"
    ;;
esac
```

### /etc/systemd/system/control-tower-agent.service

```ini
[Unit]
Description=Control Tower Setup Agent
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=claw
ExecStart=/usr/bin/node /opt/control-tower/agent.js
Restart=always
RestartSec=10
Environment=HOME=/home/claw

[Install]
WantedBy=multi-user.target
```

## Security

### Allowed Commands (Whitelist)

The agent only executes whitelisted commands:
- `openclaw *` — config, start, stop
- `systemctl --user *` — service management
- `mkdir -p` — directory creation
- `cat` — file reading (for verification)

### Token Handling

Bot tokens are NEVER transmitted to our API:
1. User creates bot in Discord Developer Portal
2. User enters token directly on VPS (via `openclaw init` or direct config edit)
3. Agent confirms "token configured" without seeing the value

### Tunnel Security

- WebSocket over TLS (wss://)
- Instance ID + pairing code = authentication
- Pairing codes expire after 24 hours
- One-time use (can't re-pair same code)

### Post-Setup

- Agent enters dormant "support mode"
- No persistent connection to our servers
- Customer can re-enable for support: `control-tower support`

## VPS Provider Specifics

### Hostinger

Template location: Hostinger VPS Templates
Image: Ubuntu 24.04 + Control Tower
Startup script: `/opt/control-tower/first-boot.sh`

### DigitalOcean

Marketplace listing: "Control Tower by Substr8"
Droplet image: Based on Ubuntu 24.04
1-Click App metadata: `marketplace.yml`

### Vultr

Marketplace: Vultr Marketplace
Snapshot-based deployment

## Cost Estimation

Minimum VPS specs:
- 1 vCPU
- 1 GB RAM
- 25 GB SSD

Provider pricing:
- Hostinger: ~$5/month
- DigitalOcean: $6/month
- Vultr: $6/month
- Hetzner: €4/month (best value)
