#!/usr/bin/env bash
# tool-logger.sh — PostToolUse hook for Leopoldo.
# Logs tool usage to journal. Tracks task_count_since_checkpoint in gates.json.
# Activates checkpoint gate when threshold reached (default: 3 Edit/Write bursts).
# Detects postmortem.completed signals from Bash tool output.
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
TOOL_OUTPUT=""

if _has_jq; then
  TOOL_NAME="$(echo "$INPUT" | jq -r '.tool_name // .tool // ""' 2>/dev/null || echo "")"
  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .file_path // .tool_input.command // ""' 2>/dev/null || echo "")"
  TOOL_OUTPUT="$(echo "$INPUT" | jq -r '.tool_output // .output // ""' 2>/dev/null || echo "")"
else
  TOOL_NAME="$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"$//' || echo "")"
  FILE_PATH="$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//' || echo "")"
fi

# Read gate state for session_id
read_gate_state

# Log tool.used event to journal
journal_append "{\"event\":\"tool.used\",\"tool\":\"$TOOL_NAME\",\"file\":\"$FILE_PATH\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"

# ──────────────────────────────────────────────
# POSTMORTEM COMPLETION DETECTION
# If a Bash command wrote postmortem.completed to the journal, auto-clear the gate
# ──────────────────────────────────────────────
if [[ "$TOOL_NAME" == "Bash" ]] && _has_jq && [[ -n "$GATE_STATE_RAW" ]]; then
  PM_REQUIRED="$(echo "$GATE_STATE_RAW" | jq -r '.postmortem.required // false' 2>/dev/null)"
  if [[ "$PM_REQUIRED" == "true" ]]; then
    TODAY="$(date +%Y-%m-%d)"
    JOURNAL_FILE="$ROOT/.state/journal/$TODAY.jsonl"
    if [[ -f "$JOURNAL_FILE" ]] && grep -q '"postmortem.completed"' "$JOURNAL_FILE" 2>/dev/null; then
      update_gate_field '.postmortem.completed = true'
      journal_append "{\"event\":\"postmortem.gate_cleared\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
    fi
  fi
fi

# ──────────────────────────────────────────────
# CHECKPOINT COMPLETION DETECTION
# If checkpoint.completed was logged, auto-clear the gate
# ──────────────────────────────────────────────
if [[ "$TOOL_NAME" == "Bash" ]] && _has_jq && [[ -n "$GATE_STATE_RAW" ]]; then
  CP_STATUS="$(get_gate_status "checkpoint" 2>/dev/null || echo "clear")"
  if [[ "$CP_STATUS" == "pending" ]]; then
    TODAY="$(date +%Y-%m-%d)"
    JOURNAL_FILE="$ROOT/.state/journal/$TODAY.jsonl"
    if [[ -f "$JOURNAL_FILE" ]] && grep -q '"checkpoint.completed"' "$JOURNAL_FILE" 2>/dev/null; then
      update_gate_field '
        .gates.checkpoint.status = "clear"
        | .gates.checkpoint.soft_warnings = 0
        | .task_count_since_checkpoint = 0
      '
      journal_append "{\"event\":\"gate.auto_cleared\",\"gate\":\"checkpoint\",\"reason\":\"checkpoint.completed detected in tool-logger\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
    fi
  fi
fi

# ──────────────────────────────────────────────
# WORKFLOW STEP COMPLETION DETECTION
# Watches for workflow.step_completed events in journal
# and marks current step as in_progress on Edit/Write.
# ──────────────────────────────────────────────
if _has_jq && [[ -n "$GATE_STATE_RAW" ]]; then
  WL_STATUS_CHECK="$(echo "$GATE_STATE_RAW" | jq -r '.gates["workflow-loop"].status // "clear"' 2>/dev/null)"

  if [[ "$WL_STATUS_CHECK" == "pending" ]]; then

    # Detection 1: Bash tool wrote workflow.step_completed to journal
    if [[ "$TOOL_NAME" == "Bash" ]]; then
      WL_TODAY="$(date +%Y-%m-%d)"
      WL_JOURNAL_FILE="$ROOT/.state/journal/$WL_TODAY.jsonl"
      if [[ -f "$WL_JOURNAL_FILE" ]]; then
        # Find the most recent workflow.step_completed event
        WL_LAST_COMPLETED_ID="$(grep '"workflow.step_completed"' "$WL_JOURNAL_FILE" 2>/dev/null | tail -1 | jq -r '.step_id // empty' 2>/dev/null || echo "")"
        if [[ -n "$WL_LAST_COMPLETED_ID" ]]; then
          # Check if this step is still pending in gates.json
          WL_STEP_STATUS="$(echo "$GATE_STATE_RAW" | jq -r ".gates[\"workflow-loop\"].steps[] | select(.id == \"$WL_LAST_COMPLETED_ID\") | .status" 2>/dev/null || echo "")"
          if [[ "$WL_STEP_STATUS" == "pending" ]] || [[ "$WL_STEP_STATUS" == "in_progress" ]]; then
            read_gate_state  # Refresh before update
            update_step_status "$WL_LAST_COMPLETED_ID" "done"
            journal_append "{\"event\":\"workflow.step_auto_completed\",\"step_id\":\"$WL_LAST_COMPLETED_ID\",\"detection\":\"journal_event\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
          fi
        fi
      fi
    fi

    # Detection 2: Mark current step as in_progress on any Edit/Write
    if [[ "$TOOL_NAME" == "Edit" ]] || [[ "$TOOL_NAME" == "Write" ]]; then
      WL_CUR_IDX="$(echo "$GATE_STATE_RAW" | jq -r '.gates["workflow-loop"].current_step // 0' 2>/dev/null)"
      WL_CUR_STATUS="$(echo "$GATE_STATE_RAW" | jq -r ".gates[\"workflow-loop\"].steps[$WL_CUR_IDX].status // \"pending\"" 2>/dev/null)"
      if [[ "$WL_CUR_STATUS" == "pending" ]]; then
        WL_CUR_ID="$(echo "$GATE_STATE_RAW" | jq -r ".gates[\"workflow-loop\"].steps[$WL_CUR_IDX].id // \"\"" 2>/dev/null)"
        if [[ -n "$WL_CUR_ID" ]]; then
          update_gate_field ".gates[\"workflow-loop\"].steps[$WL_CUR_IDX].status = \"in_progress\""
        fi
      fi
    fi

  fi
fi

# ──────────────────────────────────────────────
# CHECKPOINT TRACKING (Edit/Write + Agent operations)
# Agent tool counts because subagents make edits that
# hooks cannot see (separate processes). Each Agent
# completion counts as 1 operation toward the checkpoint.
# ──────────────────────────────────────────────
if [[ "$TOOL_NAME" == "Edit" ]] || [[ "$TOOL_NAME" == "Write" ]] || [[ "$TOOL_NAME" == "Agent" ]]; then
  TODAY="$(date +%Y-%m-%d)"
  JOURNAL_FILE="$ROOT/.state/journal/$TODAY.jsonl"

  if [[ -f "$JOURNAL_FILE" ]]; then
    # Count Edit/Write/Agent events since last checkpoint.completed
    LAST_CP_LINE="$(grep -n '"checkpoint\.passed"\|"checkpoint\.completed"' "$JOURNAL_FILE" 2>/dev/null | tail -1 | cut -d: -f1 || echo "0")"

    if [[ "$LAST_CP_LINE" -gt 0 ]]; then
      OP_COUNT="$(tail -n +"$((LAST_CP_LINE + 1))" "$JOURNAL_FILE" | grep -c '"tool":"Edit"\|"tool":"Write"\|"tool":"Agent"' 2>/dev/null || echo "0")"
    else
      OP_COUNT="$(grep -c '"tool":"Edit"\|"tool":"Write"\|"tool":"Agent"' "$JOURNAL_FILE" 2>/dev/null || echo "0")"
    fi

    # Update counter in gates.json for visibility
    if _has_jq && [[ -n "$GATE_STATE_RAW" ]]; then
      update_gate_field ".task_count_since_checkpoint = $OP_COUNT"
    fi

    # Activate checkpoint gate when threshold reached
    THRESHOLD="$GATE_CHECKPOINT_THRESHOLD"
    if [[ "$OP_COUNT" -ge "$THRESHOLD" ]]; then
      if _has_jq && [[ -n "$GATE_STATE_RAW" ]]; then
        CURRENT_STATUS="$(get_gate_status "checkpoint")"
        if [[ "$CURRENT_STATUS" == "clear" ]] || [[ "$CURRENT_STATUS" == "passed" ]]; then
          update_gate_field '.gates.checkpoint.status = "pending"'
          journal_append "{\"event\":\"gate.activated\",\"gate\":\"checkpoint\",\"reason\":\"$OP_COUNT operations since last checkpoint (threshold: $THRESHOLD)\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
        fi
      fi
    fi
  fi
fi

exit 0
