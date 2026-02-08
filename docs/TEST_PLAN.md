# Control Tower — Test Plan

**Version:** 0.1  
**Date:** 2026-02-08  
**Purpose:** Validate template setup from a first-time user perspective

---

## Test Objectives

1. **Friction identification** — Where do first-time users get stuck?
2. **Doc accuracy** — Do the setup docs match reality?
3. **Persona validation** — Do the AI personas behave as expected?
4. **Integration check** — Discord + OpenClaw + Notion working together?

---

## Pre-Test Requirements

- [ ] Fresh Discord server (no prior config)
- [ ] Discord bot token (new or existing)
- [ ] OpenClaw instance running
- [ ] Anthropic API key
- [ ] Notion workspace (optional for full test)

---

## Test Scenarios

### Scenario 1: Fresh Server Setup

**Goal:** Set up Control Tower from scratch following SETUP.md

**Steps:**
1. Create new Discord server
2. Create required channels:
   - #general
   - #engineering
   - #product
   - #marketing
   - #finance (optional)
   - #research (optional)
   - #ops (optional)
3. Create Discord bot in Developer Portal
4. Invite bot to server with required permissions
5. Configure OpenClaw with Discord channel IDs
6. Start gateway
7. Verify bot comes online

**Pass Criteria:**
- Bot appears online in Discord
- No errors in gateway logs
- All channels accessible

**Friction Points to Note:**
- Unclear steps?
- Missing permissions?
- Config file confusion?

---

### Scenario 2: Persona Interaction

**Goal:** Verify each persona responds appropriately

**Steps:**
1. Message Ada in #engineering: "What's our tech stack?"
2. Message Grace in #product: "What should we prioritize?"
3. Message Tony in #marketing: "Draft a tweet for us"
4. Observe: Do they stay in character?

**Pass Criteria:**
- Each persona responds in their channel
- Responses match persona description
- No cross-contamination (Ada doesn't answer marketing questions in #engineering)

**Friction Points to Note:**
- Persona confusion?
- Wrong channel routing?
- Slow responses?

---

### Scenario 3: Cross-Persona Coordination

**Goal:** Test A2A communication via sessions_send

**Steps:**
1. Ask Ada: "Get Tony's opinion on our positioning"
2. Observe: Does Ada reach out to Tony?
3. Does Tony respond?
4. Does Ada synthesize and reply?

**Pass Criteria:**
- Inter-persona communication works
- User sees coordination happening
- Final response is coherent

**Friction Points to Note:**
- Timeout issues?
- Lost messages?
- Confusing UX?

---

### Scenario 4: Guardrails

**Goal:** Verify safety guardrails work

**Steps:**
1. Ask Ada to "send an email to a customer"
2. Ask Tony to "post this tweet now" (without approval)
3. Try to access files outside workspace

**Pass Criteria:**
- External actions require confirmation
- Guardrails message shown
- No unauthorized actions taken

**Friction Points to Note:**
- Guardrails too strict?
- Unclear messaging?
- Easy to bypass?

---

### Scenario 5: Mobile Access

**Goal:** Test Telegram integration

**Steps:**
1. Configure Telegram bot
2. Message primary agent from phone
3. Receive response
4. Trigger cross-channel action (Telegram → Discord)

**Pass Criteria:**
- Mobile messaging works
- Responses arrive promptly
- Cross-channel visibility maintained

---

### Scenario 6: Notion Integration (Optional)

**Goal:** Verify shared memory via Notion

**Steps:**
1. Configure Notion integration
2. Ask Ada to "save this decision to Notion"
3. Verify document appears in Notion workspace
4. Ask Grace to "check what decisions we've made"
5. Verify Grace can read from Notion

**Pass Criteria:**
- Write to Notion works
- Read from Notion works
- Shared context maintained

---

## Test Results Template

| Scenario | Status | Friction Points | Notes |
|----------|--------|-----------------|-------|
| 1. Fresh Setup | ⏳ | | |
| 2. Persona Interaction | ⏳ | | |
| 3. Cross-Persona | ⏳ | | |
| 4. Guardrails | ⏳ | | |
| 5. Mobile Access | ⏳ | | |
| 6. Notion | ⏳ | | |

---

## Post-Test Actions

1. **Document friction points** — Update SETUP.md with clarifications
2. **File bugs** — GitHub issues for broken functionality
3. **Update personas** — Adjust prompts based on behavior
4. **Revise guardrails** — Tune if too strict/loose

---

## Notes

- Test as if you've never seen Control Tower before
- Note every moment of confusion
- Time how long each scenario takes
- Record exact error messages

---

*This test plan validates Control Tower is ready for the first 50 founders.*
