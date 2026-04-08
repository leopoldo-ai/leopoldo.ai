#!/usr/bin/env bash
# human-in-the-loop.sh — PreToolUse hook for Leopoldo.
# Blocks irreversible actions until the user explicitly confirms.
# Covers: deploy, email, destructive DB, git push, PR merge, license ops.
#
# Exit 2 = block (requires confirmation). Exit 0 = allow.

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

# --- Deploy: Vercel deploy ---
if [[ "$TOOL_NAME" == "mcp__claude_ai_Vercel__deploy_to_vercel" ]]; then
  echo "⛔ HUMAN-IN-THE-LOOP: Vercel deploy detected. This will push to production. Please confirm before proceeding." >&2
  exit 2
fi

# --- Email: Resend send operations ---
case "$TOOL_NAME" in
  mcp__resend__send-email|mcp__resend__send-batch-emails|mcp__resend__send-broadcast)
    echo "⛔ HUMAN-IN-THE-LOOP: Email send detected ($TOOL_NAME). Emails are irreversible. Please confirm before proceeding." >&2
    exit 2
    ;;
esac

# --- PR merge ---
if [[ "$TOOL_NAME" == "mcp__github__merge_pull_request" ]]; then
  echo "⛔ HUMAN-IN-THE-LOOP: PR merge detected. This is irreversible. Please confirm before proceeding." >&2
  exit 2
fi

# --- DB destructive: DELETE/DROP/TRUNCATE/UPDATE via postgres MCP ---
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
    echo "⛔ HUMAN-IN-THE-LOOP: Destructive DB operation detected (DELETE/DROP/TRUNCATE/UPDATE). Please confirm before proceeding." >&2
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

  # Git push (any form)
  if echo "$COMMAND" | grep -qE '^git push' 2>/dev/null; then
    echo "⛔ HUMAN-IN-THE-LOOP: git push detected. This will push to the remote repository. Please confirm before proceeding." >&2
    exit 2
  fi

  # License revoke or key rotation
  if echo "$COMMAND" | grep -qE '/api/licenses/revoke|/rotate-key' 2>/dev/null; then
    echo "⛔ HUMAN-IN-THE-LOOP: License operation detected (revoke/rotate-key). This is irreversible. Please confirm before proceeding." >&2
    exit 2
  fi
fi

exit 0
