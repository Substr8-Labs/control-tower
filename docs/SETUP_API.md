# Control Tower Setup API

> WebSocket service that bridges Discord onboarding with customer VPS instances.

## Overview

```
┌──────────────────┐     WebSocket      ┌──────────────────┐
│  Customer VPS    │◄──────────────────►│  Setup API       │
│  (agent.js)      │                    │  api.substr8labs │
└──────────────────┘                    └────────┬─────────┘
                                                 │
                                                 │ Internal
                                                 │
┌──────────────────┐     Discord API    ┌────────▼─────────┐
│  Customer in     │◄──────────────────►│  Substr8 Bot     │
│  #onboarding     │                    │  (OpenClaw)      │
└──────────────────┘                    └──────────────────┘
```

## API Endpoints

### WebSocket: wss://api.substr8labs.com/setup

VPS agents connect here.

#### Messages: Agent → API

**Register**
```json
{
  "type": "register",
  "instanceId": "ct_a1b2c3d4e5f6",
  "pairingCode": "FALCON-7291"
}
```

**Command Result**
```json
{
  "type": "result",
  "id": "cmd_123",
  "output": "...",
  "error": null
}
```

**Config Written**
```json
{
  "type": "config-written"
}
```

#### Messages: API → Agent

**Paired**
```json
{
  "type": "paired",
  "discordUser": "founderX#1234",
  "discordUserId": "123456789",
  "companyContext": {
    "name": "NightOwl Analytics",
    "type": "B2B SaaS",
    "challenge": "shipping speed"
  }
}
```

**Command**
```json
{
  "type": "command",
  "id": "cmd_123",
  "command": "openclaw config get",
  "safe": true
}
```

**Config**
```json
{
  "type": "config",
  "config": {
    "channels": {
      "discord": {
        "enabled": true,
        "guilds": { ... }
      }
    }
  }
}
```

**Complete**
```json
{
  "type": "complete",
  "message": "Setup finished! Your Control Tower is live."
}
```

### REST: POST /api/pair

Called by Discord bot when user enters pairing code.

**Request:**
```json
{
  "pairingCode": "FALCON-7291",
  "discordUserId": "123456789",
  "discordUsername": "founderX#1234",
  "companyContext": {
    "name": "NightOwl Analytics",
    "type": "B2B SaaS",
    "challenge": "shipping speed"
  }
}
```

**Response (success):**
```json
{
  "ok": true,
  "instanceId": "ct_a1b2c3d4e5f6",
  "status": "paired"
}
```

**Response (invalid code):**
```json
{
  "ok": false,
  "error": "Invalid or expired pairing code"
}
```

### REST: POST /api/command

Send command to paired VPS.

**Request:**
```json
{
  "instanceId": "ct_a1b2c3d4e5f6",
  "command": "openclaw config get",
  "safe": true
}
```

**Response:**
```json
{
  "ok": true,
  "commandId": "cmd_123"
}
```

Results come async via WebSocket or callback.

### REST: POST /api/config

Push config to paired VPS.

**Request:**
```json
{
  "instanceId": "ct_a1b2c3d4e5f6",
  "config": { ... }
}
```

### REST: POST /api/complete

Mark setup as complete, agent enters support mode.

**Request:**
```json
{
  "instanceId": "ct_a1b2c3d4e5f6"
}
```

## Data Model

### Instance

```typescript
interface Instance {
  id: string;              // ct_a1b2c3d4e5f6
  pairingCode: string;     // FALCON-7291
  status: 'waiting' | 'paired' | 'configuring' | 'complete';
  createdAt: Date;
  pairedAt?: Date;
  completedAt?: Date;
  discordUserId?: string;
  discordUsername?: string;
  companyContext?: {
    name: string;
    type: string;
    challenge: string;
  };
  wsConnection?: WebSocket;
}
```

### Storage

For MVP: In-memory (instances don't need to survive API restart during setup)
For production: Redis with 24h TTL

## Bot Integration

The Discord bot (OpenClaw in #onboarding) calls the Setup API:

### On Pairing Code Entry

```javascript
// User says: "FALCON-7291"
const response = await fetch('https://api.substr8labs.com/api/pair', {
  method: 'POST',
  body: JSON.stringify({
    pairingCode: 'FALCON-7291',
    discordUserId: message.author.id,
    discordUsername: message.author.tag,
    companyContext: session.companyContext
  })
});

if (response.ok) {
  // "Great! I'm connected to your VPS. Let's continue..."
} else {
  // "Hmm, that code doesn't match. Check the code on your VPS console."
}
```

### On Command Execution

```javascript
// Bot decides to create channels
await fetch('https://api.substr8labs.com/api/command', {
  method: 'POST',
  body: JSON.stringify({
    instanceId: session.instanceId,
    command: 'openclaw config get'
  })
});

// Result comes back via webhook or polling
```

## Security Considerations

### Pairing Code Security

- Codes are 8 characters: WORD-NNNN
- ~10M combinations (wordlist × 10000)
- Expire after 24 hours
- Single-use (consumed on successful pair)
- Rate-limited: 5 attempts per minute per IP

### Command Whitelist

Agent only executes whitelisted commands. The API can mark commands as `safe: true` to bypass whitelist for trusted operations.

Default whitelist:
- `openclaw *`
- `systemctl --user start openclaw-gateway`
- `systemctl --user stop openclaw-gateway`
- `systemctl --user status openclaw-gateway`
- `cat ~/.openclaw/openclaw.json`
- `mkdir -p`

### Token Isolation

Bot tokens are entered directly on the VPS:
1. Bot guides user to create token
2. User SSHs into VPS (or uses console)
3. User runs `openclaw init` and pastes token
4. Token never leaves their machine

The Setup API can verify token is configured without seeing it:
```bash
openclaw config get | jq '.channels.discord.token | length > 0'
# Returns: true (token exists) or false
```

## Deployment

### Infrastructure

- **Host:** Cloudflare Workers or small VPS
- **WebSocket:** Durable Objects (CF) or ws library (Node)
- **Storage:** Redis (Upstash) or in-memory for MVP

### Environment Variables

```
SETUP_API_SECRET=<shared secret for bot auth>
REDIS_URL=<optional, for persistence>
```

### Monitoring

Track:
- Active connections (waiting for pair)
- Pair success rate
- Setup completion rate
- Time from pair to complete
