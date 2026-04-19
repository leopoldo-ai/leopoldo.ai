---
description: Query the Neon Postgres database via MCP or psql, with privacy guards.
argument-hint: "<optional: schema | clients | purchases | metrics | scout | jobs>"
---

# /db

## Required Reading — Do This First

1. `.claude/rules/api-security.md` — privacy rules (no raw connection strings, no tokens in output)
2. `api/builder/assembler.py` and `api/memory/schema.sql` — schema reference

---

**Scope:** read-only database queries with pre-defined operations. Never exposes raw credentials.
**NOT for:** writing data (use admin UI or migration scripts). Not for CRM-specific queries (use `/clients`).

## What I Need From You

Parse `$ARGUMENTS` to pick an operation:

- **Empty** or `schema` → list all tables with row counts
- `clients` → summary of client registry
- `purchases` → `pack_purchases` + `download_log` summary
- `metrics` → recent `page_views` and `metrics` counts
- `scout` → `scout_sources` + `scout_findings` freshness
- `jobs` → scheduled `client_jobs` and status

## Output Template

```markdown
DB QUERY — [operation] — [YYYY-MM-DD]

[Structured table based on operation]

Source: [postgres MCP | psql fallback]
```

## The Tests

- **The privacy test**: No connection string, OAuth token, or API key leaks to output. Truncate sensitive fields to `sk_xxx...`.
- **The read-only test**: Every query is SELECT. If `$ARGUMENTS` suggests a write operation, STOP and redirect to admin UI.
- **The grounding test**: Every number in output comes from a SQL query result, never inferred.

## Flow

1. Parse `$ARGUMENTS` to select operation
2. Prefer the `postgres` MCP server if connected
3. Fallback to psql with env-var connection string (never printed)
4. Run the pre-defined query for the chosen operation
5. Apply privacy filter: strip OAuth tokens, API keys, encrypted fields
6. Render as a table; annotate data source in footer

## Tips

1. If the `postgres` MCP server is unavailable and `DATABASE_URL` env var is missing, report the constraint and ask the user how to proceed.
2. For large tables (`>10k rows`), use `COUNT(*)` summaries; don't dump rows.
3. `scout_findings` freshness is the key signal for intelligence feed health — flag if newest row is >7 days old.
