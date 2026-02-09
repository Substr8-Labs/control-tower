# Control Tower — Notion Setup Guide

Your AI executive team needs shared memory. Notion is that memory.

---

## Quick Start (10 mins)

### 1. Create Notion Integration

1. Go to https://notion.so/my-integrations
2. Click **"+ New integration"**
3. Name: `Control Tower`
4. Workspace: Select your workspace
5. Capabilities: Read, Update, Insert content ✓
6. Copy the API key (starts with `ntn_` or `secret_`)

### 2. Create Workspace Structure

Create these pages in Notion:

```
📂 Control Tower (root page)
├── 📊 Decisions Log (database)
├── 📋 Projects (database)
├── 🧠 Context (page with databases)
│   ├── Company Info
│   ├── People
│   └── Preferences
├── 📝 Meeting Notes (database)
└── 💡 Ideas Backlog (database)
```

### 3. Connect Integration

For EACH page/database you create:
1. Click "..." menu (top right)
2. Click "Connect to"
3. Select "Control Tower" integration

---

## Database Schemas

### 📊 Decisions Log

Track all decisions made with context.

| Property | Type | Options |
|----------|------|---------|
| Decision | Title | — |
| Date | Date | — |
| Category | Select | Strategy, Product, Tech, Marketing, Ops, Finance |
| Made By | Select | Raza, Ada, Grace, Tony, Bucky, Sentinel |
| Status | Select | Proposed, Decided, Implemented, Revised |
| Context | Rich Text | — |
| Outcome | Rich Text | — |

### 📋 Projects

Active work streams.

| Property | Type | Options |
|----------|------|---------|
| Project | Title | — |
| Status | Select | Planning, Active, Blocked, Complete, Archived |
| Owner | Select | Raza, Ada, Grace, Tony, Bucky, Sentinel |
| Priority | Select | P0-Critical, P1-High, P2-Medium, P3-Low |
| Due Date | Date | — |
| Description | Rich Text | — |
| Links | URL | — |

### 📝 Meeting Notes

Capture conversations and outcomes.

| Property | Type | Options |
|----------|------|---------|
| Title | Title | — |
| Date | Date | — |
| Type | Select | Strategy, Standup, Review, External, Ad-hoc |
| Participants | Multi-select | Raza, Ada, Grace, Tony, Bucky, Sentinel, External |
| Summary | Rich Text | — |
| Action Items | Rich Text | — |

### 💡 Ideas Backlog

Capture ideas for later.

| Property | Type | Options |
|----------|------|---------|
| Idea | Title | — |
| Category | Select | Product, Feature, Marketing, Content, Tech, Business |
| Source | Select | Raza, Ada, Grace, Tony, Bucky, Sentinel, External |
| Status | Select | Raw, Explored, Validated, Rejected, Shipped |
| Notes | Rich Text | — |

---

## Context Pages

### Company Info (Simple page)

```markdown
# Substr8 Labs

**Founded:** February 2026
**Location:** Sydney, Australia
**Domain:** substr8labs.com

## Mission
Building practical AI tools today while researching the foundations of tomorrow's agent-driven economy.

## Products
- **Control Tower** — AI executive team for founders (flagship)
- **Substr8 Kernel** — Provable agent runtime (research)

## Values
- Thoughtful over hype
- Ship to learn
- Transparency about uncertainty
```

### People (Database)

| Property | Type |
|----------|------|
| Name | Title |
| Role | Select |
| Contact | Email |
| Notes | Rich Text |

### Preferences (Simple page)

```markdown
# Raza's Preferences

## Communication
- Primary: Telegram
- Timezone: Australia/Sydney (AEDT, UTC+11)
- Work hours: Irregular (shift worker)

## Approvals Required
- External communications (tweets, emails)
- Spending > $50
- Public commitments

## Don't
- Schedule meetings before 9am Sydney
- Send non-urgent messages 11pm-7am
```

---

## API Integration

### Store API Key

```bash
# On the server (already done for OpenClaw)
mkdir -p ~/.config/notion
echo "ntn_YOUR_KEY_HERE" > ~/.config/notion/api_key
chmod 600 ~/.config/notion/api_key
```

### Test Connection

```bash
NOTION_KEY=$(cat ~/.config/notion/api_key)
curl -s "https://api.notion.com/v1/users/me" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" | jq .
```

### Find Database IDs

```bash
# Search for your databases
curl -s -X POST "https://api.notion.com/v1/search" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"query": "Decisions"}' | jq '.results[] | {title: .title[0].plain_text, id: .id}'
```

### Add to OpenClaw Config

Once you have database IDs, we'll add them to the agent config so Ada/Grace/Tony can read and write to Notion.

---

## How Agents Use Notion

### Reading Context
Before responding, agents can query Notion for:
- Recent decisions (avoid contradictions)
- Active projects (context for discussions)
- Company info (consistent messaging)
- Preferences (respect boundaries)

### Writing Memory
After important conversations, agents log:
- Decisions made
- Action items created
- Ideas captured
- Meeting summaries

### Example Flow

```
User: "Let's pivot Control Tower to focus on agencies"

Agent:
1. Query Decisions Log for previous pivot discussions
2. Check Projects database for current commitments
3. Discuss with context
4. If decided: Log new decision to Decisions Log
5. Update relevant Projects
```

---

## Setup Checklist

- [ ] Create Notion integration
- [ ] Copy API key
- [ ] Create Control Tower root page
- [ ] Create Decisions Log database
- [ ] Create Projects database
- [ ] Create Context section
- [ ] Create Meeting Notes database
- [ ] Create Ideas Backlog database
- [ ] Connect integration to all pages
- [ ] Store API key on server
- [ ] Test API connection
- [ ] Share database IDs with Ada

---

*Ready when you wake up. — Ada ✦*
