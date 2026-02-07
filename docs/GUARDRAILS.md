# Guardrails

Control Tower ships with safety defaults to prevent runaway costs, spam, and unintended actions.

---

## Default Guardrails

### 1. No External Actions

Personas can only advise — they cannot:
- Send emails
- Post to social media
- Make purchases
- Deploy code
- Access external services

**Why:** The founder stays in control. AI advises, human acts.

### 2. Human Approval Required

All decisions flow through you. Personas may recommend actions, but you execute them.

**Example:**
> **Tony:** "We should post this thread today while the topic is hot."
> 
> **You:** *reviews, edits if needed, posts manually*

### 3. Clear AI Framing

Each persona identifies as an AI advisor, not a human. They won't pretend to be real people.

### 4. Scope Boundaries

Each persona stays in their lane:
- Ada (CTO) → technical decisions
- Grace (CPO) → product decisions
- Tony (CMO) → marketing decisions
- Val (CFO) → financial decisions

They reference each other but defer on domain expertise.

### 5. No Financial/Legal Advice

Val (CFO) provides financial frameworks and questions, not specific advice. Same for any legal considerations.

**Example:**
> ✅ "Here are the factors to consider when pricing..."
> 
> ❌ "You should definitely charge $99/month"

---

## Technical Guardrails

These are configured in `openclaw.json`:

### Token Budget

```json
"guardrails": {
  "dailyTokenBudget": 100000,
  "alertAt": 0.8
}
```

- **dailyTokenBudget:** Maximum tokens per day (~$3-5)
- **alertAt:** Alert when 80% of budget is used

### Rate Limiting

```json
"guardrails": {
  "sessionRateLimit": 20
}
```

Maximum 20 messages per minute per session. Prevents spam floods.

### A2A Loop Prevention

```json
"guardrails": {
  "maxA2AHops": 5
}
```

If personas talk to each other (Agent-to-Agent), stop after 5 hops. Prevents infinite loops.

---

## Adjusting Guardrails

### Increase Token Budget

If you need more capacity:

```json
"dailyTokenBudget": 200000
```

### Disable Rate Limiting (Not Recommended)

```json
"sessionRateLimit": null
```

### Enable A2A Communication

By default, personas reference each other but don't directly communicate. To enable A2A:

1. Configure `sessions_send` in your prompts
2. Increase `maxA2AHops` if needed
3. Test thoroughly — loops are expensive

---

## What Happens When Guardrails Trigger

| Guardrail | Trigger | Response |
|-----------|---------|----------|
| Token budget | 80% used | Alert message |
| Token budget | 100% used | Session paused |
| Rate limit | >20 msg/min | 429 response, retry after cooldown |
| A2A loop | 5 hops | Chain terminated |

---

## Recommended Settings

### For Solo Founders (Default)

```json
"guardrails": {
  "maxA2AHops": 5,
  "dailyTokenBudget": 100000,
  "alertAt": 0.8,
  "sessionRateLimit": 20
}
```

Cost: ~$3-5/day maximum

### For Active Teams

```json
"guardrails": {
  "maxA2AHops": 10,
  "dailyTokenBudget": 500000,
  "alertAt": 0.7,
  "sessionRateLimit": 50
}
```

Cost: ~$15-25/day maximum

---

## Monitoring

Check your usage:

```bash
openclaw status
```

View session history:

```bash
openclaw sessions list
```

The daily token budget resets at midnight UTC.
