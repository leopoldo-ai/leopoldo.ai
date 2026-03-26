#!/usr/bin/env bash
# tool-logger.sh — PostToolUse hook for Leopoldo.
# Logs tool usage to journal. Activates checkpoint gate when edit threshold reached.
# Always exits 0 (PostToolUse cannot block).

set -euo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

ROOT="$(find_project_root)"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Read tool info from stdin
INPUT="$(cat)"

TOOL_NAME=""
FILE_PATH=""

if _has_jq; then
  TOOL_NAME="$(echo "$INPUT" | jq -r '.tool_name // .tool // ""' 2>/dev/null || echo "")"
  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .file_path // .tool_input.command // ""' 2>/dev/null || echo "")"
else
  # Best-effort extraction without jq
  TOOL_NAME="$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"$//' || echo "")"
  FILE_PATH="$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//' || echo "")"
fi

# Read gate state for session_id
read_gate_state

# Log tool.used event to journal
journal_append "{\"event\":\"tool.used\",\"tool\":\"$TOOL_NAME\",\"file\":\"$FILE_PATH\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"

# Count Edit|Write events since last checkpoint.passed
# Only check if tool is Edit or Write (not Bash)
if [[ "$TOOL_NAME" == "Edit" ]] || [[ "$TOOL_NAME" == "Write" ]]; then
  TODAY="$(date +%Y-%m-%d)"
  JOURNAL_FILE="$ROOT/.state/journal/$TODAY.jsonl"

  if [[ -f "$JOURNAL_FILE" ]]; then
    # Count Edit/Write events since last checkpoint.passed
    # Get line number of last checkpoint.passed event
    LAST_CP_LINE="$(grep -n '"checkpoint.passed"' "$JOURNAL_FILE" 2>/dev/null | tail -1 | cut -d: -f1 || echo "0")"

    if [[ "$LAST_CP_LINE" -gt 0 ]]; then
      EDIT_COUNT="$(tail -n +"$((LAST_CP_LINE + 1))" "$JOURNAL_FILE" | grep -c '"tool":"Edit"\|"tool":"Write"' 2>/dev/null || echo "0")"
    else
      EDIT_COUNT="$(grep -c '"tool":"Edit"\|"tool":"Write"' "$JOURNAL_FILE" 2>/dev/null || echo "0")"
    fi

    # Check against threshold
    THRESHOLD="$GATE_CHECKPOINT_THRESHOLD"
    if [[ "$EDIT_COUNT" -ge "$THRESHOLD" ]]; then
      # Activate checkpoint gate if not already pending
      if _has_jq && [[ -n "$GATE_STATE_RAW" ]]; then
        CURRENT_STATUS="$(get_gate_status "checkpoint")"
        if [[ "$CURRENT_STATUS" == "clear" ]]; then
          update_gate_field '.gates.checkpoint.status = "pending"'
          journal_append "{\"event\":\"gate.activated\",\"gate\":\"checkpoint\",\"reason\":\"$EDIT_COUNT edits since last checkpoint\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
        fi
      fi
    fi
  fi
fi

exit 0
