# Scheduled task templates

Five reusable prompt patterns for `/schedule`. Each follows the autonomous-prompt rules in SKILL.md. Output of this skill is the **prompt body** plus a recommended `taskName` and `timing`. The user pastes them into Anthropic's `/schedule` skill.

Placeholders to replace at conversation time:
- `{user_email}` — destination email if Gmail delivery
- `{slack_channel}` — Slack channel if Slack delivery
- `{notion_page}` — Notion page URL or ID
- `{sectors}` — sectors of interest for the user
- `{client_name}` — specific client / portfolio company / mandate

---

## 1. Morning brief

```text
taskName: morning-brief
timing: cron "0 8 * * 1-5"   # every weekday at 08:00 local

prompt:
1. Open my Google Calendar and list today's meetings. For each: title, time, attendees (max 5), one-line context if available from the invite description.
2. Open Gmail and list unread emails from the last 16 hours that are (a) labeled "priority", (b) from a contact already in my CRM, or (c) flagged as important. For each: sender, subject, one-line summary, suggested action.
3. Web search: 3 news items published in the last 24h about {sectors}. Sources: Bloomberg, Reuters, FT, Institutional Investor, sector trade press. For each: title, source URL, one-line takeaway.
4. Compose an email titled "Morning brief — {today's date}" with three sections (Calendar, Priority mail, Sector news). Send via Gmail to {user_email}.
5. Fail-safe: if any section has no data, write "no data" for that section instead of asking. If Gmail send fails, save the brief as a draft.
```

---

## 2. Weekly pipeline review

```text
taskName: weekly-pipeline-review
timing: cron "0 8 * * 1"   # every Monday at 08:00 local

prompt:
1. Query Manatal for all open jobs assigned to me. For each: title, client, days open, candidates in pipeline, candidates moved this week.
2. Identify stale candidates (in pipeline > 14 days, no activity). List name, role, last stage, days stale.
3. Compute weekly funnel: applied → screened → interviewed → submitted → hired. Show absolute numbers and conversion rates.
4. Identify top-3 jobs at risk: oldest open, fewest active candidates, or shortlist not yet sent.
5. Compose a markdown report titled "Weekly pipeline review — week of {Monday's date}" with sections: Open jobs, Stale candidates, Funnel, At-risk jobs, Suggested actions (3 max).
6. Save the report to {notion_page} via Notion. Email a copy to {user_email} via Gmail.
7. Fail-safe: if Manatal returns no data, output "no data this week" and skip downstream steps. If a destination fails, save locally as fallback.
```

---

## 3. Monthly portfolio snapshot

```text
taskName: monthly-portfolio-snapshot
timing: preset Manual   # user triggers after closing month-end data

prompt:
1. Read the latest valuation file in the working folder (most recent .xlsx by modified date). Extract NAV, total commitments, called capital, distributions, unrealized value.
2. Compute month-over-month delta for each metric. Compute MOIC, TVPI, DPI for the fund as a whole.
3. List top-5 holdings by current value. For each: company, sector, current value, unrealized gain/loss, last update date.
4. List portfolio companies with stale data (no update in last 60 days). Flag for follow-up.
5. Compose a one-page snapshot in Markdown with sections: Headline numbers, Performance ratios, Top-5 holdings, Stale data flags. Include disclaimer: "This analysis is for informational purposes only and does not constitute investment advice."
6. Save to {notion_page} and email a copy to {user_email}.
7. Fail-safe: if no valuation file is found in the working folder, output "no valuation file found, skipping run". Do not invent numbers.
```

Manual on purpose: month-end timing is rarely a clean cron preset, user triggers after closing data.

---

## 4. Daily deal radar

```text
taskName: daily-deal-radar
timing: cron "0 19 * * *"   # every day at 19:00 local (evening scan)

prompt:
1. Web search for deals announced in the last 24h in {sectors}. Search terms: "acquired", "raises", "Series A/B/C", "merger", "spin-off". Limit to credible sources (Bloomberg, Reuters, FT, sector trade press).
2. For each deal: target, acquirer/lead investor, sector, deal size if disclosed, source URL, one-line strategic rationale.
3. Filter out any deal already covered in the last 7 days. Keep at most 10 deals.
4. Cross-reference target/acquirer with my CRM. Flag any deal involving a known contact or company.
5. Post a Slack message titled "Deal radar — {today's date}" with the filtered list to {slack_channel}.
6. Fail-safe: if no deals match, post "No new deals in target sectors today." Do not stretch criteria to fill the report.
```

---

## 5. Quarterly client report

```text
taskName: quarterly-client-report-{client_name}
timing: preset Manual   # user triggers after quarter-end

prompt:
1. Read all files in the working folder modified in the last quarter. Categorize: deliverables, meeting notes, data files.
2. Build a quarter narrative with sections: Engagements completed, Key decisions and outcomes, Open items carrying into next quarter, Hours/spend summary if data available.
3. Pull KPIs from the latest data file (most recent .xlsx). Compare current vs prior quarter. Flag deltas > 10%.
4. Draft an executive summary (5 bullets max) suitable for client leadership.
5. Compose the full report in Markdown. Save to {notion_page} as a new sub-page named "Q{quarter} {year} — {client_name}". Save a copy to the working folder.
6. Send a notification email to {user_email} with the executive summary in body and a link to the full report.
7. Fail-safe: if the working folder has no recent files, output "no quarterly data, skipping report" and stop. Do not fabricate.
```

Manual on purpose: triggered after quarter close, not on fixed cadence.

---

## Adapting templates

When the user picks a template:

1. Confirm the placeholders with the user (one quick round)
2. Replace placeholders inline
3. Adjust timing only if the user explicitly asks
4. Keep the fail-safe lines intact
5. Print the final Leopoldo Schedule Package per SKILL.md output format
6. Remind the user to invoke `/schedule` and paste

## Cron quick reference

| Want | Cron |
| --- | --- |
| Every weekday 08:00 | `0 8 * * 1-5` |
| Every Monday 09:00 | `0 9 * * 1` |
| Every day 18:00 | `0 18 * * *` |
| First of month 09:00 | `0 9 1 * *` |
| Every 4 hours | `0 */4 * * *` |
| Every 30 min during weekday business hours | `*/30 8-18 * * 1-5` |

All cron expressions evaluate in the user's local timezone.
