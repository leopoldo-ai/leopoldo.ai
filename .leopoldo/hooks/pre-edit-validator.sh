#!/usr/bin/env bash
# pre-edit-validator.sh — PreToolUse hook for Leopoldo.
# Blocks writes to protected directories (.state/, managed .leopoldo/ files).
# Provides helpful denial messages and auto-corrects paths where possible.
#
# Exit 2 = block the edit. Exit 0 = allow (optionally with updatedInput).
# JSON output on stdout enables updatedInput and structured denial reasons.

set -euo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

# Read tool input from stdin
INPUT="$(cat)"

FILE_PATH=""
TOOL_NAME=""
if _has_jq; then
  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .file_path // ""' 2>/dev/null || echo "")"
  TOOL_NAME="$(echo "$INPUT" | jq -r '.tool_name // .tool // ""' 2>/dev/null || echo "")"
else
  FILE_PATH="$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//' || echo "")"
fi

# No file path — allow (might be a non-file operation)
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

ROOT="$(find_project_root)"

# --- Helper: deny with structured reason ---
deny_with_reason() {
  local reason="$1"
  if _has_jq; then
    jq -n \
      --arg reason "$reason" \
      '{
        "hookSpecificOutput": {
          "hookEventName": "PreToolUse",
          "permissionDecision": "deny",
          "permissionDecisionReason": $reason
        }
      }'
  else
    echo "$reason" >&2
  fi
  exit 2
}

# --- Block writes to .state/ directory ---
if echo "$FILE_PATH" | grep -q '\.state/' 2>/dev/null; then
  deny_with_reason "Protected: .state/ is managed by Leopoldo hooks. Use Bash with jq to update state files. Example: jq '.field = \"value\"' .state/gates.json > .state/gates.json.tmp && mv .state/gates.json.tmp .state/gates.json"
fi

# --- Block writes to .leopoldo/ (with exceptions) ---
if echo "$FILE_PATH" | grep -q '\.leopoldo/' 2>/dev/null; then
  # Allow: hooks/ (development)
  if echo "$FILE_PATH" | grep -qE '\.leopoldo/hooks/' 2>/dev/null; then
    exit 0
  fi

  # Allow: playbooks/ (WS-C.2 client-owned YAML templates, project-scoped)
  if echo "$FILE_PATH" | grep -qE '\.leopoldo/playbooks/' 2>/dev/null; then
    exit 0
  fi

  # Allow: studio/ (WS-E delivery meta-tool state, drafts and backups)
  if echo "$FILE_PATH" | grep -qE '\.leopoldo/studio/' 2>/dev/null; then
    exit 0
  fi

  # Block: manifest
  if echo "$FILE_PATH" | grep -q '\.leopoldo-manifest\.json' 2>/dev/null || echo "$FILE_PATH" | grep -q '\.leopoldo/manifest' 2>/dev/null; then
    deny_with_reason "Protected: manifest is managed by leopoldo-manager. Use /leopoldo commands to modify the manifest."
  fi

  # Block: leopoldo-client.json
  if echo "$FILE_PATH" | grep -q 'leopoldo-client\.json' 2>/dev/null; then
    deny_with_reason "Protected: leopoldo-client.json contains license credentials. Use /leopoldo commands to manage."
  fi

  # Block: license.dat
  if echo "$FILE_PATH" | grep -q 'license\.dat' 2>/dev/null; then
    deny_with_reason "Protected: license.dat is managed by the activation system. Use /leopoldo activate to re-activate."
  fi

  # Block: everything else in .leopoldo/
  deny_with_reason "Protected: files in .leopoldo/ are managed by leopoldo-manager. Use /leopoldo commands to modify."
fi

# --- Block writes to .leopoldo-manifest.json at root ---
if echo "$FILE_PATH" | grep -q '\.leopoldo-manifest\.json' 2>/dev/null; then
  deny_with_reason "Protected: .leopoldo-manifest.json is managed by leopoldo-manager. Use /leopoldo install, /leopoldo add, or /leopoldo remove."
fi

exit 0
