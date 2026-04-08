#!/usr/bin/env bash
# core.sh — Shared functions for Leopoldo event layer hooks.
# Sourced by all hooks. Never executed directly.
#
# Resilience: every function handles missing files, corrupt JSON,
# and edge cases gracefully. Hooks fail-open (exit 0) on error.

set -euo pipefail

# --- Project root discovery ---

_LEOPOLDO_ROOT=""

find_project_root() {
  if [[ -n "$_LEOPOLDO_ROOT" ]]; then
    echo "$_LEOPOLDO_ROOT"
    return 0
  fi

  local dir="${PWD}"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.leopoldo-manifest.json" ]] || [[ -d "$dir/.state" ]]; then
      _LEOPOLDO_ROOT="$dir"
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  # Fallback: use the directory where this script lives (two levels up from hooks/)
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  _LEOPOLDO_ROOT="$(dirname "$(dirname "$script_dir")")"
  echo "$_LEOPOLDO_ROOT"
}

# --- JSON helpers ---

_has_jq() {
  command -v jq &>/dev/null
}

# --- Gate state ---

# Globals set by read_gate_state
GATE_STATE_RAW=""
GATE_SESSION_ID=""
GATE_TASK_COUNT=0
GATE_CHECKPOINT_THRESHOLD=6
GATE_CURRENT_PHASE=""

read_gate_state() {
  local root
  root="$(find_project_root)"
  local gates_file="$root/.state/gates.json"

  # Reset globals to defaults
  GATE_STATE_RAW=""
  GATE_SESSION_ID=""
  GATE_TASK_COUNT=0
  GATE_CHECKPOINT_THRESHOLD=6
  GATE_CURRENT_PHASE=""

  if [[ ! -f "$gates_file" ]]; then
    return 0
  fi

  GATE_STATE_RAW="$(cat "$gates_file" 2>/dev/null)" || return 0

  # Validate JSON
  if _has_jq; then
    if ! echo "$GATE_STATE_RAW" | jq empty 2>/dev/null; then
      GATE_STATE_RAW=""
      return 0
    fi
    GATE_SESSION_ID="$(echo "$GATE_STATE_RAW" | jq -r '.session_id // ""')"
    GATE_TASK_COUNT="$(echo "$GATE_STATE_RAW" | jq -r '.task_count_since_checkpoint // 0')"
    GATE_CHECKPOINT_THRESHOLD="$(echo "$GATE_STATE_RAW" | jq -r '.checkpoint_threshold // 6')"
    GATE_CURRENT_PHASE="$(echo "$GATE_STATE_RAW" | jq -r '.current_phase // ""')"
  else
    # Fallback: grep-based extraction
    GATE_SESSION_ID="$(grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$gates_file" 2>/dev/null | head -1 | sed 's/.*: *"//;s/"$//' || echo "")"
    GATE_TASK_COUNT="$(grep -o '"task_count_since_checkpoint"[[:space:]]*:[[:space:]]*[0-9]*' "$gates_file" 2>/dev/null | head -1 | sed 's/.*: *//' || echo "0")"
    GATE_CHECKPOINT_THRESHOLD="$(grep -o '"checkpoint_threshold"[[:space:]]*:[[:space:]]*[0-9]*' "$gates_file" 2>/dev/null | head -1 | sed 's/.*: *//' || echo "6")"
    GATE_CURRENT_PHASE="$(grep -o '"current_phase"[[:space:]]*:[[:space:]]*"[^"]*"' "$gates_file" 2>/dev/null | head -1 | sed 's/.*: *"//;s/"$//' || echo "")"
  fi
}

write_gate_state() {
  local content="$1"
  local root
  root="$(find_project_root)"
  local gates_file="$root/.state/gates.json"
  local tmp_file="$gates_file.tmp"

  mkdir -p "$(dirname "$gates_file")"
  echo "$content" > "$tmp_file"
  mv "$tmp_file" "$gates_file"
}

# --- Journal ---

journal_append() {
  local event="$1"
  local root
  root="$(find_project_root)"
  local journal_dir="$root/.state/journal"
  local today
  today="$(date +%Y-%m-%d)"
  local journal_file="$journal_dir/$today.jsonl"

  mkdir -p "$journal_dir"
  echo "$event" >> "$journal_file"
}

# --- Enforcement helpers ---

get_enforcement_level() {
  local gate_name="$1"

  if [[ -z "$GATE_STATE_RAW" ]]; then
    echo "soft"
    return 0
  fi

  if _has_jq; then
    local level
    level="$(echo "$GATE_STATE_RAW" | jq -r ".gates[\"$gate_name\"].enforcement // \"soft\"")"
    echo "$level"
  else
    # Fallback: default levels
    case "$gate_name" in
      security-gate|phase-gate) echo "hard" ;;
      *) echo "soft" ;;
    esac
  fi
}

check_override() {
  local gate_name="$1"

  if [[ -z "$GATE_STATE_RAW" ]]; then
    return 1
  fi

  if _has_jq; then
    local found
    found="$(echo "$GATE_STATE_RAW" | jq -r ".overrides // [] | index(\"$gate_name\") // empty" 2>/dev/null)"
    if [[ -n "$found" ]]; then
      return 0
    fi
  else
    if echo "$GATE_STATE_RAW" | grep -q "\"$gate_name\"" 2>/dev/null; then
      # Rough check — may false-positive but safe (fail-open direction)
      return 0
    fi
  fi

  return 1
}

# --- Gate manipulation helpers ---

# Get a gate's status from the raw state
get_gate_status() {
  local gate_name="$1"

  if [[ -z "$GATE_STATE_RAW" ]]; then
    echo "clear"
    return 0
  fi

  if _has_jq; then
    echo "$GATE_STATE_RAW" | jq -r ".gates[\"$gate_name\"].status // \"clear\""
  else
    echo "clear"
  fi
}

# Get soft_warnings count for a gate
get_soft_warnings() {
  local gate_name="$1"

  if [[ -z "$GATE_STATE_RAW" ]]; then
    echo "0"
    return 0
  fi

  if _has_jq; then
    echo "$GATE_STATE_RAW" | jq -r ".gates[\"$gate_name\"].soft_warnings // 0"
  else
    echo "0"
  fi
}

# Update gates.json using jq (noop without jq)
update_gate_field() {
  local jq_expression="$1"

  if ! _has_jq; then
    return 0
  fi

  if [[ -z "$GATE_STATE_RAW" ]]; then
    return 0
  fi

  local updated
  updated="$(echo "$GATE_STATE_RAW" | jq "$jq_expression")" || return 0
  write_gate_state "$updated"
  GATE_STATE_RAW="$updated"
}

# --- Workflow Loop helpers ---

# Globals set by read_workflow_loop
WL_STATUS=""
WL_TOTAL=0
WL_DONE=0
WL_SOURCE=""
WL_CURRENT_STEP=0
WL_STALL_COUNT=0
WL_MAX_STALL=3

read_workflow_loop() {
  # Reset globals
  WL_STATUS="clear"
  WL_TOTAL=0
  WL_DONE=0
  WL_SOURCE=""
  WL_CURRENT_STEP=0
  WL_STALL_COUNT=0
  WL_MAX_STALL=3

  if [[ -z "$GATE_STATE_RAW" ]]; then
    return 0
  fi

  if ! _has_jq; then
    return 0
  fi

  WL_STATUS="$(echo "$GATE_STATE_RAW" | jq -r '.gates["workflow-loop"].status // "clear"')"
  if [[ "$WL_STATUS" == "clear" ]]; then
    return 0
  fi

  WL_TOTAL="$(echo "$GATE_STATE_RAW" | jq '.gates["workflow-loop"].steps | length')"
  WL_DONE="$(echo "$GATE_STATE_RAW" | jq '[.gates["workflow-loop"].steps[] | select(.status == "done" or .status == "skipped")] | length')"
  WL_SOURCE="$(echo "$GATE_STATE_RAW" | jq -r '.gates["workflow-loop"].source // ""')"
  WL_CURRENT_STEP="$(echo "$GATE_STATE_RAW" | jq -r '.gates["workflow-loop"].current_step // 0')"
  WL_STALL_COUNT="$(echo "$GATE_STATE_RAW" | jq -r '.gates["workflow-loop"].stall_count // 0')"
  WL_MAX_STALL="$(echo "$GATE_STATE_RAW" | jq -r '.gates["workflow-loop"].max_stall // 3')"
}

# Update a specific step's status in the workflow-loop
# Usage: update_step_status "step_id" "done"
update_step_status() {
  local step_id="$1"
  local new_status="$2"

  if ! _has_jq || [[ -z "$GATE_STATE_RAW" ]]; then
    return 0
  fi

  # Update the step status
  update_gate_field "
    .gates[\"workflow-loop\"].steps = [
      .gates[\"workflow-loop\"].steps[] |
      if .id == \"$step_id\" then .status = \"$new_status\" else . end
    ]
  "

  # If marking done or skipped, reset stall counter and advance current_step
  if [[ "$new_status" == "done" ]] || [[ "$new_status" == "skipped" ]]; then
    # Find the next pending step index
    local next_idx
    next_idx="$(echo "$GATE_STATE_RAW" | jq '
      [.gates["workflow-loop"].steps | to_entries[] | select(.value.status == "pending")] | .[0].key // -1
    ')" 2>/dev/null || next_idx="-1"

    if [[ "$next_idx" == "-1" ]]; then
      # All steps done — mark gate as completed
      update_gate_field '
        .gates["workflow-loop"].status = "completed"
        | .gates["workflow-loop"].stall_count = 0
      '
    else
      update_gate_field "
        .gates[\"workflow-loop\"].current_step = $next_idx
        | .gates[\"workflow-loop\"].stall_count = 0
      "
    fi
  fi
}

# Build the visual progress display for the workflow-loop
# Returns the formatted string via stdout
build_progress_display() {
  if ! _has_jq || [[ -z "$GATE_STATE_RAW" ]]; then
    echo ""
    return 0
  fi

  local total="$WL_TOTAL"
  local done="$WL_DONE"
  local current="$WL_CURRENT_STEP"
  local output=""

  output="⏳ Workflow in progress ($done/$total completed)"$'\n'$'\n'

  # Build step list
  local i=0
  while [[ $i -lt $total ]]; do
    local title
    title="$(echo "$GATE_STATE_RAW" | jq -r ".gates[\"workflow-loop\"].steps[$i].title")"
    local status
    status="$(echo "$GATE_STATE_RAW" | jq -r ".gates[\"workflow-loop\"].steps[$i].status")"

    case "$status" in
      done)        output="$output  ✅ $title"$'\n' ;;
      skipped)     output="$output  ⏭️  $title (skipped)"$'\n' ;;
      in_progress) output="$output  → $title (in progress)"$'\n' ;;
      pending)
        if [[ $i -eq $current ]]; then
          output="$output  → $title (next)"$'\n'
        else
          output="$output  ○ $title"$'\n'
        fi
        ;;
    esac
    i=$((i + 1))
  done

  local next_title
  next_title="$(echo "$GATE_STATE_RAW" | jq -r ".gates[\"workflow-loop\"].steps[$current].title // \"next step\"")"
  output="$output"$'\n'"Next step: $next_title"$'\n'"Complete this step, then continue with the remaining ones."$'\n'"To stop: \"stop\" or \"skip gate\""

  echo "$output"
}
