---
name: productivity
version: 0.1.0
description: "Productivity essentials. Day-1 useful skills available in every Leopoldo install: email triage, calendar prep, task capture, decision log, structured note. Cowork-native."
author: lucadealbertis
license: proprietary
skills:
  - email-triage
  - calendar-prep
  - task-capture
  - decision-log
  - structured-note
dependencies:
  packs: ["essentials"]
tags: ["productivity", "cross-domain", "cowork-native", "day-1"]
---

# Productivity

Day-1 productivity essentials for any Leopoldo user. Five skills that close the gap between "Cowork installed" and "Cowork demonstrably useful in 10 minutes". Cross-domain (finance, legal, consulting, medical, HR all benefit equally). Cowork-native by design (no PostToolUse hooks, no bundled MCP, native memory friendly).

## Why this pack exists

When a new client installs Leopoldo on Cowork, the first 10 minutes determine whether the system feels like an upgrade or a configuration project. Generic Claude already does email and calendar reasonably; Anthropic's `knowledge-work-plugins` repo (Apache 2.0, 12k stars) ships a productivity plugin that covers the basics for free. We do not try to out-feature it. We ship a thin, regulated-finance-aware version that integrates with the rest of Leopoldo (citation discipline, audit trail, decision-log feeds compliance-engine) so the prospect sees the framework value on day 1.

## Target users

- Any professional opening Cowork for the first time after installing Leopoldo
- Buyers in pilot phase who need quick wins to validate the framework
- Existing users who want lightweight productivity without leaving Cowork

## Out of scope

- Not a project management replacement. Notion, Asana, Linear, Jira remain the source of truth; this pack captures and routes, does not own.
- Not a CRM. Manatal, Salesforce, Hubspot remain the source of truth.
- Not an inbox-zero methodology. We surface and prioritize; the user decides.
- Not a calendar app. We prepare and orchestrate; Outlook / Google Calendar remain the booking surface.

## Skill summary

| Skill | What it does | Typical trigger |
|---|---|---|
| email-triage | Categorize and rank inbox by urgency with finance-aware tags | "Help me triage my inbox" |
| calendar-prep | Surface upcoming meetings, identify prep needs, propose blocking | "What's my week" |
| task-capture | Quick structured task entry with project/deal tagging | "Add a task to follow up with X" |
| decision-log | Capture decisions with rationale, source, and audit trail | "Log this decision" |
| structured-note | Fast structured note capture during calls or reviews | "Note from this call" |

## Cross-pack integration

| Other pack | Integration point |
|---|---|
| finance/advisory-desk/meeting-prep-pack | calendar-prep surfaces upcoming meetings; meeting-prep-pack assembles the briefing pack for high-priority ones |
| finance/investment-core/compliance-engine | decision-log feeds compliance audit trail |
| common/essentials/decision-toolkit | task-capture and decision-log both honor the decision-toolkit framework |
| intelligence/competitive-intelligence | structured-note can be tagged for CI input |

## Cowork compatibility

All five skills are Cowork-compatible by construction:
- Frontmatter strips cleanly to name + description
- No PostToolUse / SubagentStart / SubagentStop hook dependency
- No MCP bundled (uses Cowork-native interfaces)
- Each SKILL.md under 800 words
- Native memory friendly (writes to client memory via standard Cowork preferences)

## Disclaimer

These are productivity utilities. They do not constitute investment, legal, tax, or accounting advice. Decisions captured via decision-log are audit-trail support, not legal record; privileged and material decisions remain the responsibility of the user and any qualified professional involved.
