#!/usr/bin/env bash
# gate-enforcer.sh — Stop hook for Leopoldo.
# Enforces pending quality gates AND postmortem obligation.
# Exit 2 = block Claude from finishing.
# Fail-open: if gates.json missing/corrupt/script error, exit 0.

set -euo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

# Read current gate state
read_gate_state

# No state or no raw data — fail-open
if [[ -z "$GATE_STATE_RAW" ]]; then
  exit 0
fi

# jq is required for gate enforcement logic
if ! _has_jq; then
  exit 0
fi

ROOT="$(find_project_root)"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

BLOCKED=false
BLOCK_MESSAGE=""

# ──────────────────────────────────────────────
# POSTMORTEM GATE (highest priority, always hard)
# ──────────────────────────────────────────────
PM_REQUIRED="$(echo "$GATE_STATE_RAW" | jq -r '.postmortem.required // false' 2>/dev/null)"
PM_COMPLETED="$(echo "$GATE_STATE_RAW" | jq -r '.postmortem.completed // false' 2>/dev/null)"

if [[ "$PM_REQUIRED" == "true" && "$PM_COMPLETED" != "true" ]]; then
  # Check journal for postmortem.completed event AFTER detection
  PM_DETECTED_AT="$(echo "$GATE_STATE_RAW" | jq -r '.postmortem.detected_at // ""' 2>/dev/null)"
  TODAY="$(date +%Y-%m-%d)"
  JOURNAL_FILE="$ROOT/.state/journal/$TODAY.jsonl"

  PM_DONE=false
  if [[ -f "$JOURNAL_FILE" ]]; then
    # Check if postmortem.completed was logged after the detection
    if grep -q '"postmortem.completed"' "$JOURNAL_FILE" 2>/dev/null; then
      PM_DONE=true
      # Auto-clear the postmortem gate
      update_gate_field '.postmortem.completed = true'
    fi
  fi

  if [[ "$PM_DONE" == "false" ]]; then
    BLOCKED=true
    BLOCK_MESSAGE="🔴 POSTMORTEM GATE BLOCKING. A correction was detected but no postmortem was completed. You MUST run skill-postmortem (Phases 1-3) and log postmortem.completed to the journal BEFORE fixing or proceeding. This is non-negotiable. User can say 'skip gate' to override."

    # Check for user override
    if check_override "postmortem"; then
      update_gate_field '
        .postmortem.required = false
        | .postmortem.completed = false
        | .overrides = (.overrides | map(select(. != "postmortem")))
      '
      journal_append "{\"event\":\"gate.overridden\",\"gate\":\"postmortem\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
      BLOCKED=false
      BLOCK_MESSAGE=""
    fi
  fi
fi

# ──────────────────────────────────────────────
# WORKFLOW LOOP GATE (between postmortem and standard gates)
# ──────────────────────────────────────────────
if [[ "$BLOCKED" == "false" ]]; then
  read_workflow_loop

  if [[ "$WL_STATUS" == "pending" ]]; then
    # Check for user override
    if check_override "workflow-loop"; then
      update_gate_field '
        .gates["workflow-loop"].status = "clear"
        | .gates["workflow-loop"].steps = []
        | .gates["workflow-loop"].stall_count = 0
        | .overrides = (.overrides | map(select(. != "workflow-loop")))
      '
      journal_append "{\"event\":\"workflow.overridden\",\"reason\":\"user_request\",\"steps_completed\":$WL_DONE,\"steps_total\":$WL_TOTAL,\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
    elif [[ "$WL_DONE" -lt "$WL_TOTAL" ]]; then
      # Steps remain — check for stall
      if [[ "$WL_STALL_COUNT" -ge "$WL_MAX_STALL" ]]; then
        # Anti-stall: suggest options, don't hard block
        WL_CURRENT_TITLE="$(echo "$GATE_STATE_RAW" | jq -r ".gates[\"workflow-loop\"].steps[$WL_CURRENT_STEP].title // \"current step\"")"
        BLOCK_MESSAGE="$(printf '⚠️ Step "%s" appears stuck (%d attempts)\n\n  Options:\n  a) Skip and continue → say "skip step"\n  b) Retry with a different approach\n  c) Stop here → say "stop" or "skip gate"\n\n  What do you prefer?' "$WL_CURRENT_TITLE" "$WL_STALL_COUNT")"
        # Show warning but don't block — let Claude/user decide
        echo "$BLOCK_MESSAGE" >&2
        journal_append "{\"event\":\"workflow.stall_detected\",\"step\":\"$WL_CURRENT_TITLE\",\"stall_count\":$WL_STALL_COUNT,\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
      else
        # Normal block: show progress, increment stall
        PROGRESS="$(build_progress_display)"
        BLOCK_MESSAGE="$PROGRESS"
        BLOCKED=true

        # Increment stall counter
        WL_NEW_STALL=$((WL_STALL_COUNT + 1))
        update_gate_field ".gates[\"workflow-loop\"].stall_count = $WL_NEW_STALL"

        journal_append "{\"event\":\"workflow.gate_blocked\",\"done\":$WL_DONE,\"total\":$WL_TOTAL,\"stall_count\":$WL_NEW_STALL,\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
      fi
    else
      # All steps done — clear the gate and celebrate
      update_gate_field '
        .gates["workflow-loop"].status = "completed"
        | .gates["workflow-loop"].stall_count = 0
      '
      journal_append "{\"event\":\"workflow.completed\",\"steps_completed\":$WL_DONE,\"steps_total\":$WL_TOTAL,\"source\":\"$WL_SOURCE\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"

      # Show completion feedback (non-blocking)
      echo "✅ Workflow completed ($WL_TOTAL/$WL_TOTAL). All steps have been completed." >&2
    fi
  fi
fi

# ──────────────────────────────────────────────
# STANDARD GATES (checkpoint, doc-gate, phase-gate, security-gate)
# ──────────────────────────────────────────────
if [[ "$BLOCKED" == "false" ]]; then
  GATE_NAMES="$(echo "$GATE_STATE_RAW" | jq -r '.gates | keys[]' 2>/dev/null)" || exit 0

  for gate in $GATE_NAMES; do
    status="$(get_gate_status "$gate")"

    if [[ "$status" != "pending" ]]; then
      continue
    fi

    # Auto-clear checkpoint gate if checkpoint.completed was logged
    if [[ "$gate" == "checkpoint" ]]; then
      TODAY="$(date +%Y-%m-%d)"
      JOURNAL_FILE="$ROOT/.state/journal/$TODAY.jsonl"
      if [[ -f "$JOURNAL_FILE" ]]; then
        # Find last gate.activated for checkpoint and last checkpoint.completed
        LAST_ACTIVATED="$(grep -n '"gate.activated".*"checkpoint"' "$JOURNAL_FILE" 2>/dev/null | tail -1 | cut -d: -f1 || echo "0")"
        LAST_COMPLETED="$(grep -n '"checkpoint.completed"' "$JOURNAL_FILE" 2>/dev/null | tail -1 | cut -d: -f1 || echo "0")"

        if [[ "$LAST_COMPLETED" -gt "$LAST_ACTIVATED" ]] && [[ "$LAST_COMPLETED" -gt 0 ]]; then
          # Checkpoint was completed after it was activated — auto-clear
          update_gate_field '
            .gates.checkpoint.status = "clear"
            | .gates.checkpoint.soft_warnings = 0
            | .task_count_since_checkpoint = 0
          '
          # Write checkpoint.completed so the counter in tool-logger has a fresh reset point
          journal_append "{\"event\":\"checkpoint.completed\",\"source\":\"gate_enforcer_auto_clear\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
          journal_append "{\"event\":\"gate.auto_cleared\",\"gate\":\"checkpoint\",\"reason\":\"checkpoint.completed found in journal\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
          continue
        fi
      fi
    fi

    # Check for user override
    if check_override "$gate"; then
      update_gate_field "
        .gates[\"$gate\"].status = \"overridden\"
        | .overrides = (.overrides | map(select(. != \"$gate\")))
      "
      journal_append "{\"event\":\"gate.overridden\",\"gate\":\"$gate\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
      continue
    fi

    enforcement="$(get_enforcement_level "$gate")"

    if [[ "$enforcement" == "hard" ]]; then
      case "$gate" in
        security-gate)
          BLOCK_MESSAGE="Security gate pending. Resolve all security concerns before proceeding."
          ;;
        phase-gate)
          required="$(echo "$GATE_STATE_RAW" | jq -r '.gates["phase-gate"].skills_required // [] | length' 2>/dev/null || echo "?")"
          invoked="$(echo "$GATE_STATE_RAW" | jq -r '.gates["phase-gate"].skills_invoked // [] | length' 2>/dev/null || echo "?")"
          phase="$(echo "$GATE_STATE_RAW" | jq -r '.current_phase // "unknown"' 2>/dev/null || echo "unknown")"
          BLOCK_MESSAGE="Phase gate: $invoked skills invoked of $required required for phase '$phase'. Complete required skills before proceeding."
          ;;
        *)
          BLOCK_MESSAGE="Gate '$gate' is pending (enforcement: hard). Resolve before proceeding."
          ;;
      esac
      BLOCKED=true
      break
    fi

    if [[ "$enforcement" == "soft" ]]; then
      warnings="$(get_soft_warnings "$gate")"

      if [[ "$warnings" -ge 2 ]]; then
        BLOCK_MESSAGE="Gate '$gate' has been warned $warnings times and is now blocking. Resolve the $gate before proceeding. User can say 'skip gate' to override."
        BLOCKED=true
        break
      else
        new_warnings=$((warnings + 1))
        update_gate_field ".gates[\"$gate\"].soft_warnings = $new_warnings"
        journal_append "{\"event\":\"gate.soft_warning\",\"gate\":\"$gate\",\"warnings\":$new_warnings,\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
        echo "{\"additionalContext\": \"Warning: '$gate' gate is pending ($new_warnings/2 warnings before block). Resolve it soon.\"}" >&2
      fi
    fi
  done
fi

# Log the check
journal_append "{\"event\":\"gate.check\",\"blocked\":$BLOCKED,\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"

if [[ "$BLOCKED" == "true" ]]; then
  echo "$BLOCK_MESSAGE" >&2
  exit 2
fi

exit 0
