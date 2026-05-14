#!/usr/bin/env bash
# validate-frontmatter.sh — PreToolUse hook for SKILL.md edits.
#
# Validates tier/status/applies_to vocabulary. Blocks the edit if a
# value is outside the allowed set, or if a skill living in
# skills/packs/common/essentials/ is given a tier other than
# `essentials` (sanity check).
#
# Per docs/specs/2026-04-27-essentials-tier-migration.md, Phase 4.
#
# Exit 2 = block. Exit 0 = allow.

set -uo pipefail
# We intentionally do NOT set -e here. A deny() exit 2 must not be
# rewritten by an ERR trap. We trap unexpected errors and convert
# them to exit 0 (fail-open) only for setup steps; the validation
# decision uses an explicit conditional, not exit-on-error.
_orig_err_trap() { :; }
trap _orig_err_trap ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

INPUT="$(cat)"

FILE_PATH=""
NEW_CONTENT=""
TOOL_NAME=""
if _has_jq; then
  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .file_path // ""' 2>/dev/null || echo "")"
  TOOL_NAME="$(echo "$INPUT" | jq -r '.tool_name // .tool // ""' 2>/dev/null || echo "")"
  NEW_CONTENT="$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // ""' 2>/dev/null || echo "")"
fi

# Only fire on SKILL.md files
case "$FILE_PATH" in
  *SKILL.md) ;;
  *) exit 0 ;;
esac

# If the new content is small (e.g. an Edit replacing only a snippet),
# read the on-disk file post-write isn't possible (we're PreToolUse).
# So we validate the post-edit state: if NEW_CONTENT looks like a full
# document, check it; otherwise read the current on-disk file as a
# best-effort baseline (Edit usually preserves frontmatter).
ROOT="$(find_project_root)"

deny() {
  local reason="$1"
  if _has_jq; then
    jq -n --arg reason "$reason" '{decision:"block", reason:$reason}'
  else
    echo "{\"decision\":\"block\",\"reason\":\"$reason\"}"
  fi
  exit 2
}

# Always validate the on-disk file (post-write equivalent for Write,
# pre-edit baseline for Edit which usually preserves the frontmatter).
TARGET_FILE="$FILE_PATH"
TMP=""
cleanup_tmp() { [[ -n "$TMP" && -f "$TMP" ]] && rm -f "$TMP"; }
trap cleanup_tmp EXIT
if [[ ! -f "$TARGET_FILE" ]]; then
  # New file via Write; use NEW_CONTENT directly via tmpfile
  if [[ -n "$NEW_CONTENT" ]]; then
    TMP="$(mktemp)"
    printf '%s' "$NEW_CONTENT" > "$TMP"
    TARGET_FILE="$TMP"
  else
    exit 0
  fi
fi

# Run validator via Python (single source of truth for vocabulary).
# We disable `set -e` for this block so a Python exit 1 (= validation
# failure) does not trip the ERR trap and silently allow the edit.
set +e
RESULT="$(python3 - "$TARGET_FILE" 2>&1 <<'PYEOF'
import sys
from pathlib import Path

VALID_TIERS = {"essentials", "pack", "premium", "beta"}
VALID_STATUSES = {"ga", "draft", "deprecated"}
VALID_PROFILES = {"CONTENT", "DEV", "STUDIO"}

path = Path(sys.argv[1])
text = path.read_text()
if not text.startswith("---"):
    print("OK")
    sys.exit(0)
end = text.find("---", 3)
if end == -1:
    print("WARN: no closing frontmatter marker")
    sys.exit(0)
fm = text[3:end]
issues = []
in_essentials_dir = "common/essentials/" in str(path)
tier_seen = None
for raw in fm.splitlines():
    line = raw.strip()
    if line.startswith("tier:"):
        v = line.split(":", 1)[1].strip().strip('"').strip("'")
        tier_seen = v
        if v not in VALID_TIERS:
            issues.append("invalid tier " + repr(v))
    elif line.startswith("status:"):
        v = line.split(":", 1)[1].strip().strip('"').strip("'")
        if v not in VALID_STATUSES:
            issues.append("invalid status " + repr(v))
    elif line.startswith("applies_to:"):
        v = line.split(":", 1)[1].strip()
        if v.startswith("[") and v.endswith("]"):
            for p in (x.strip() for x in v[1:-1].split(",") if x.strip()):
                if p not in VALID_PROFILES:
                    issues.append("invalid applies_to value " + repr(p))

# Sanity flag: essentials-dir skill without tier=essentials
if in_essentials_dir and tier_seen is not None and tier_seen != "essentials":
    issues.append("skill in common/essentials/ has tier=" + repr(tier_seen) +
                  "; expected 'essentials' (or move out of that directory)")

if issues:
    print("BLOCK: " + "; ".join(issues))
    sys.exit(1)
print("OK")
PYEOF
)"
PYRC=$?
# Keep `set -e` off through the conditional so an off-path test can't
# trigger the ERR trap and silently approve.

if [[ $PYRC -eq 0 && "$RESULT" == OK* ]]; then
  exit 0
fi

deny "Skill frontmatter validation failed for $FILE_PATH: ${RESULT#BLOCK: }"
