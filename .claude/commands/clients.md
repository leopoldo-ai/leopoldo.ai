---
description: |
  Query the Leopoldo client CRM in Neon Postgres.
  Trigger with "mostrami i clienti", "list clients", "CRM clienti",
  "who are our clients", "dammi i clienti", or "show me client X".
argument-hint: "<optional: client name, email, or operation>"
---

# /clients

## Required Reading — Do This First

Before any output, read these completely:

1. `skills/engine/clients/SKILL.md` — client CRM access layer
2. `.claude/rules/api-security.md` — privacy rules (NEVER expose OAuth tokens, credentials, raw API keys)

---

**Scope:** read-only CRM queries — list, detail, jobs, purchases, activity.
**NOT for:** creating or editing clients (use admin UI at `/admin/clients`). Not for sending emails (use `/clients` admin).

## What I Need From You

Parse `$ARGUMENTS` to infer the operation:

- **Empty / "list"** → list all clients (summary)
- **Client name/email** → detail view of that client
- **"jobs <client>"** → scheduled jobs for that client
- **"purchases <client>"** → purchase history
- **"activity <client>"** → recent conversation history

## Output Template

```markdown
CLIENTS — [operation] — [YYYY-MM-DD]

| Name | Plan | Domains | Expires | Last heartbeat |
| --- | --- | --- | --- | --- |
| [name] | [plan] | [comma list] | [date] | [🟢 active | 🟡 stale | 🔴 offline >30d] |

[For detail view: add profile block + recent communications]
```

## The Tests

Run before showing the user:

- **The privacy test**: Output contains zero OAuth tokens, zero raw api_key values, zero encrypted fields in clear. If a token appears in query results, truncate to `sk_xxx...` pattern.
- **The traffic-light test**: Every client has a heartbeat status 🟢/🟡/🔴.
- **The grounding test**: Every number comes from a SQL query result, not hallucination.

## Flow

1. Parse `$ARGUMENTS` to determine operation
2. Use the `postgres` MCP server (preferred) or direct psql fallback
3. Run the appropriate pre-defined query (never construct SQL with user input — use parameters)
4. Apply privacy filter: strip OAuth tokens, API keys, encrypted fields before rendering
5. Compute heartbeat status: 🟢 if last_heartbeat <7d, 🟡 if <30d, 🔴 otherwise
6. Render table or detail block
7. For detail views, include communication history (subject + status only, no body)

## If Connectors Available

If **~~crm** is connected (Salesforce/HubSpot via MCP): cross-reference lead enrichment data.

Fallback: query only the Leopoldo `clients` table.

## Never Say / Instead

| Never say | Instead |
|---|---|
| "API key: sk_live_..." | Truncate to `sk_xxx...` always |
| "Client has no activity" | State the actual last_heartbeat date |
