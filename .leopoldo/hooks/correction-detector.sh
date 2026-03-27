#!/usr/bin/env bash
# correction-detector.sh — UserPromptSubmit hook for Leopoldo.
# Detects correction signals in user messages and suggests /postmortem.
# Never blocks (always exits 0).

set -euo pipefail
trap 'exit 0' ERR

# Read user prompt from stdin
INPUT="$(cat)"

# Extract prompt text
PROMPT=""
if command -v jq &>/dev/null; then
  PROMPT="$(echo "$INPUT" | jq -r '.prompt // .message // ""' 2>/dev/null || echo "$INPUT")"
else
  PROMPT="$INPUT"
fi

# Empty prompt — nothing to check
if [[ -z "$PROMPT" ]]; then
  exit 0
fi

# Correction signal patterns (case-insensitive, word boundaries)
# Italian signals
IT_PATTERN='\b(sbagliato|rifai|non funziona|non è corretto|non e'\'' corretto|correggi|è sbagliato|e'\'' sbagliato)\b'
# English signals
EN_PATTERN='\b(wrong|redo|that'\''s not right|thats not right|try again|not what I asked|incorrect)\b'

if echo "$PROMPT" | grep -iEq "$IT_PATTERN" 2>/dev/null || \
   echo "$PROMPT" | grep -iEq "$EN_PATTERN" 2>/dev/null; then
  cat <<'EOF'
{"additionalContext": "Note: this message may contain a correction of a previous output. If it refers to something Leopoldo just produced, consider running /postmortem before fixing. If Imprint is enabled, append an observation to .leopoldo/imprint/observations.jsonl after the postmortem."}
EOF
fi

exit 0
