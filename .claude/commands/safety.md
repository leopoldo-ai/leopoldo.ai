---
description: Run Safety Agent on the last output. Profile auto-detected or passed explicit.
argument-hint: "<code | full | numbers | disclaimer>"
---

# /safety

## Required Reading — Do This First

1. `agents/orchestrator.md` — gate enforcement rules (Output Integrity Gate section)
2. `.claude/rules/finance-skills.md`, `legal-skills.md`, `api-security.md` — domain-specific disclaimer and safety rules

---

**Scope:** explicit safety check on the last output in the conversation. Reports issues; does NOT auto-fix.
**NOT for:** fixing the output (user decides after the report). Not for proactive pre-delivery checks (that's the orchestrator's job via the Output Integrity Gate).

## What I Need From You

- `$ARGUMENTS` picks the profile:
  - empty → auto-detect from current domain
  - `code` → DEV profile (code security checks)
  - `full` → full BUSINESS profile (all checks)
  - `numbers` → numeric consistency only
  - `disclaimer` → disclaimer presence only

## Output Template

```text
Safety check [profile] — N issues found

1. CATEGORY [🔴 blocker | 🟡 warn]
   Description of the issue.
   Suggestion: how to fix.

2. ...

Overall: [🟢 PASS | 🟡 WARN | 🔴 FAIL] (N issues, M blockers)
```

Audit journal event written after every run:

```json
{"event":"safety.check","profile":"<profile>","result":"PASS|WARN|FAIL","issues":N,"checks_run":M,"timestamp":"<ISO-8601>"}
```

## The Tests

- **The scope test**: Check ONLY the last output in the conversation, not previous ones.
- **The no-autofix test**: Report issues; never edit the output. User decides fix.
- **The audit test**: Always write the audit journal event, even on PASS.

## Flow

1. Parse `$ARGUMENTS` to pick profile (auto-detect uses current domain from conversation)
2. Dispatch a Safety Agent (sonnet, foreground) with the profile and the last output
3. Agent runs the appropriate checks:
   - **DEV profile**: SQL injection, XSS, unsafe packages, supply chain, weak crypto, auth gaps
   - **BUSINESS profile**: fact consistency, source flagging, disclaimer enforcement, cross-contamination, numeric consistency, regulatory freshness, hallucination markers
4. Agent returns issues list with severity
5. Append audit event to `.state/journal/<session>.jsonl`
6. Present the report

## Available Capabilities

| Profile | Best for | Key checks |
|---|---|---|
| DEV (`code`) | Code-heavy outputs | Injection, XSS, crypto, auth |
| BUSINESS (`full`) | Finance/legal/medical memos | Consistency, sources, disclaimers |
| NUMBERS | Financial models, analysis | Math derivation chain |
| DISCLAIMER | Any regulated domain | Domain-specific disclaimer string |

## Tips

1. The Safety Agent is intentionally a separate dispatch — keeps the check independent of the producer.
2. If profile is `auto` and the domain is ambiguous, default to `full` (safest).
3. A `PASS` still produces an audit event — you want the trail for compliance.
