---
name: incident-response
description: "Use when handling production incidents: detection, triage, mitigation, communication, and postmortem. Covers structured incident response for engineering teams. Triggers on: incident, outage, downtime, postmortem, on-call, alert, production issue, degradation, RCA, root cause analysis."
metadata:
  author: leopoldo
  source: custom
  created: 2026-03-24
  forge_strategy: build
license: MIT
upstream:
  url: null
  version: null
  last_checked: 2026-03-24
---

# Incident Response -- Production Incident Management

## Why This Exists

| Problem | Solution |
|---------|----------|
| Teams panic during incidents, no process | Structured incident response playbook |
| Same incidents recur without learning | Blameless postmortem process |

Inspired by [anthropics/knowledge-work-plugins/engineering/incident-response](https://github.com/anthropics/knowledge-work-plugins).

## Core Workflow

### The 5-Phase Process

```
1. DETECT   -> Alert triggers, user report, monitoring
2. TRIAGE   -> Severity assessment, assign incident commander
3. MITIGATE -> Stop the bleeding (rollback, feature flag, scale)
4. RESOLVE  -> Fix root cause, verify fix
5. LEARN    -> Blameless postmortem, action items
```

### Severity Levels

| Level | Definition | Response Time | Example |
|-------|-----------|---------------|---------|
| SEV1 | Complete outage, data loss risk | Immediate (15 min) | Database down, auth broken |
| SEV2 | Major feature broken, workaround exists | 1 hour | Payment processing failing |
| SEV3 | Minor feature broken, low impact | 4 hours | Export feature not working |
| SEV4 | Cosmetic, no user impact | Next business day | Typo in email template |

### Mitigation Playbook

```
Common mitigations (fastest first):
1. Feature flag OFF     (seconds, no deploy needed)
2. Rollback to last good deploy  (minutes)
3. Scale up resources   (minutes)
4. Block bad traffic    (rate limit, WAF rule)
5. Hotfix + deploy      (last resort, riskiest)
```

### Postmortem Template

```markdown
# Incident Postmortem: [Title]

**Date:** YYYY-MM-DD
**Duration:** X hours Y minutes
**Severity:** SEV-N
**Incident Commander:** [Name]

## Summary
[1-2 sentences: what happened, who was affected, how long]

## Timeline
| Time (UTC) | Event |
|-----------|-------|
| HH:MM | Alert triggered |
| HH:MM | IC assigned, investigation started |
| HH:MM | Root cause identified |
| HH:MM | Mitigation applied |
| HH:MM | Full resolution confirmed |

## Root Cause
[Technical explanation of why this happened]

## Impact
- Users affected: N
- Revenue impact: $X
- Duration: X hours

## What Went Well
- [thing that worked]

## What Went Wrong
- [thing that failed]

## Action Items
| # | Action | Owner | Due Date | Status |
|---|--------|-------|----------|--------|
| 1 | [specific action] | [name] | [date] | Open |
```

## Rules

1. Mitigate first, investigate later (stop the bleeding)
2. One incident commander per incident (clear ownership)
3. Communicate early and often (status page, Slack channel)
4. Blameless postmortems ALWAYS (focus on systems, not people)
5. Every SEV1/SEV2 gets a postmortem within 48 hours
6. Action items must have owners and due dates
7. Feature flags for instant rollback capability

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| No incident process | Chaos during outages | Documented playbook, practiced |
| Blame individuals | People hide problems | Blameless culture, fix systems |
| No postmortem | Same incident recurs | Postmortem within 48h for SEV1/2 |
| Hotfix as first response | Risky, may make worse | Rollback or feature flag first |
| No communication during incident | Users and stakeholders in dark | Status page + regular updates |
