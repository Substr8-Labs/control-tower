# Notion Integration

Add a "shared brain" to your Control Tower with Notion.

---

## What This Enables

- **Decisions Log:** Personas reference past decisions, don't relitigate
- **Company Context:** Rich, structured context in one place
- **Meeting Notes:** Async "board meeting" summaries
- **Roadmap:** Shared view of what's planned

---

## Prerequisites

- A Notion account (free tier works)
- Control Tower already set up

---

## Step 1: Create Notion Workspace (5 min)

### Option A: Use Our Template

1. Open: [Control Tower Notion Template](https://notion.so/templates/control-tower) *(coming soon)*
2. Click "Duplicate"
3. Choose your workspace

### Option B: Create From Scratch

Create these databases:

**Decisions Log**
| Property | Type |
|----------|------|
| Decision | Title |
| Date | Date |
| Owner | Select (Ada, Grace, Tony, Val) |
| Rationale | Text |
| Status | Select (Active, Superseded) |

**Open Questions**
| Property | Type |
|----------|------|
| Question | Title |
| Priority | Select (Urgent, Normal, Low) |
| Assigned | Select (Ada, Grace, Tony, Val) |
| Status | Select (Open, In Progress, Resolved) |

**Roadmap**
| Property | Type |
|----------|------|
| Feature | Title |
| Status | Select (Planned, In Progress, Shipped) |
| Owner | Select |
| ETA | Date |

---

## Step 2: Create Notion Integration (5 min)

1. Go to [Notion Integrations](https://www.notion.so/my-integrations)
2. Click "New Integration"
3. Name: "Control Tower"
4. Capabilities: Read + Write content
5. Click "Submit" → copy the **Internal Integration Token**

### Share Databases with Integration

For each database:
1. Open the database page
2. Click "..." → "Add connections"
3. Find and add "Control Tower"

---

## Step 3: Configure OpenClaw (5 min)

Add Notion MCP to your config:

```json
{
  "skills": {
    "entries": {
      "notion": {
        "apiKey": "${NOTION_API_KEY}"
      }
    }
  }
}
```

Set environment variable:
```bash
export NOTION_API_KEY="your-integration-token"
```

### Get Database IDs

1. Open each database in Notion
2. Copy the URL: `notion.so/workspace/DATABASE_ID?v=...`
3. The `DATABASE_ID` is the long string before `?v=`

Add to your company context or config as needed.

---

## Step 4: Update Persona Prompts

Add Notion awareness to each persona:

```markdown
## Notion Integration

You have access to the team's Notion workspace:
- **Decisions Log:** Check before making recommendations
- **Open Questions:** Add questions that need resolution
- **Roadmap:** Reference for timing and priorities

Before giving advice on major decisions, check if we've already decided this.
```

---

## How Personas Use Notion

### Reading Decisions

Before recommending something big, Ada might check:

> Let me check if we've already decided on this...
> 
> Found: "2024-01-15: Decided to use PostgreSQL over MongoDB for data layer. Rationale: team familiarity, relational data model."
>
> This is consistent with that decision.

### Adding Questions

When a strategic question comes up:

> Adding to Open Questions: "Should we offer annual pricing discount?"
> Priority: Normal
> Assigned: Val (CFO)

### Referencing Roadmap

> Looking at the roadmap... Feature X is planned for Q2, so we might want to coordinate with that.

---

## Best Practices

### Keep Decisions Updated

When you make a decision based on persona advice:
1. Log it in the Decisions database
2. Include the rationale
3. Note which personas were consulted

### Review Open Questions Weekly

Part of your "board meeting" routine:
1. Review Open Questions
2. Resolve or prioritize
3. Close stale questions

### Don't Over-Structure

Start simple:
- Decisions Log (essential)
- Open Questions (very useful)
- Roadmap (optional)

Add more structure only if you need it.

---

## Troubleshooting

### Personas Can't Access Notion

1. Check integration token is correct
2. Verify database is shared with integration
3. Check OpenClaw logs for errors

### Stale Context

If personas reference outdated information:
1. Mark old decisions as "Superseded"
2. Update Company Context regularly
3. Add "as of DATE" to time-sensitive info
