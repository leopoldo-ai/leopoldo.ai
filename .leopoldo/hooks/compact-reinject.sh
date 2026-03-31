#!/usr/bin/env bash
# compact-reinject.sh — SessionStart hook (matcher: compact).
# Re-injects critical context when Claude's context is compacted.
# Lightweight: no session init, no license check, no heartbeat.
# Only re-injects: Imprint calibrations, gate state, workflow progress.
# Always exits 0.

set -euo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

ROOT="$(find_project_root)"
CONTEXT="Leopoldo context re-injected after compaction."

# --- License status (from env var or client config) ---
LICENSE_STATUS="${LEOPOLDO_LICENSE_STATUS:-FREE}"
if [[ "$LICENSE_STATUS" != "LICENSE_VALID" && "$LICENSE_STATUS" != "FREE" ]]; then
  if _has_jq; then
    jq -n --arg ctx "$LICENSE_STATUS: Leopoldo skills disabled. Run /leopoldo activate YOUR-KEY." '{"additionalContext": $ctx}'
  else
    echo "{\"additionalContext\": \"$LICENSE_STATUS: Leopoldo skills disabled.\"}"
  fi
  exit 0
fi

# --- Imprint calibrations ---
IMPRINT_CONFIG="$ROOT/.leopoldo/imprint/config.json"
IMPRINT_PROFILE="$ROOT/.leopoldo/imprint/profile.json"

IMPRINT_ENABLED="${LEOPOLDO_IMPRINT_ENABLED:-false}"
if [[ "$IMPRINT_ENABLED" != "true" ]] && [[ -f "$IMPRINT_CONFIG" ]] && _has_jq; then
  IMPRINT_ENABLED="$(jq -r '.enabled // false' "$IMPRINT_CONFIG" 2>/dev/null || echo "false")"
fi

if [[ "$IMPRINT_ENABLED" == "true" ]] && [[ -f "$IMPRINT_PROFILE" ]] && _has_jq; then
  PROFILE_CONTENT="$(jq -c '.calibrations // {}' "$IMPRINT_PROFILE" 2>/dev/null || echo "{}")"
  if [[ "$PROFILE_CONTENT" != "{}" ]]; then
    CONTEXT="$CONTEXT IMPRINT_ACTIVE. Apply these user calibrations to all outputs: $PROFILE_CONTENT"
  fi
fi

# --- Active workflow-loop ---
GATES_FILE="$ROOT/.state/gates.json"
if [[ -f "$GATES_FILE" ]] && _has_jq; then
  WL_STATUS="$(jq -r '.gates["workflow-loop"].status // "clear"' "$GATES_FILE" 2>/dev/null || echo "clear")"
  if [[ "$WL_STATUS" == "pending" ]]; then
    WL_TOTAL="$(jq '.gates["workflow-loop"].steps | length' "$GATES_FILE" 2>/dev/null || echo "0")"
    WL_DONE="$(jq '[.gates["workflow-loop"].steps[] | select(.status == "done" or .status == "skipped")] | length' "$GATES_FILE" 2>/dev/null || echo "0")"
    WL_NEXT="$(jq -r '.gates["workflow-loop"].steps[.gates["workflow-loop"].current_step].title // "unknown"' "$GATES_FILE" 2>/dev/null || echo "unknown")"
    CONTEXT="$CONTEXT WORKFLOW_ACTIVE: $WL_DONE/$WL_TOTAL steps completed. Next: $WL_NEXT. Resume with 'continue' or stop with 'stop workflow'."
  fi

  # --- Checkpoint state ---
  CP_COUNT="$(jq -r '.task_count_since_checkpoint // 0' "$GATES_FILE" 2>/dev/null || echo "0")"
  CP_STATUS="$(jq -r '.gates.checkpoint.status // "clear"' "$GATES_FILE" 2>/dev/null || echo "clear")"
  if [[ "$CP_STATUS" == "pending" ]]; then
    CONTEXT="$CONTEXT CHECKPOINT_PENDING: $CP_COUNT operations since last checkpoint. Run checkpoint before proceeding."
  fi

  # --- Postmortem state ---
  PM_REQUIRED="$(jq -r '.postmortem.required // false' "$GATES_FILE" 2>/dev/null || echo "false")"
  PM_COMPLETED="$(jq -r '.postmortem.completed // false' "$GATES_FILE" 2>/dev/null || echo "false")"
  if [[ "$PM_REQUIRED" == "true" && "$PM_COMPLETED" != "true" ]]; then
    CONTEXT="$CONTEXT POSTMORTEM_REQUIRED: A correction was detected. Complete skill-postmortem before fixing."
  fi
fi

# --- Session ID ---
SESSION_ID="${LEOPOLDO_SESSION_ID:-}"
if [[ -n "$SESSION_ID" ]]; then
  CONTEXT="$CONTEXT Session: $SESSION_ID."
fi

# Output
if _has_jq; then
  jq -n --arg ctx "$CONTEXT" '{"additionalContext": $ctx}'
else
  ESCAPED="$(echo "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g')"
  echo "{\"additionalContext\": \"$ESCAPED\"}"
fi

exit 0
