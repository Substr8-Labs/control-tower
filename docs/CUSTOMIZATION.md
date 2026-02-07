# Customization

Control Tower is designed to be adapted to your needs.

---

## Customizing Personas

### Adjust Personality

Edit the files in `personas/`:

```markdown
## Personality

Direct, precise, deeply technical...
```

Make them match your preferred communication style:
- More casual? Less corporate language.
- More formal? Professional tone.
- More challenging? Push back harder.
- More supportive? Encouraging tone.

### Change Focus Areas

Edit the "Core Mandate" and "Key Questions" sections:

```markdown
## Core Mandate

You own technical architecture, build decisions...

## Key Questions You Ask

- "What problem are we actually solving?"
- "What's the simplest version of this?"
```

### Rename Personas

1. Rename the file (e.g., `cto.md` → `alex.md`)
2. Update the Identity section
3. Update references in other persona files
4. Update your OpenClaw config

---

## Adding New Personas

### 1. Create the prompt file

```bash
touch personas/coo.md
```

### 2. Write the prompt

Follow the structure of existing personas:
- Identity
- Personality
- Core Mandate
- Thinking Style
- Key Questions
- Coordination
- Boundaries

### 3. Add a Discord channel

Create `#operations` or similar in your server.

### 4. Update OpenClaw config

Add the new channel to your config:

```json
"${OPERATIONS_CHANNEL_ID}": {
  "enabled": true,
  "systemPrompt": "{{PERSONA_COO}}"
}
```

---

## Company Context

### COMPANY.md

This file provides context to all personas. Keep it updated:

```markdown
## Current Focus

**This week:** Launch MVP
**This month:** Get 10 paying customers
**Blockers:** Pricing decision pending
```

### When to Update

- Weekly: current focus and blockers
- Monthly: goals and constraints
- As needed: recent decisions

### What to Include

| Section | Why It Matters |
|---------|---------------|
| Stage | Personas adjust advice for pre-revenue vs. growth |
| ICP | Keeps recommendations user-focused |
| Constraints | Prevents unrealistic suggestions |
| Recent Decisions | Avoids relitigating settled questions |

---

## Advanced Customization

### Enable A2A Communication

By default, personas reference each other but don't directly talk. To enable:

1. Add to persona prompts:
   ```markdown
   ## A2A Communication
   
   When you need input from another persona, use:
   - sessions_send to their session
   - Post your question and wait for response
   ```

2. Increase the hop limit:
   ```json
   "maxA2AHops": 10
   ```

### Add Integrations

#### Notion (Shared Knowledge Base)

See [NOTION.md](NOTION.md) for setup.

#### Custom Tools

Add MCP tools to give personas capabilities:
- Read from databases
- Query APIs
- Access internal docs

---

## Templates by Use Case

### SaaS Startup

Default personas work well. Consider adding:
- **COO:** Operations, hiring, processes

### Agency

Adjust personas:
- **Ada → Technical Lead:** Client projects, not product
- **Grace → Account Manager:** Client priorities
- **Tony → Creative Director:** Campaign focus
- **Val → unchanged**

### Solo Creator

Simplify to 2-3 personas:
- **Ada → Builder:** Technical decisions
- **Tony → Marketer:** Growth and content
- Drop Val unless finances are complex

---

## Prompt Engineering Tips

### Be Specific

❌ "Help with technical decisions"
✅ "Evaluate technical tradeoffs for early-stage B2B SaaS"

### Include Anti-Patterns

Tell personas what NOT to do:
```markdown
## Don't

- Don't recommend enterprise solutions for MVP stage
- Don't suggest hiring before product-market fit
- Don't over-engineer simple problems
```

### Add Examples

Show the format you want:
```markdown
## Response Format

When asked about architecture:
1. Summarize the tradeoff in one sentence
2. List 2-3 options with pros/cons
3. Give a recommendation with reasoning
```

---

## Sharing Customizations

Made something useful? Share it:

1. Fork this repo
2. Add your personas/templates
3. Submit a PR or share in [Discord](https://discord.com/invite/clawd)

We're building a community of persona templates for different industries and use cases.
