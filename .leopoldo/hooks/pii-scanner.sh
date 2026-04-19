#!/usr/bin/env bash
# pii-scanner.sh — PostToolUse hook for Leopoldo.
# Scans Edit/Write/Agent output for PII and secrets.
# NOT applied to Bash (too many false positives from git log, env dumps, etc.).
#
# Exit 2 = block (secret detected). Exit 0 = clean.

set -euo pipefail
trap 'exit 0' ERR

# Read tool output from stdin
INPUT="$(cat)"

# Extract the tool output content to scan.
# PostToolUse receives the full tool result. We scan everything.
OUTPUT_TEXT=""
if command -v jq &>/dev/null; then
  OUTPUT_TEXT="$(echo "$INPUT" | jq -r '
    (.tool_result // .result // .output // "") |
    if type == "object" then tostring else . end
  ' 2>/dev/null || echo "$INPUT")"
else
  OUTPUT_TEXT="$INPUT"
fi

# If empty, nothing to scan
if [[ -z "$OUTPUT_TEXT" ]]; then
  exit 0
fi

# --- Pattern checks ---

# Private keys (RSA, EC, DSA, generic)
if echo "$OUTPUT_TEXT" | grep -qE '\-\-\-\-\-BEGIN (RSA |EC |DSA )?PRIVATE KEY\-\-\-\-\-' 2>/dev/null; then
  echo "⛔ PII-SCANNER: Private key detected in output. Do NOT commit or share this content. Redact before proceeding." >&2
  exit 2
fi

# AWS access keys
if echo "$OUTPUT_TEXT" | grep -qE 'AKIA[0-9A-Z]{16}' 2>/dev/null; then
  echo "⛔ PII-SCANNER: AWS access key detected in output. Redact before proceeding." >&2
  exit 2
fi

# Credit card numbers (4 groups of 4 digits, separated by spaces or dashes)
if echo "$OUTPUT_TEXT" | grep -qE '[0-9]{4}[[:space:]\-]?[0-9]{4}[[:space:]\-]?[0-9]{4}[[:space:]\-]?[0-9]{4}' 2>/dev/null; then
  echo "⛔ PII-SCANNER: Possible credit card number detected in output. Redact before proceeding." >&2
  exit 2
fi

# Passwords in config/code (password = "...", password: "...")
if echo "$OUTPUT_TEXT" | grep -qiE 'password[[:space:]]*[:=][[:space:]]*['"'"'"][^'"'"'"]+['"'"'"]' 2>/dev/null; then
  echo "⛔ PII-SCANNER: Password value detected in output. Redact before proceeding." >&2
  exit 2
fi

# API secrets (api_key, api_secret, secret_key, access_token with 32+ char values)
if echo "$OUTPUT_TEXT" | grep -qiE '(api_key|api_secret|secret_key|access_token)[[:space:]]*[:=][[:space:]]*['"'"'"][A-Za-z0-9_\-]{32,}['"'"'"]' 2>/dev/null; then
  echo "⛔ PII-SCANNER: API secret/token detected in output. Redact before proceeding." >&2
  exit 2
fi

exit 0
