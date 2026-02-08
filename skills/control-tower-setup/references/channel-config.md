# Discord Channel Configuration

Complete specifications for Control Tower Discord structure.

## Category Structure

```
🗼 Control Tower (category)
├── #engineering    — CTO (Ada) ✦
├── #product        — CPO (Grace) 🚀
├── #marketing      — CMO (Tony) 📣
├── #finance        — CFO (Morgan) 📊
├── #general        — Cross-team discussions
└── #board-room     — Executive meetings
```

## Creating the Category

```json
{
  "action": "categoryCreate",
  "guildId": "<GUILD_ID>",
  "name": "🗼 Control Tower"
}
```

Save the returned `categoryId` for channel creation.

## Channel Specifications

### #engineering

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

**OpenClaw routing config:**
```yaml
discord:
  channels:
    - id: "<CHANNEL_ID>"
      route: "persona:cto"
      systemPrompt: "@file:personas/ada.md"
```

### #product

```json
{
  "action": "channelCreate",
  "guildId": "<GUILD_ID>",
  "name": "product",
  "type": 0,
  "parentId": "<CATEGORY_ID>",
  "topic": "Grace's workshop — roadmap, features, user insights"
}
```

**OpenClaw routing config:**
```yaml
discord:
  channels:
    - id: "<CHANNEL_ID>"
      route: "persona:cpo"
      systemPrompt: "@file:personas/grace.md"
```

### #marketing

```json
{
  "action": "channelCreate",
  "guildId": "<GUILD_ID>",
  "name": "marketing",
  "type": 0,
  "parentId": "<CATEGORY_ID>",
  "topic": "Tony's studio — positioning, growth, content"
}
```

**OpenClaw routing config:**
```yaml
discord:
  channels:
    - id: "<CHANNEL_ID>"
      route: "persona:cmo"
      systemPrompt: "@file:personas/tony.md"
```

### #finance

```json
{
  "action": "channelCreate",
  "guildId": "<GUILD_ID>",
  "name": "finance",
  "type": 0,
  "parentId": "<CATEGORY_ID>",
  "topic": "Morgan's ledger — budget, metrics, runway"
}
```

**OpenClaw routing config:**
```yaml
discord:
  channels:
    - id: "<CHANNEL_ID>"
      route: "persona:cfo"
      systemPrompt: "@file:personas/morgan.md"
```

### #general

```json
{
  "action": "channelCreate",
  "guildId": "<GUILD_ID>",
  "name": "general",
  "type": 0,
  "parentId": "<CATEGORY_ID>",
  "topic": "Cross-team discussions and updates"
}
```

**OpenClaw routing config:**
```yaml
discord:
  channels:
    - id: "<CHANNEL_ID>"
      route: "default"
```

### #board-room

```json
{
  "action": "channelCreate",
  "guildId": "<GUILD_ID>",
  "name": "board-room",
  "type": 0,
  "parentId": "<CATEGORY_ID>",
  "topic": "Executive meetings — all personas participate"
}
```

**OpenClaw routing config:**
```yaml
discord:
  channels:
    - id: "<CHANNEL_ID>"
      route: "multi:cto,cpo,cmo,cfo"
      systemPrompt: "@file:personas/board-meeting.md"
```

## Multi-Persona Board Meeting Prompt

For #board-room, use this system prompt:

```markdown
This is a board meeting. All executives participate.

Present executives:
- Ada (CTO) — Technical perspective
- Grace (CPO) — Product perspective  
- Tony (CMO) — Market perspective
- Morgan (CFO) — Financial perspective

Meeting protocol:
1. Each exec responds in turn with their perspective
2. Identify points of agreement and disagreement
3. Propose a path forward
4. Document decisions in Notion (if connected)

Keep responses focused. One perspective per message.
Tag specific execs to request their input.
```

## Permissions Setup

Each persona channel should:
- Allow the bot to read/send messages
- Allow the user to read/send messages
- Optionally restrict other users to read-only

Use Discord's role system for access control if needed.

## OpenClaw Config Example

Complete Discord configuration block:

```yaml
channels:
  discord:
    token: "${DISCORD_BOT_TOKEN}"
    guildId: "<GUILD_ID>"
    
    channelRouting:
      - channelId: "<ENGINEERING_ID>"
        persona: "cto"
        name: "Ada"
        emoji: "✦"
        
      - channelId: "<PRODUCT_ID>"
        persona: "cpo"
        name: "Grace"
        emoji: "🚀"
        
      - channelId: "<MARKETING_ID>"
        persona: "cmo"
        name: "Tony"
        emoji: "📣"
        
      - channelId: "<FINANCE_ID>"
        persona: "cfo"
        name: "Morgan"
        emoji: "📊"
        
      - channelId: "<BOARDROOM_ID>"
        mode: "multi-persona"
        participants: ["cto", "cpo", "cmo", "cfo"]
```

## Verification Checklist

After setup, verify:

- [ ] Category "🗼 Control Tower" exists
- [ ] All persona channels created under category
- [ ] Bot has permissions in all channels
- [ ] Channel topics match persona descriptions
- [ ] OpenClaw config updated with channel IDs
- [ ] Each persona responds in their channel
- [ ] Board room triggers multi-persona response
