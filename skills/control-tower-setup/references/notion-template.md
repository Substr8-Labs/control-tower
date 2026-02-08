# Notion Knowledge Base Template

Database schemas for Control Tower's shared knowledge.

## Workspace Structure

```
📁 Control Tower (root page)
├── 🎯 Command Center (dashboard)
├── 📚 Context
│   ├── 🏢 Company Context (database)
│   └── 🎯 Goals & OKRs (database)
├── 💭 Deliberation
│   ├── ❓ Strategic Questions (database)
│   ├── ⚖️ Decisions Log (database)
│   └── 📝 Board Meetings (database)
└── 📈 Execution
    └── 🚀 Initiatives (database)
```

## Database Schemas

### 🏢 Company Context

Structured knowledge about the company. Replaces static COMPANY.md.

**Properties:**

| Property | Type | Options |
|----------|------|---------|
| Section | Select | mission, product, market, team, culture, constraints |
| Content | Rich Text | — |
| Last Verified | Date | — |
| Owner | Select | CTO, CPO, CMO, CFO, Founder |
| Confidence | Select | high, medium, low, stale |

**API Create:**
```bash
curl -X POST "https://api.notion.com/v1/data_sources" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -d '{
    "parent": {"page_id": "<ROOT_PAGE_ID>"},
    "title": [{"text": {"content": "🏢 Company Context"}}],
    "properties": {
      "Section": {"select": {"options": [
        {"name": "mission"}, {"name": "product"}, {"name": "market"},
        {"name": "team"}, {"name": "culture"}, {"name": "constraints"}
      ]}},
      "Content": {"rich_text": {}},
      "Last Verified": {"date": {}},
      "Owner": {"select": {"options": [
        {"name": "CTO"}, {"name": "CPO"}, {"name": "CMO"}, {"name": "CFO"}, {"name": "Founder"}
      ]}},
      "Confidence": {"select": {"options": [
        {"name": "high"}, {"name": "medium"}, {"name": "low"}, {"name": "stale"}
      ]}}
    }
  }'
```

### ⚖️ Decisions Log

Institutional memory for "why did we do X?"

**Properties:**

| Property | Type | Options |
|----------|------|---------|
| Decision | Title | — |
| Date | Date | — |
| Context | Rich Text | — |
| Options Considered | Rich Text | — |
| Reasoning | Rich Text | — |
| Personas Consulted | Multi-select | CTO, CPO, CMO, CFO |
| Outcome | Select | pending, implemented, revised, abandoned |
| Tags | Multi-select | product, tech, hiring, pricing, strategy |

**API Create:**
```bash
curl -X POST "https://api.notion.com/v1/data_sources" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -d '{
    "parent": {"page_id": "<ROOT_PAGE_ID>"},
    "title": [{"text": {"content": "⚖️ Decisions Log"}}],
    "properties": {
      "Decision": {"title": {}},
      "Date": {"date": {}},
      "Context": {"rich_text": {}},
      "Options Considered": {"rich_text": {}},
      "Reasoning": {"rich_text": {}},
      "Personas Consulted": {"multi_select": {"options": [
        {"name": "CTO"}, {"name": "CPO"}, {"name": "CMO"}, {"name": "CFO"}
      ]}},
      "Outcome": {"select": {"options": [
        {"name": "pending"}, {"name": "implemented"}, {"name": "revised"}, {"name": "abandoned"}
      ]}},
      "Tags": {"multi_select": {"options": [
        {"name": "product"}, {"name": "tech"}, {"name": "hiring"}, {"name": "pricing"}, {"name": "strategy"}
      ]}}
    }
  }'
```

### ❓ Strategic Questions

Backlog of things to think about.

**Properties:**

| Property | Type | Options |
|----------|------|---------|
| Question | Title | — |
| Status | Select | open, in-discussion, decided, parked |
| Priority | Select | urgent, important, someday |
| Domain | Select | product, tech, growth, ops, finance |
| Owner | Select | CTO, CPO, CMO, CFO |
| Raised By | Text | — |
| Raised Date | Date | — |
| Discussion | Rich Text | — |

### 📝 Board Meetings

Async "executive sync" summaries.

**Properties:**

| Property | Type | Options |
|----------|------|---------|
| Date | Date | — |
| Attendees | Multi-select | CTO, CPO, CMO, CFO |
| Agenda | Rich Text | — |
| Key Outcomes | Rich Text | — |
| Decisions Made | Relation | → Decisions Log |
| Open Questions | Relation | → Strategic Questions |
| Next Meeting | Date | — |

### 🎯 Goals & OKRs

What we're trying to achieve.

**Properties:**

| Property | Type | Options |
|----------|------|---------|
| Goal | Title | — |
| Type | Select | objective, key-result |
| Parent | Relation | → Goals & OKRs (self-relation) |
| Timeframe | Select | Q1, Q2, Q3, Q4, annual |
| Status | Select | on-track, at-risk, off-track, achieved |
| Progress | Number | 0-100 |
| Owner | Select | CTO, CPO, CMO, CFO |

### 🚀 Initiatives

Active work streams.

**Properties:**

| Property | Type | Options |
|----------|------|---------|
| Initiative | Title | — |
| Status | Select | planned, active, blocked, completed, cancelled |
| Owner | Select | CTO, CPO, CMO, CFO |
| Goal | Relation | → Goals & OKRs |
| Start Date | Date | — |
| Target Date | Date | — |
| Description | Rich Text | — |
| Current Status | Rich Text | — |
| Blockers | Rich Text | — |

## Command Center Dashboard

Create a page with linked views:

```markdown
# 🎯 Command Center

## 🔥 Urgent Questions
[Linked view: Strategic Questions, filter: priority = urgent, status = open]

## 📅 Recent Decisions (Last 30 Days)
[Linked view: Decisions Log, sort: date desc, limit: 10]

## 🚀 Active Initiatives
[Linked view: Initiatives, filter: status = active]

## ⚠️ Stale Context
[Linked view: Company Context, filter: confidence = stale]
```

## Persona Access Patterns

Each persona primarily uses:

| Persona | Primary DBs | Actions |
|---------|-------------|---------|
| CTO | Initiatives, Decisions (tech) | Architecture decisions |
| CPO | Strategic Questions, Goals | Roadmap, prioritization |
| CMO | Decisions (positioning) | Campaigns, positioning |
| CFO | Goals (financial), Decisions | Budget, metrics |

## Integration Flow

1. User provides Notion API key
2. Create root page "Control Tower"
3. Create each database under root
4. Share page with integration
5. Store database IDs in config
6. Personas query/update via Notion skill

## Seed Data

After creation, seed with initial content:

**Company Context:**
- Mission section with company mission
- Product section with one-liner
- Constraints section with key limits

**Strategic Questions:**
- "What should we build first?"
- "How do we differentiate?"
- "What's our pricing strategy?"

**Goals:**
- One objective for the quarter
- 2-3 key results underneath

This gives personas context to start reasoning about the business.
