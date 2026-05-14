#!/usr/bin/env bash
# human-in-the-loop.sh — PreToolUse hook for Leopoldo.
# Blocks irreversible actions until the user explicitly confirms.
# Covers: deploy, email, destructive DB, git push, PR merge, license ops.
#
# Exit 2 = block (requires confirmation). Exit 0 = allow.
#
# Bypass (after explicit user confirmation in chat):
#   LEOPOLDO_HUMAN_CONFIRMED=1 <command>
# Allowed for: git push, PR merge, Vercel deploy, license ops.
# NEVER allowed for: destructive DB (DELETE/DROP/TRUNCATE/UPDATE).
# DB operations must be run from terminal directly.

set -euo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

# Read tool input from stdin
INPUT="$(cat)"

TOOL_NAME=""
TOOL_INPUT=""
if _has_jq; then
  TOOL_NAME="$(echo "$INPUT" | jq -r '.tool_name // .tool // ""' 2>/dev/null || echo "")"
  TOOL_INPUT="$(echo "$INPUT" | jq -r '.tool_input // {} | tostring' 2>/dev/null || echo "")"
else
  TOOL_NAME="$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"$//' || echo "")"
  TOOL_INPUT="$INPUT"
fi

# Bypass helper: log the bypass event to journal for audit trail
_log_bypass() {
  local action="$1"
  journal_append "{\"event\":\"hook.bypassed\",\"hook\":\"human-in-the-loop\",\"action\":\"$action\",\"method\":\"LEOPOLDO_HUMAN_CONFIRMED\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" 2>/dev/null || true
}

# --- Deploy: Vercel deploy (BYPASSABLE) ---
if [[ "$TOOL_NAME" == "mcp__claude_ai_Vercel__deploy_to_vercel" ]]; then
  if [[ "${LEOPOLDO_HUMAN_CONFIRMED:-}" == "1" ]]; then
    _log_bypass "vercel-deploy"
    exit 0
  fi
  echo "⛔ HUMAN-IN-THE-LOOP: Vercel deploy detected. This will push to production. Please confirm before proceeding." >&2
  echo "   After your explicit confirmation in chat, retry with LEOPOLDO_HUMAN_CONFIRMED=1." >&2
  exit 2
fi

# --- Email: Resend send operations ---
case "$TOOL_NAME" in
  mcp__resend__send-email|mcp__resend__send-batch-emails|mcp__resend__send-broadcast)
    echo "⚠️  Email send detected ($TOOL_NAME). Confirm in the tool permission prompt to proceed." >&2
    exit 0
    ;;
esac

# --- Microsoft 365: send / delete / share / admin write operations ---
# Block any ms365 tool that sends mail, deletes data, shares files, or modifies
# directory state. Read operations (list, get, search) pass through.
if [[ "$TOOL_NAME" == mcp__ms365__* ]]; then
  case "$TOOL_NAME" in
    # Mail send / reply / forward
    *send-mail*|*send-message*|*reply*|*forward*|*send-draft*)
      if [[ "${LEOPOLDO_HUMAN_CONFIRMED:-}" == "1" ]]; then
        _log_bypass "ms365-send"
        exit 0
      fi
      echo "⛔ HUMAN-IN-THE-LOOP: Microsoft 365 send operation detected ($TOOL_NAME)." >&2
      echo "   Confirm explicitly in chat, then retry with LEOPOLDO_HUMAN_CONFIRMED=1." >&2
      exit 2
      ;;
    # Destructive deletes
    *delete-*|*remove-*)
      if [[ "${LEOPOLDO_HUMAN_CONFIRMED:-}" == "1" ]]; then
        _log_bypass "ms365-delete"
        exit 0
      fi
      echo "⛔ HUMAN-IN-THE-LOOP: Microsoft 365 destructive operation ($TOOL_NAME)." >&2
      echo "   Confirm explicitly in chat, then retry with LEOPOLDO_HUMAN_CONFIRMED=1." >&2
      exit 2
      ;;
    # File sharing / move
    *share-*|*move-*|*invite-*)
      if [[ "${LEOPOLDO_HUMAN_CONFIRMED:-}" == "1" ]]; then
        _log_bypass "ms365-share"
        exit 0
      fi
      echo "⛔ HUMAN-IN-THE-LOOP: Microsoft 365 share/move operation ($TOOL_NAME)." >&2
      echo "   Confirm explicitly in chat, then retry with LEOPOLDO_HUMAN_CONFIRMED=1." >&2
      exit 2
      ;;
    # User / license / role management
    *create-user*|*update-user*|*assign-license*|*revoke-license*|*reset-password*|*assign-role*|*remove-role*|*disable-user*|*enable-user*)
      if [[ "${LEOPOLDO_HUMAN_CONFIRMED:-}" == "1" ]]; then
        _log_bypass "ms365-admin"
        exit 0
      fi
      echo "⛔ HUMAN-IN-THE-LOOP: Microsoft 365 admin operation ($TOOL_NAME) on user/license/role." >&2
      echo "   Confirm explicitly in chat, then retry with LEOPOLDO_HUMAN_CONFIRMED=1." >&2
      exit 2
      ;;
    # Bookings: create / update appointments are reversible but still confirm sends
    *cancel-appointment*|*delete-appointment*)
      if [[ "${LEOPOLDO_HUMAN_CONFIRMED:-}" == "1" ]]; then
        _log_bypass "ms365-booking-cancel"
        exit 0
      fi
      echo "⛔ HUMAN-IN-THE-LOOP: Bookings cancellation/deletion ($TOOL_NAME)." >&2
      echo "   Confirm explicitly in chat, then retry with LEOPOLDO_HUMAN_CONFIRMED=1." >&2
      exit 2
      ;;
  esac
fi

# --- PR merge (BYPASSABLE) ---
if [[ "$TOOL_NAME" == "mcp__github__merge_pull_request" ]]; then
  if [[ "${LEOPOLDO_HUMAN_CONFIRMED:-}" == "1" ]]; then
    _log_bypass "pr-merge"
    exit 0
  fi
  echo "⛔ HUMAN-IN-THE-LOOP: PR merge detected. This is irreversible. Please confirm before proceeding." >&2
  echo "   After your explicit confirmation in chat, retry with LEOPOLDO_HUMAN_CONFIRMED=1." >&2
  exit 2
fi

# --- DB destructive: HARD BLOCK, no bypass, terminal only ---
if [[ "$TOOL_NAME" == "mcp__postgres__query" ]]; then
  # Extract the SQL query from input
  SQL_QUERY=""
  if _has_jq; then
    SQL_QUERY="$(echo "$INPUT" | jq -r '.tool_input.query // .tool_input.sql // ""' 2>/dev/null || echo "")"
  else
    SQL_QUERY="$(echo "$TOOL_INPUT" | grep -oiE '(DELETE|DROP|TRUNCATE|UPDATE)[[:space:]]' 2>/dev/null | head -1 || echo "")"
  fi

  # Case-insensitive check for destructive SQL
  if echo "$SQL_QUERY" | grep -qiE '\b(DELETE|DROP|TRUNCATE|UPDATE)\b' 2>/dev/null; then
    echo "⛔ HUMAN-IN-THE-LOOP: Destructive DB operation detected (DELETE/DROP/TRUNCATE/UPDATE)." >&2
    echo "   NO BYPASS AVAILABLE for DB destructive ops. Run directly from terminal after manual verification." >&2
    exit 2
  fi
fi

# --- Bash: git push, license ops ---
if [[ "$TOOL_NAME" == "Bash" ]]; then
  COMMAND=""
  if _has_jq; then
    COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")"
  else
    COMMAND="$(echo "$TOOL_INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"//;s/"$//' || echo "")"
  fi

  # Git push (any form) — BYPASSABLE
  if echo "$COMMAND" | grep -qE '^git push|LEOPOLDO_HUMAN_CONFIRMED=1 git push' 2>/dev/null; then
    if [[ "${LEOPOLDO_HUMAN_CONFIRMED:-}" == "1" ]] || echo "$COMMAND" | grep -qE 'LEOPOLDO_HUMAN_CONFIRMED=1' 2>/dev/null; then
      _log_bypass "git-push"
      exit 0
    fi
    echo "⛔ HUMAN-IN-THE-LOOP: git push detected. This will push to the remote repository. Please confirm before proceeding." >&2
    echo "   After your explicit confirmation in chat, retry with LEOPOLDO_HUMAN_CONFIRMED=1 git push ..." >&2
    exit 2
  fi

  # License revoke or key rotation — BYPASSABLE
  if echo "$COMMAND" | grep -qE '/api/licenses/revoke|/rotate-key' 2>/dev/null; then
    if [[ "${LEOPOLDO_HUMAN_CONFIRMED:-}" == "1" ]] || echo "$COMMAND" | grep -qE 'LEOPOLDO_HUMAN_CONFIRMED=1' 2>/dev/null; then
      _log_bypass "license-op"
      exit 0
    fi
    echo "⛔ HUMAN-IN-THE-LOOP: License operation detected (revoke/rotate-key). This is irreversible. Please confirm before proceeding." >&2
    echo "   After your explicit confirmation in chat, retry with LEOPOLDO_HUMAN_CONFIRMED=1 ..." >&2
    exit 2
  fi
fi

exit 0
