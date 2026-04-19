---
description: Present a monitoring dashboard of API, DB, distribution, and scout signals.
argument-hint: ""
---

# /monitor

## Required Reading — Do This First

1. `.state/state.json` — current distribution and evolution state
2. `api/monitoring/logger.py` — logging contract (for output format)

---

**Scope:** runtime observability — API latency, DB row counts, distribution pending updates, scout feed freshness, download log.
**NOT for:** infrastructure health (use `/health`). Not for client CRM queries (use `/clients`).

## What I Need From You

No arguments. Pulls from Railway API, Neon, and local state.

## Output Template

```markdown
LEOPOLDO MONITORING — [YYYY-MM-DD]

API:
  /health             [🟢 HTTP 200 — Xms | 🔴]
  /api/licenses       [🟢 X.Xs avg | 🟡]

Database (Neon):
  clients             [N rows]
  pack_purchases      [N rows, last purchase [date]]
  page_views (24h)    [N]
  metrics (24h)       [N]
  scout_findings      [N, newest: [date]]

Distribution:
  Pending updates     [N]
  Last build          [date]

Downloads (7d):
  Total               [N]
  Unique clients      [N]

Anomalies:
  [none | list]
```

## The Tests

- **The privacy test**: Zero raw client identifiers (emails, API keys, tokens) in output.
- **The freshness test**: If `scout_findings` newest is older than 7 days, flag 🟡.
- **The anomaly test**: If any metric deviates >50% from the 7-day baseline, list it in Anomalies.

## Flow

1. Curl `/health` endpoint, measure latency
2. Query `postgres` MCP: `SELECT count(*) FROM clients`, same for `pack_purchases`, `page_views` (last 24h), `metrics` (last 24h), `scout_findings`
3. Read `.state/state.json` for distribution state
4. Query `download_log` for last 7 days, group by client_id
5. Compute 7-day baseline vs current for anomaly detection
6. Emit the dashboard

## If Connectors Available

If **~~project tracker** is connected: cross-reference Anomalies to open incidents.

Fallback: report anomalies only.

## Tips

1. If Neon is unreachable, return 🔴 on the DB section and continue with API + state.
2. An empty `scout_findings` for >7 days usually means the scout cron is broken. Flag it explicitly in Anomalies.
3. Keep output scannable. If >5 anomalies, list top 3 + "…and N more, run /monitor --verbose".
