#!/usr/bin/env bash
# subagent-tracker.sh — SubagentStart/SubagentStop hook for Leopoldo.
# Tracks subagent lifecycle and parses transcripts for observability.
# Handles both events: detects which event from the input JSON.
# Always exits 0 (never blocks subagent operations).

set -euo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

ROOT="$(find_project_root)"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Read hook input from stdin
INPUT="$(cat)"

if ! _has_jq; then
  exit 0
fi

# Detect which event this is based on available fields
# SubagentStop has transcript_path and duration_ms; SubagentStart does not
HAS_TRANSCRIPT="$(echo "$INPUT" | jq -r 'has("transcript_path") // false' 2>/dev/null || echo "false")"
HAS_DURATION="$(echo "$INPUT" | jq -r 'has("duration_ms") // false' 2>/dev/null || echo "false")"

# Extract common fields
AGENT_TYPE="$(echo "$INPUT" | jq -r '.agent_type // .subagent_type // "unknown"' 2>/dev/null || echo "unknown")"
SUB_SESSION_ID="$(echo "$INPUT" | jq -r '.session_id // ""' 2>/dev/null || echo "")"

# Get parent session ID from env var or gates.json
SESSION_ID="${LEOPOLDO_SESSION_ID:-}"
if [[ -z "$SESSION_ID" ]]; then
  read_gate_state
  SESSION_ID="$GATE_SESSION_ID"
fi

# ──────────────────────────────────────────────
# SubagentStop — parse transcript, enrich journal
# ──────────────────────────────────────────────
if [[ "$HAS_TRANSCRIPT" == "true" ]] || [[ "$HAS_DURATION" == "true" ]]; then
  DURATION_MS="$(echo "$INPUT" | jq -r '.duration_ms // 0' 2>/dev/null || echo "0")"
  TOOL_USE_COUNT="$(echo "$INPUT" | jq -r '.tool_use_count // 0' 2>/dev/null || echo "0")"
  TRANSCRIPT_PATH="$(echo "$INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")"

  # Parse transcript for detailed activity
  FILES_EDITED="[]"
  COMMANDS_RUN="[]"
  ERROR_COUNT=0
  EDIT_WRITE_COUNT=0

  if [[ -n "$TRANSCRIPT_PATH" ]] && [[ -f "$TRANSCRIPT_PATH" ]]; then
    # Cap at 1000 lines to avoid parsing huge transcripts
    TRANSCRIPT_HEAD="$(head -1000 "$TRANSCRIPT_PATH" 2>/dev/null || echo "")"

    if [[ -n "$TRANSCRIPT_HEAD" ]]; then
      # Extract unique file paths from Edit and Write tool calls
      FILES_EDITED="$(echo "$TRANSCRIPT_HEAD" | \
        grep -o '"name"[[:space:]]*:[[:space:]]*"\(Edit\|Write\)"' -A 50 2>/dev/null | \
        grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | \
        sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//' | \
        sort -u | \
        jq -R -s 'split("\n") | map(select(length > 0))' 2>/dev/null || echo "[]")"

      # Count Edit/Write operations
      EDIT_WRITE_COUNT="$(echo "$TRANSCRIPT_HEAD" | \
        grep -c '"name"[[:space:]]*:[[:space:]]*"\(Edit\|Write\)"' 2>/dev/null || echo "0")"

      # Extract Bash commands (first 100 chars each)
      COMMANDS_RUN="$(echo "$TRANSCRIPT_HEAD" | \
        grep '"name"[[:space:]]*:[[:space:]]*"Bash"' -A 20 2>/dev/null | \
        grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | \
        sed 's/.*"command"[[:space:]]*:[[:space:]]*"//;s/"$//' | \
        head -20 | \
        cut -c 1-100 | \
        jq -R -s 'split("\n") | map(select(length > 0))' 2>/dev/null || echo "[]")"

      # Count errors in tool results
      ERROR_COUNT="$(echo "$TRANSCRIPT_HEAD" | \
        grep -c '"is_error"[[:space:]]*:[[:space:]]*true' 2>/dev/null || echo "0")"
    fi
  fi

  # Log subagent completion with detailed activity
  journal_append "$(jq -n -c \
    --arg event "subagent.completed" \
    --arg agent_type "$AGENT_TYPE" \
    --arg sub_sid "$SUB_SESSION_ID" \
    --argjson duration "$DURATION_MS" \
    --argjson tool_count "$TOOL_USE_COUNT" \
    --argjson files "$FILES_EDITED" \
    --argjson commands "$COMMANDS_RUN" \
    --argjson errors "$ERROR_COUNT" \
    --argjson edit_write_count "$EDIT_WRITE_COUNT" \
    --arg sid "$SESSION_ID" \
    --arg ts "$TIMESTAMP" \
    '{
      event: $event,
      agent_type: $agent_type,
      subagent_session_id: $sub_sid,
      duration_ms: $duration,
      tool_use_count: $tool_count,
      files_edited: $files,
      commands_run: $commands,
      error_count: $errors,
      edit_write_count: $edit_write_count,
      session_id: $sid,
      timestamp: $ts
    }' 2>/dev/null || echo "{\"event\":\"subagent.completed\",\"agent_type\":\"$AGENT_TYPE\",\"session_id\":\"$SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}")"

  exit 0
fi

# ──────────────────────────────────────────────
# SubagentStart — log subagent spawn
# ──────────────────────────────────────────────
PROMPT_RAW="$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null || echo "")"
PROMPT_EXCERPT="$(echo "$PROMPT_RAW" | head -c 200 | tr '\n' ' ')"

journal_append "$(jq -n -c \
  --arg event "subagent.started" \
  --arg agent_type "$AGENT_TYPE" \
  --arg prompt_excerpt "$PROMPT_EXCERPT" \
  --arg sub_sid "$SUB_SESSION_ID" \
  --arg sid "$SESSION_ID" \
  --arg ts "$TIMESTAMP" \
  '{
    event: $event,
    agent_type: $agent_type,
    prompt_excerpt: $prompt_excerpt,
    subagent_session_id: $sub_sid,
    session_id: $sid,
    timestamp: $ts
  }' 2>/dev/null || echo "{\"event\":\"subagent.started\",\"agent_type\":\"$AGENT_TYPE\",\"session_id\":\"$SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}")"

exit 0
