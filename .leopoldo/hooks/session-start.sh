#!/usr/bin/env bash
# session-start.sh — SessionStart hook for Leopoldo.
# Initializes session state, resets gate counters, and prepares the session.
# Always exits 0. Never blocks session start.

set -euo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

ROOT="$(find_project_root)"

# ============================================================
# LICENSE GATE (must be first — blocks everything if invalid)
# ============================================================

# Skip license check for free plugin (full-stack) or standalone use
if [ ! -f "$ROOT/.leopoldo/leopoldo-client.json" ]; then
  # No client config = free plugin or standalone use
  LICENSE_STATUS="FREE"
else
  # Run cross-platform license verification
  LICENSE_OUTPUT=$(cd "$ROOT" && python3 .leopoldo/hooks/verify-license.py 2>/dev/null || python .leopoldo/hooks/verify-license.py 2>/dev/null || echo "LICENSE_CHECK_ERROR")
  LICENSE_STATUS=$(echo "$LICENSE_OUTPUT" | head -1)
  LICENSE_INFO=$(echo "$LICENSE_OUTPUT" | tail -1)
fi

# Handle license status — early exit for non-valid states
case "$LICENSE_STATUS" in
  "LICENSE_VALID"|"FREE")
    # Proceed normally
    ;;
  "ACTIVATION_REQUIRED")
    if _has_jq; then
      jq -n '{"additionalContext": "ACTIVATION_REQUIRED: This Leopoldo installation is not activated. All Leopoldo skills and agents are disabled. Run /leopoldo activate YOUR-ACTIVATION-KEY to activate. The activation key was sent in your welcome email."}'
    else
      echo '{"additionalContext": "ACTIVATION_REQUIRED: This Leopoldo installation is not activated. All Leopoldo skills and agents are disabled. Run /leopoldo activate YOUR-ACTIVATION-KEY to activate. The activation key was sent in your welcome email."}'
    fi
    exit 0
    ;;
  "ACTIVATION_INCOMPLETE")
    if _has_jq; then
      jq -n '{"additionalContext": "ACTIVATION_INCOMPLETE: A previous activation was interrupted before completing. Run /leopoldo activate YOUR-ACTIVATION-KEY again to retry. If the problem persists, delete .leopoldo/.activation-in-progress and try again."}'
    else
      echo '{"additionalContext": "ACTIVATION_INCOMPLETE: A previous activation was interrupted before completing. Run /leopoldo activate YOUR-ACTIVATION-KEY again to retry."}'
    fi
    exit 0
    ;;
  "LICENSE_INVALID")
    if _has_jq; then
      jq -n '{"additionalContext": "LICENSE_INVALID: Your license file is corrupted or tampered with. Run /leopoldo activate YOUR-KEY to re-activate, or contact hello@leopoldo.ai"}'
    else
      echo '{"additionalContext": "LICENSE_INVALID: Your license file is corrupted or tampered with. Run /leopoldo activate YOUR-KEY to re-activate, or contact hello@leopoldo.ai"}'
    fi
    exit 0
    ;;
  "LICENSE_WRONG_DEVICE")
    if _has_jq; then
      jq -n '{"additionalContext": "LICENSE_WRONG_DEVICE: This license belongs to another device. Run /leopoldo transfer on the original device first, or contact hello@leopoldo.ai"}'
    else
      echo '{"additionalContext": "LICENSE_WRONG_DEVICE: This license belongs to another device. Run /leopoldo transfer on the original device first, or contact hello@leopoldo.ai"}'
    fi
    exit 0
    ;;
  "LICENSE_EXPIRED")
    if _has_jq; then
      jq -n '{"additionalContext": "LICENSE_EXPIRED: Your Leopoldo license has expired. Contact hello@leopoldo.ai to renew."}'
    else
      echo '{"additionalContext": "LICENSE_EXPIRED: Your Leopoldo license has expired. Contact hello@leopoldo.ai to renew."}'
    fi
    exit 0
    ;;
  "LICENSE_OFFLINE_TOO_LONG")
    if _has_jq; then
      jq -n '{"additionalContext": "LICENSE_OFFLINE_TOO_LONG: Your Leopoldo license requires periodic connectivity. Please connect to the internet and restart your session. If this persists, contact hello@leopoldo.ai"}'
    else
      echo '{"additionalContext": "LICENSE_OFFLINE_TOO_LONG: Your Leopoldo license requires periodic connectivity. Please connect to the internet and restart your session."}'
    fi
    exit 0
    ;;
  *)
    # LICENSE_CHECK_ERROR or unknown — fail open (don't block Claude)
    ;;
esac

# ============================================================
# PLATFORM MISMATCH DETECTION (Fix #6)
# ============================================================

if [[ -f "$ROOT/.leopoldo/leopoldo-client.json" ]] && _has_jq; then
  EXPECTED_PLATFORM="$(jq -r '.platform // "claude-code"' "$ROOT/.leopoldo/leopoldo-client.json" 2>/dev/null || echo "claude-code")"

  # Detect current platform: Claude Code has .claude/ dir, Cowork has different structure
  CURRENT_PLATFORM="unknown"
  if [[ -d "$ROOT/.claude" ]]; then
    CURRENT_PLATFORM="claude-code"
  elif [[ -f "$ROOT/.cowork/config.json" ]] || [[ -f "$ROOT/hooks/hooks.json" ]]; then
    CURRENT_PLATFORM="cowork"
  fi

  if [[ "$CURRENT_PLATFORM" != "unknown" ]] && [[ "$EXPECTED_PLATFORM" != "$CURRENT_PLATFORM" ]] && [[ "$EXPECTED_PLATFORM" != "both" ]]; then
    CONTEXT="PLATFORM_MISMATCH: This package was built for $EXPECTED_PLATFORM but you are using $CURRENT_PLATFORM. Some features may not work correctly. Contact hello@leopoldo.ai for the correct package format."
  fi
fi

# ============================================================
# REST OF EXISTING SESSION-START LOGIC (unchanged)
# ============================================================

# Ensure .state directories exist
mkdir -p "$ROOT/.state/journal"
mkdir -p "$ROOT/.state/snapshots"
mkdir -p "$ROOT/.state/evolution"

# Generate session ID
SESSION_ID="ses_$(date +%Y%m%d_%H%M%S)"

# Create or reset gates.json
GATES_FILE="$ROOT/.state/gates.json"

if [[ -f "$GATES_FILE" ]] && _has_jq && jq empty "$GATES_FILE" 2>/dev/null; then
  # Preserve enforcement levels, reset counters, ensure postmortem field exists
  UPDATED="$(jq \
    --arg sid "$SESSION_ID" \
    '
    .session_id = $sid
    | .checkpoint_threshold = 5
    | .gates["doc-gate"].soft_warnings = 0
    | .postmortem = {"required": false, "detected_at": null, "completed": false, "user_signal": null}
    | .overrides = []
    | if .gates["workflow-loop"].status == "pending" then
        .
      else
        .gates["workflow-loop"] = {"status": "clear", "enforcement": "soft", "soft_warnings": 0, "source": null, "steps": [], "current_step": 0, "stall_count": 0, "max_stall": 3, "activated_at": null}
      end
    ' \
    "$GATES_FILE")"
  write_gate_state "$UPDATED"
else
  # Create fresh gates.json with postmortem tracking
  write_gate_state "$(cat <<EOF
{
  "version": "2.0.0",
  "session_id": "$SESSION_ID",
  "task_count_since_checkpoint": 0,
  "checkpoint_threshold": 5,
  "current_phase": null,
  "gates": {
    "checkpoint": {"status": "clear", "enforcement": "soft", "soft_warnings": 0},
    "doc-gate": {"status": "clear", "enforcement": "soft", "soft_warnings": 0},
    "phase-gate": {"status": "clear", "enforcement": "hard", "skills_required": [], "skills_invoked": []},
    "security-gate": {"status": "clear", "enforcement": "hard"},
    "workflow-loop": {"status": "clear", "enforcement": "soft", "soft_warnings": 0, "source": null, "steps": [], "current_step": 0, "stall_count": 0, "max_stall": 3, "activated_at": null}
  },
  "postmortem": {
    "required": false,
    "detected_at": null,
    "completed": false,
    "user_signal": null
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

# Check for active workflow-loop
if [[ -f "$GATES_FILE" ]] && _has_jq; then
  WL_STATUS="$(jq -r '.gates["workflow-loop"].status // "clear"' "$GATES_FILE" 2>/dev/null || echo "clear")"
  if [[ "$WL_STATUS" == "pending" ]]; then
    WL_TOTAL="$(jq '.gates["workflow-loop"].steps | length' "$GATES_FILE" 2>/dev/null || echo "0")"
    WL_DONE="$(jq '[.gates["workflow-loop"].steps[] | select(.status == "done" or .status == "skipped")] | length' "$GATES_FILE" 2>/dev/null || echo "0")"
    WL_NEXT="$(jq -r '.gates["workflow-loop"].steps[.gates["workflow-loop"].current_step].title // "unknown"' "$GATES_FILE" 2>/dev/null || echo "unknown")"
    CONTEXT="$CONTEXT WORKFLOW_ACTIVE: $WL_DONE/$WL_TOTAL steps completed. Next: $WL_NEXT. Resume with 'continue' or stop with 'stop workflow'."
  fi
fi



# --- Environment Quick Check (conditional) ---
# Only scan when cache is stale (>24h) or MCP config changed since last scan.
# Sets ENV_SCAN_NEEDED flag for orchestrator to dispatch environment-agent.

MANIFEST="$ROOT/.leopoldo-manifest.json"
MCP_LOCAL="$ROOT/.mcp.json"
MCP_HOME="$HOME/.claude/mcp.json"

needs_env_scan=false

if [ ! -f "$MANIFEST" ]; then
  needs_env_scan=true
else
  # Check cache age (>24h = stale)
  if _has_jq; then
    last_scan=$(jq -r '.environment.last_scan // empty' "$MANIFEST" 2>/dev/null)
    if [ -z "$last_scan" ]; then
      needs_env_scan=true
    else
      manifest_mtime=$(stat -f %m "$MANIFEST" 2>/dev/null || stat -c %Y "$MANIFEST" 2>/dev/null || echo 0)
      now=$(date +%s)
      age=$(( now - manifest_mtime ))
      if [ "$age" -gt 86400 ]; then
        needs_env_scan=true
      fi
    fi
  fi
  # Check MCP config changes (mtime newer than manifest)
  if [ -f "$MCP_LOCAL" ] && [ "$MCP_LOCAL" -nt "$MANIFEST" ]; then
    needs_env_scan=true
  fi
  if [ -f "$MCP_HOME" ] && [ "$MCP_HOME" -nt "$MANIFEST" ]; then
    needs_env_scan=true
  fi
fi

if $needs_env_scan; then
  CONTEXT="$CONTEXT ENV_SCAN_NEEDED: environment cache stale or missing. Dispatch environment-agent for quick MCP re-scan before handling user request."
fi

# ============================================================
# WEEKLY HEARTBEAT (curl-based, non-blocking, replaces heartbeat.py)
# ============================================================
if [[ "$LICENSE_STATUS" == "LICENSE_VALID" ]] && [[ -f "$ROOT/.leopoldo/leopoldo-client.json" ]] && _has_jq; then
  LAST_HB_FILE="$ROOT/.leopoldo/.last-heartbeat"
  SEND_HB="false"

  if [[ ! -f "$LAST_HB_FILE" ]]; then
    SEND_HB="true"
  else
    LAST_HB="$(cat "$LAST_HB_FILE" 2>/dev/null || echo "0")"
    NOW="$(date +%s)"
    DIFF=$(( NOW - LAST_HB ))
    if [[ "$DIFF" -ge 604800 ]]; then
      SEND_HB="true"
    fi
  fi

  if [[ "$SEND_HB" == "true" ]] && command -v curl &>/dev/null; then
    HB_API_KEY="$(jq -r '.api_key // ""' "$ROOT/.leopoldo/leopoldo-client.json" 2>/dev/null || echo "")"
    HB_API_URL="$(jq -r '.api_url // ""' "$ROOT/.leopoldo/leopoldo-client.json" 2>/dev/null | sed 's:/*$::' || echo "")"
    HB_VERSION="$(jq -r '.version // "1.0.0"' "$ROOT/.leopoldo/leopoldo-client.json" 2>/dev/null || echo "1.0.0")"

    if [[ -n "$HB_API_KEY" ]] && [[ -n "$HB_API_URL" ]]; then
      # Get device fingerprint (same logic as verify-license.py)
      HB_FINGERPRINT=""
      if [[ "$(uname)" == "Darwin" ]]; then
        HB_FINGERPRINT="$(ioreg -rd1 -c IOPlatformExpertDevice 2>/dev/null | grep IOPlatformUUID | sed 's/.*= "//;s/"//' || hostname)"
      else
        HB_FINGERPRINT="$(cat /etc/machine-id 2>/dev/null || cat /var/lib/dbus/machine-id 2>/dev/null || hostname)"
      fi

      # Extract current license info for renewal detection (mirrors old heartbeat.py)
      HB_CURRENT_EXPIRES=""
      HB_CURRENT_PRODUCTS=""
      LICENSE_DAT="$ROOT/.leopoldo/license.dat"
      if [[ -f "$LICENSE_DAT" ]]; then
        LICENSE_RAW="$(python3 -c "import base64,json,sys; d=json.loads(base64.b64decode(open('$LICENSE_DAT').read().strip())); p=d.get('payload',{}); print(p.get('expires_at','')); print(','.join(p.get('products',[])))" 2>/dev/null || echo "")"
        if [[ -n "$LICENSE_RAW" ]]; then
          HB_CURRENT_EXPIRES="$(echo "$LICENSE_RAW" | head -1)"
          HB_CURRENT_PRODUCTS="$(echo "$LICENSE_RAW" | tail -1)"
        fi
      fi

      # Send heartbeat in background (non-blocking)
      (
        HB_BODY="{\"device_fingerprint\":\"$HB_FINGERPRINT\",\"version\":\"$HB_VERSION\""
        if [[ -n "$HB_CURRENT_EXPIRES" ]]; then
          HB_BODY="$HB_BODY,\"current_expires\":\"$HB_CURRENT_EXPIRES\""
        fi
        if [[ -n "$HB_CURRENT_PRODUCTS" ]]; then
          HB_BODY="$HB_BODY,\"current_products\":\"$HB_CURRENT_PRODUCTS\""
        fi
        HB_BODY="$HB_BODY}"

        HB_RESPONSE="$(curl -s -m 10 \
          -X POST "$HB_API_URL/api/licenses/heartbeat" \
          -H "Content-Type: application/json" \
          -H "X-Api-Key: $HB_API_KEY" \
          -d "$HB_BODY" \
          2>/dev/null || echo "{}")"

        # Handle renewed license
        if echo "$HB_RESPONSE" | jq -e '.renewed_license' &>/dev/null; then
          RENEWED="$(echo "$HB_RESPONSE" | jq -r '.renewed_license')"
          echo "$RENEWED" > "$ROOT/.leopoldo/license.dat"
        fi

        # Handle revocation
        if echo "$HB_RESPONSE" | jq -r '.status' 2>/dev/null | grep -q 'revoked'; then
          rm -f "$ROOT/.leopoldo/license.dat"
        fi

        # Update last heartbeat timestamp
        date +%s > "$LAST_HB_FILE"
      ) &>/dev/null &
    fi
  fi
fi

# ============================================================
# PERSIST SESSION VARS via CLAUDE_ENV_FILE
# Other hooks read these as env vars instead of re-parsing gates.json.
# CLAUDE_ENV_FILE is only writable in SessionStart/CwdChanged/FileChanged.
# ============================================================
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
  LEOPOLDO_API_KEY=""
  LEOPOLDO_API_URL=""
  if [[ -f "$ROOT/.leopoldo/leopoldo-client.json" ]] && _has_jq; then
    LEOPOLDO_API_KEY="$(jq -r '.api_key // ""' "$ROOT/.leopoldo/leopoldo-client.json" 2>/dev/null || echo "")"
    LEOPOLDO_API_URL="$(jq -r '.api_url // ""' "$ROOT/.leopoldo/leopoldo-client.json" 2>/dev/null | sed 's:/*$::' || echo "")"
  fi

  cat >> "$CLAUDE_ENV_FILE" <<ENVEOF
LEOPOLDO_SESSION_ID=$SESSION_ID
LEOPOLDO_LICENSE_STATUS=$LICENSE_STATUS
LEOPOLDO_ROOT=$ROOT
LEOPOLDO_API_KEY=$LEOPOLDO_API_KEY
LEOPOLDO_API_URL=$LEOPOLDO_API_URL
ENVEOF
fi

# Output JSON for Claude Code — use jq to properly escape the context string
if _has_jq; then
  jq -n --arg ctx "$CONTEXT" '{"additionalContext": $ctx}'
else
  # Fallback: basic escaping
  ESCAPED_CONTEXT="$(echo "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g')"
  echo "{\"additionalContext\": \"$ESCAPED_CONTEXT\"}"
fi

exit 0
