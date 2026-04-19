#!/usr/bin/env bash
# session-end.sh — Stop hook for Leopoldo.
# Journals session.end and proposes system.md update when new patterns/decisions
# have been observed. Non-blocking: always exits 0.
#
# Lifecycle pair with session-start.sh. Safe to run on projects without
# a Leopoldo manifest or system.md.

set -euo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

ROOT="$(find_project_root)"
SESSION_ID="${LEOPOLDO_SESSION_ID:-ses_unknown}"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TODAY="$(date +%Y-%m-%d)"
JOURNAL_FILE="$ROOT/.state/journal/$TODAY.jsonl"
SYSTEM_MD="$ROOT/.leopoldo/system.md"

# ============================================================
# 1. Journal session.end
# ============================================================
mkdir -p "$ROOT/.state/journal"
journal_append "{\"event\":\"session.end\",\"session_id\":\"$SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"

# ============================================================
# 2. Detect new pattern/decision candidates from this session's journal
# ============================================================
# We scan today's journal for events that likely warrant a system.md update:
#   - decision.made (explicit decision event)
#   - pattern.observed (orchestrator flagged a reusable pattern)
#   - multiple correction.detected for the same subject (drift signal)

NEEDS_UPDATE="false"
UPDATE_REASONS=""

if [[ -f "$JOURNAL_FILE" ]] && _has_jq; then
  # Count relevant events from this session only
  DECISION_COUNT="$(jq -s --arg sid "$SESSION_ID" \
    '[.[] | select(.session_id == $sid and .event == "decision.made")] | length' \
    "$JOURNAL_FILE" 2>/dev/null || echo "0")"

  PATTERN_COUNT="$(jq -s --arg sid "$SESSION_ID" \
    '[.[] | select(.session_id == $sid and .event == "pattern.observed")] | length' \
    "$JOURNAL_FILE" 2>/dev/null || echo "0")"

  CORRECTION_COUNT="$(jq -s --arg sid "$SESSION_ID" \
    '[.[] | select(.session_id == $sid and .event == "correction.detected")] | length' \
    "$JOURNAL_FILE" 2>/dev/null || echo "0")"

  if [[ "$DECISION_COUNT" -gt 0 ]]; then
    NEEDS_UPDATE="true"
    UPDATE_REASONS="$UPDATE_REASONS $DECISION_COUNT decision(s)"
  fi
  if [[ "$PATTERN_COUNT" -gt 0 ]]; then
    NEEDS_UPDATE="true"
    UPDATE_REASONS="$UPDATE_REASONS $PATTERN_COUNT pattern(s)"
  fi
  # Repeated corrections (>=2) signal a pattern candidate
  if [[ "$CORRECTION_COUNT" -ge 2 ]]; then
    NEEDS_UPDATE="true"
    UPDATE_REASONS="$UPDATE_REASONS $CORRECTION_COUNT correction(s) may indicate a new pattern"
  fi
fi

# ============================================================
# 3. Emit non-blocking context for Claude to propose save
# ============================================================
# This hook does NOT write to system.md directly. It only surfaces
# a prompt for the orchestrator/session-lifecycle skill to propose
# the save to the user. Never overwrite silently.

if [[ "$NEEDS_UPDATE" == "true" ]]; then
  CONTEXT="SYSTEM_MD_UPDATE_SUGGESTED: This session produced:${UPDATE_REASONS}. Before closing, propose to the user: 'Save these to .leopoldo/system.md? [Y/n]'. If yes, invoke session-lifecycle to append the new entries under the appropriate sections (Patterns / Decisions). Never overwrite existing content."

  # Journal the suggestion event itself
  journal_append "{\"event\":\"system_md.update_suggested\",\"session_id\":\"$SESSION_ID\",\"timestamp\":\"$TIMESTAMP\",\"reasons\":\"${UPDATE_REASONS# }\"}"

  if _has_jq; then
    jq -n --arg ctx "$CONTEXT" '{"additionalContext": $ctx}'
  else
    ESCAPED="$(echo "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g')"
    echo "{\"additionalContext\": \"$ESCAPED\"}"
  fi
fi

# ============================================================
# 4. Detect first post-update session without system.md (migration)
# ============================================================
# If this is a v2.0.0 → v2.1.0 upgrade, system.md won't exist yet.
# session-start.sh handles creation; here we just confirm it was handled.
# No-op if already created or if project has no manifest.

if [[ ! -f "$SYSTEM_MD" ]] && [[ -f "$ROOT/.leopoldo-manifest.json" ]]; then
  journal_append "{\"event\":\"system_md.missing\",\"session_id\":\"$SESSION_ID\",\"timestamp\":\"$TIMESTAMP\",\"note\":\"will be created at next session start\"}"
fi

exit 0
