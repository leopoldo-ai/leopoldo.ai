#!/usr/bin/env bash
# rate-limiter.sh — PostToolUse hook for Leopoldo.
# Enforces per-minute rate limits on tool calls to prevent runaway loops.
# Counter files: /tmp/leopoldo-rate-{tool}-{minute}.count
#
# Limits: Edit 30, Write 20, Bash 40, Agent 10, default 50 per minute.
# Exit 2 = rate exceeded. Exit 0 = within limits.

set -euo pipefail
trap 'exit 0' ERR

# Read tool input from stdin
INPUT="$(cat)"

TOOL_NAME=""
if command -v jq &>/dev/null; then
  TOOL_NAME="$(echo "$INPUT" | jq -r '.tool_name // .tool // ""' 2>/dev/null || echo "")"
else
  TOOL_NAME="$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"$//' || echo "")"
fi

if [[ -z "$TOOL_NAME" ]]; then
  exit 0
fi

# --- Rate limits per tool ---
case "$TOOL_NAME" in
  Edit)   LIMIT=30 ;;
  Write)  LIMIT=20 ;;
  Bash)   LIMIT=40 ;;
  Agent)  LIMIT=10 ;;
  *)      LIMIT=50 ;;
esac

# --- Current minute bucket ---
MINUTE="$(date +%Y%m%d%H%M)"
COUNTER_FILE="/tmp/leopoldo-rate-${TOOL_NAME}-${MINUTE}.count"

# --- Auto-cleanup: remove counter files older than 2 minutes ---
find /tmp -maxdepth 1 -name "leopoldo-rate-*.count" -mmin +2 -delete 2>/dev/null || true

# --- Read current count ---
CURRENT=0
if [[ -f "$COUNTER_FILE" ]]; then
  CURRENT="$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")"
  # Validate numeric
  if ! [[ "$CURRENT" =~ ^[0-9]+$ ]]; then
    CURRENT=0
  fi
fi

# --- Check limit ---
if [[ "$CURRENT" -ge "$LIMIT" ]]; then
  echo "⛔ RATE-LIMITER: $TOOL_NAME exceeded $LIMIT calls/minute (current: $CURRENT). Slow down to avoid runaway loops." >&2
  exit 2
fi

# --- Increment counter ---
echo $((CURRENT + 1)) > "$COUNTER_FILE"

exit 0
