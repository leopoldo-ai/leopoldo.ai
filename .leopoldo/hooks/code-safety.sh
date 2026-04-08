#!/usr/bin/env bash
# code-safety.sh — PreToolUse hook for Leopoldo (Layer 1 DEV profile).
# Regex scan for known-unsafe code patterns in Write/Edit operations.
# Exit 2 = block. Exit 0 = allow.

set -euo pipefail
trap 'exit 0' ERR

INPUT="$(cat)"

CONTENT=""
if command -v jq &>/dev/null; then
  CONTENT="$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""' 2>/dev/null || echo "")"
else
  CONTENT="$INPUT"
fi

if [[ -z "$CONTENT" || "$CONTENT" == "null" ]]; then
  exit 0
fi

FOUND=""

# Hardcoded credentials
if echo "$CONTENT" | grep -qE 'password\s*[:=]\s*['"'"'"][^'"'"'"]{3,}['"'"'"]' 2>/dev/null; then
  FOUND="${FOUND}Hardcoded password. "
fi
if echo "$CONTENT" | grep -qE 'api_key\s*=\s*['"'"'"]sk-' 2>/dev/null; then
  FOUND="${FOUND}Hardcoded API key. "
fi

# Dangerous eval/exec
if echo "$CONTENT" | grep -qE 'eval\(' 2>/dev/null; then
  FOUND="${FOUND}eval() usage. "
fi
if echo "$CONTENT" | grep -qE 'exec\(' 2>/dev/null; then
  if ! echo "$CONTENT" | grep -qE 'if __name__' 2>/dev/null; then
    FOUND="${FOUND}exec() usage. "
  fi
fi

# Dangerous shell commands
if echo "$CONTENT" | grep -qE 'chmod 777' 2>/dev/null; then
  FOUND="${FOUND}chmod 777. "
fi
if echo "$CONTENT" | grep -qE 'curl.*\|\s*bash' 2>/dev/null; then
  FOUND="${FOUND}curl | bash (pipe to shell). "
fi
if echo "$CONTENT" | grep -qE 'rm -rf /' 2>/dev/null; then
  FOUND="${FOUND}rm -rf /. "
fi

# Prompt injection markers
if echo "$CONTENT" | grep -qiE '<!-- Ignore previous' 2>/dev/null; then
  FOUND="${FOUND}Prompt injection marker. "
fi
if echo "$CONTENT" | grep -qE '\[SYSTEM\]' 2>/dev/null; then
  FOUND="${FOUND}Prompt injection [SYSTEM] tag. "
fi

if [[ -n "$FOUND" ]]; then
  echo "CODE SAFETY: Unsafe pattern detected: ${FOUND}Review and fix before writing." >&2
  exit 2
fi

exit 0
