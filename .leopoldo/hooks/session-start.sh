#!/usr/bin/env bash
# session-start.sh — SessionStart hook for Leopoldo.
# Initializes session state, resets gate counters, loads Imprint profile.
# Always exits 0. Never blocks session start.

set -euo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

ROOT="$(find_project_root)"

# Ensure .state directories exist
mkdir -p "$ROOT/.state/journal"
mkdir -p "$ROOT/.state/snapshots"
mkdir -p "$ROOT/.state/evolution"

# Generate session ID
SESSION_ID="ses_$(date +%Y%m%d_%H%M%S)"

# Create or reset gates.json
GATES_FILE="$ROOT/.state/gates.json"

if [[ -f "$GATES_FILE" ]] && _has_jq && jq empty "$GATES_FILE" 2>/dev/null; then
  # Preserve enforcement levels and checkpoint_threshold, reset counters
  UPDATED="$(jq \
    --arg sid "$SESSION_ID" \
    '.session_id = $sid
     | .task_count_since_checkpoint = 0
     | .gates.checkpoint.soft_warnings = 0
     | .gates["doc-gate"].soft_warnings = 0
     | .overrides = []' \
    "$GATES_FILE")"
  write_gate_state "$UPDATED"
else
  # Create fresh gates.json
  write_gate_state "$(cat <<EOF
{
  "version": "1.0.0",
  "session_id": "$SESSION_ID",
  "task_count_since_checkpoint": 0,
  "checkpoint_threshold": 6,
  "current_phase": null,
  "gates": {
    "checkpoint": {"status": "clear", "enforcement": "soft", "soft_warnings": 0},
    "doc-gate": {"status": "clear", "enforcement": "soft", "soft_warnings": 0},
    "phase-gate": {"status": "clear", "enforcement": "hard", "skills_required": [], "skills_invoked": []},
    "security-gate": {"status": "clear", "enforcement": "hard"}
  },
  "overrides": []
}
EOF
)"
fi

# Log session start to journal
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
journal_append "{\"event\":\"session.start\",\"session_id\":\"$SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"

# Build additional context
CONTEXT="Leopoldo session $SESSION_ID started. Gate enforcement active."

# Check for pending evolution tasks
STATE_FILE="$ROOT/.state/state.json"
if [[ -f "$STATE_FILE" ]] && _has_jq; then
  PENDING="$(jq -r '.evolution.pending_tasks // [] | length' "$STATE_FILE" 2>/dev/null || echo "0")"
  if [[ "$PENDING" -gt 0 ]]; then
    CONTEXT="$CONTEXT $PENDING pending evolution task(s)."
  fi
fi

# Load Imprint profile if present
IMPRINT_CONTEXT=""
IMPRINT_FILE="$ROOT/.leopoldo/imprint/profile.json"
if [[ -f "$IMPRINT_FILE" ]] && _has_jq; then
  CALIBRATIONS="$(jq -r '.calibrations // {} | to_entries | map("\(.key): \(.value)") | join(", ")' "$IMPRINT_FILE" 2>/dev/null || echo "")"
  if [[ -n "$CALIBRATIONS" ]]; then
    IMPRINT_CONTEXT="Imprint active. Calibrations: $CALIBRATIONS"
    CONTEXT="$CONTEXT $IMPRINT_CONTEXT"
  fi
fi

# Output JSON for Claude Code
cat <<EOF
{"additionalContext": "$CONTEXT"}
EOF

exit 0
