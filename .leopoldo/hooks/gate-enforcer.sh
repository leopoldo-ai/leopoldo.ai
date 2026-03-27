#!/usr/bin/env bash
# gate-enforcer.sh — Stop hook for Leopoldo.
# Enforces pending quality gates. Exit 2 = block Claude from finishing.
# Also reminds about unprocessed Imprint observations.
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

# Iterate over all gates and check for pending status
GATE_NAMES="$(echo "$GATE_STATE_RAW" | jq -r '.gates | keys[]' 2>/dev/null)" || exit 0

BLOCKED=false
BLOCK_MESSAGE=""

for gate in $GATE_NAMES; do
  status="$(get_gate_status "$gate")"

  if [[ "$status" != "pending" ]]; then
    continue
  fi

  # Check for user override
  if check_override "$gate"; then
    # Clear the override and the gate
    update_gate_field "
      .gates[\"$gate\"].status = \"overridden\"
      | .overrides = (.overrides | map(select(. != \"$gate\")))
    "
    journal_append "{\"event\":\"gate.overridden\",\"gate\":\"$gate\",\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
    continue
  fi

  enforcement="$(get_enforcement_level "$gate")"

  if [[ "$enforcement" == "hard" ]]; then
    # Build descriptive message based on gate type
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
      # Escalated to hard block
      BLOCK_MESSAGE="Gate '$gate' has been warned $warnings times and is now blocking. Resolve the $gate before proceeding. User can say 'skip gate' to override."
      BLOCKED=true
      break
    else
      # Increment soft_warnings, warn but don't block
      new_warnings=$((warnings + 1))
      update_gate_field ".gates[\"$gate\"].soft_warnings = $new_warnings"
      journal_append "{\"event\":\"gate.soft_warning\",\"gate\":\"$gate\",\"warnings\":$new_warnings,\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"
      echo "{\"additionalContext\": \"Warning: '$gate' gate is pending ($new_warnings/2 warnings before block). Resolve it soon.\"}" >&2
    fi
  fi
done

# Remind about unprocessed Imprint observations (best-effort, not blocking)
# Primary processing happens at next session start; this is a secondary reminder
IMPRINT_OBS="$ROOT/.leopoldo/imprint/observations.jsonl"
if [[ -f "$IMPRINT_OBS" ]]; then
  OBS_COUNT="$(wc -l < "$IMPRINT_OBS" | tr -d ' ')"
  if [[ "$OBS_COUNT" -gt 0 ]]; then
    echo "{\"additionalContext\": \"Imprint: $OBS_COUNT unprocessed observations. If possible, process them now (read observations.jsonl + profile.json, synthesize, write profile.json, archive to observations.processed.jsonl). If not, they will be processed at next session start.\"}" >&2
  fi
fi

# Log the check
journal_append "{\"event\":\"gate.check\",\"blocked\":$BLOCKED,\"session_id\":\"$GATE_SESSION_ID\",\"timestamp\":\"$TIMESTAMP\"}"

if [[ "$BLOCKED" == "true" ]]; then
  echo "$BLOCK_MESSAGE" >&2
  exit 2
fi

exit 0
