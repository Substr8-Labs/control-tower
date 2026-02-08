# Guardrails Configuration

Safety controls for Control Tower to prevent runaway costs and loops.

## Core Guardrails

### 1. Loop Prevention (maxA2AHops)

Prevents personas from calling each other infinitely.

```yaml
guardrails:
  maxA2AHops: 5
```

**What it does:**
- Counts hops when one persona triggers another
- Kills the chain after 5 hops
- Resets on new user input

**Example scenario:**
```
User → CTO → CPO → CTO → CPO → CTO → [KILLED]
         1     2     3     4     5
```

**When it trips:**
- Log: "Loop detected: maxA2AHops exceeded"
- Action: Session paused, user notified
- Recovery: User sends new message to restart

### 2. Daily Token Budget

Caps daily spending across all personas.

```yaml
guardrails:
  dailyTokenBudget: 100000
  alertAt: 0.8
```

**What it does:**
- Tracks cumulative tokens used today
- Alerts at 80% (80,000 tokens)
- Stops at 100% (100,000 tokens)

**Cost estimate:**
- 100K tokens ≈ $3-5/day (varies by model)
- Claude Sonnet: ~$0.003/1K input, ~$0.015/1K output

**When it trips:**
- At 80%: Warning message to user
- At 100%: "Daily budget exhausted. Resets at midnight UTC."
- Recovery: Wait for reset or increase budget

### 3. Session Rate Limit

Prevents spam floods.

```yaml
guardrails:
  sessionRateLimit: "20/min"
```

**What it does:**
- Sliding window rate limiter
- Max 20 messages per minute per session
- Applies to user messages, not responses

**When it trips:**
- Response: "Rate limited. Please wait."
- Recovery: Automatic after cooldown

### 4. Approval Threshold

Requires confirmation for expensive operations.

```yaml
guardrails:
  approvalThreshold: 10000
```

**What it does:**
- Estimates token cost before execution
- If estimated > 10,000 tokens, pauses for approval
- User must confirm to proceed

**Example trigger:**
- "Analyze this 50-page document" (high input tokens)
- "Write a comprehensive report" (high output tokens)

**When it trips:**
- Message: "This will use ~15,000 tokens (~$X). Proceed? [Yes/No]"
- Recovery: User confirms or cancels

## Implementation

### Gateway Config

Add to `openclaw.yaml`:

```yaml
guardrails:
  maxA2AHops: 5
  dailyTokenBudget: 100000
  alertAt: 0.8
  sessionRateLimit: "20/min"
  approvalThreshold: 10000

  # Per-persona overrides (optional)
  personaLimits:
    cto:
      dailyTokenBudget: 40000
    cpo:
      dailyTokenBudget: 30000
    cmo:
      dailyTokenBudget: 20000
    cfo:
      dailyTokenBudget: 10000
```

### Monitoring

Track guardrail state in lineage metadata:

```yaml
guardrails:
  a2a_hop_count: 2
  rate_limit_remaining: 18
  budget_used_today: 45000
  budget_remaining_pct: 0.55
  approval_required: false
```

### Alerts

Configure alert channels:

```yaml
guardrails:
  alerts:
    budgetWarning:
      channel: "discord:<GENERAL_CHANNEL_ID>"
      message: "⚠️ Budget at {percent}%. {remaining} tokens left today."
    
    budgetExhausted:
      channel: "discord:<GENERAL_CHANNEL_ID>"
      message: "🛑 Daily budget exhausted. Resets at midnight UTC."
    
    loopDetected:
      channel: "discord:<GENERAL_CHANNEL_ID>"
      message: "🔄 Loop detected between personas. Chain killed after {hops} hops."
```

## Degradation Hierarchy

When guardrails trip, follow this order:

```
1. WARN (80% budget)
   └── Alert user, continue operating

2. APPROVE (expensive operation)
   └── Pause, request confirmation, continue on yes

3. PAUSE (100% budget)
   └── Stop new operations, allow viewing logs
   
4. KILL (loop detected / rate limit)
   └── Terminate session, require new message to restart
```

## Tuning Guide

**Starter config (conservative):**
```yaml
maxA2AHops: 3
dailyTokenBudget: 50000
approvalThreshold: 5000
```

**Power user config (permissive):**
```yaml
maxA2AHops: 10
dailyTokenBudget: 500000
approvalThreshold: 50000
```

**Cost-sensitive config (tight):**
```yaml
maxA2AHops: 3
dailyTokenBudget: 20000
alertAt: 0.5
approvalThreshold: 2000
```

## Verification Checklist

After configuring guardrails:

- [ ] Test loop prevention: Have personas ping each other
- [ ] Test budget alert: Run queries until 80%
- [ ] Test rate limit: Send 25 messages quickly
- [ ] Test approval: Request a large analysis
- [ ] Verify alerts fire to correct channel
- [ ] Check logs capture guardrail state
