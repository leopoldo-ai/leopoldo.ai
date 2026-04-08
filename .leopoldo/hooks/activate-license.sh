#!/usr/bin/env bash
# activate-license.sh — UserPromptSubmit hook for Leopoldo.
# Intercepts "/leopoldo activate XXXX-XXXX-XXXX-XXXX" in user prompt,
# calls the backend API to activate the license, and saves license.dat.
# Works on both Claude Code and Cowork.
# Always exits 0 (never blocks Claude).

set -euo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core.sh"

# Read user prompt from stdin
INPUT="$(cat)"

# Extract prompt text
PROMPT=""
if _has_jq; then
  PROMPT="$(echo "$INPUT" | jq -r '.prompt // .message // ""' 2>/dev/null || echo "$INPUT")"
else
  PROMPT="$INPUT"
fi

# Check if prompt matches activation pattern
# Accepts: /leopoldo activate XXXX-XXXX-XXXX-XXXX
# Also accepts without slash: leopoldo activate XXXX-XXXX-XXXX-XXXX
ACTIVATION_KEY=""
if echo "$PROMPT" | grep -qiE '/?leopoldo\s+activate\s+[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}'; then
  ACTIVATION_KEY="$(echo "$PROMPT" | grep -oiE '[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}' | head -1 | tr '[:lower:]' '[:upper:]')"
fi

# Not an activation request — exit silently
if [[ -z "$ACTIVATION_KEY" ]]; then
  exit 0
fi

ROOT="$(find_project_root)"
CLIENT_JSON="$ROOT/.leopoldo/leopoldo-client.json"

# Verify client config exists
if [[ ! -f "$CLIENT_JSON" ]]; then
  echo '{"additionalContext": "ACTIVATION_ERROR: No leopoldo-client.json found. Please reinstall the plugin from your download link."}'
  exit 0
fi

# Read API key and URL from client config
if ! _has_jq; then
  echo '{"additionalContext": "ACTIVATION_ERROR: jq is required for activation. Please install jq."}'
  exit 0
fi

API_KEY="$(jq -r '.api_key // ""' "$CLIENT_JSON" 2>/dev/null || echo "")"
API_URL="$(jq -r '.api_url // ""' "$CLIENT_JSON" 2>/dev/null | sed 's:/*$::' || echo "")"

if [[ -z "$API_KEY" ]] || [[ -z "$API_URL" ]]; then
  echo '{"additionalContext": "ACTIVATION_ERROR: Missing api_key or api_url in leopoldo-client.json. Please reinstall the plugin."}'
  exit 0
fi

# Compute device fingerprint (same logic as verify-license.py)
FINGERPRINT=""
if [[ "$(uname)" == "Darwin" ]]; then
  MACHINE_ID="$(ioreg -rd1 -c IOPlatformExpertDevice 2>/dev/null | grep IOPlatformUUID | sed 's/.*= "//;s/"//' || hostname)"
elif [[ "$(uname)" == "Linux" ]]; then
  MACHINE_ID="$(cat /etc/machine-id 2>/dev/null || cat /var/lib/dbus/machine-id 2>/dev/null || hostname)"
else
  # Windows (Git Bash / WSL)
  MACHINE_ID="$(reg query 'HKLM\SOFTWARE\Microsoft\Cryptography' /v MachineGuid 2>/dev/null | grep MachineGuid | awk '{print $NF}' || hostname)"
fi
USERNAME="${USER:-${USERNAME:-unknown}}"
FINGERPRINT="$(echo -n "${MACHINE_ID}${USERNAME}" | shasum -a 256 | cut -d' ' -f1)"

# Check if curl is available
if ! command -v curl &>/dev/null; then
  echo '{"additionalContext": "ACTIVATION_ERROR: curl is required for activation but not found."}'
  exit 0
fi

# Call activation API
ACTIVATE_BODY="{\"activation_key\":\"$ACTIVATION_KEY\",\"device_fingerprint\":\"$FINGERPRINT\",\"api_key\":\"$API_KEY\"}"

RESPONSE="$(curl -s -m 15 \
  -X POST "$API_URL/api/licenses/activate" \
  -H "Content-Type: application/json" \
  -d "$ACTIVATE_BODY" \
  2>/dev/null || echo '{"success":false,"error":"Network error: could not reach activation server"}')"

# Parse response
SUCCESS="$(echo "$RESPONSE" | jq -r '.success // false' 2>/dev/null || echo "false")"

if [[ "$SUCCESS" == "true" ]]; then
  # Save license.dat
  LICENSE_DATA="$(echo "$RESPONSE" | jq -r '.license_data // ""' 2>/dev/null || echo "")"
  CLIENT_NAME="$(echo "$RESPONSE" | jq -r '.name // ""' 2>/dev/null || echo "")"
  PRODUCTS="$(echo "$RESPONSE" | jq -r '.products // [] | join(", ")' 2>/dev/null || echo "")"

  if [[ -n "$LICENSE_DATA" ]]; then
    echo "$LICENSE_DATA" > "$ROOT/.leopoldo/license.dat"

    # Log activation
    TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    mkdir -p "$ROOT/.state/journal"
    echo "{\"event\":\"license.activated\",\"client_name\":\"$CLIENT_NAME\",\"products\":\"$PRODUCTS\",\"timestamp\":\"$TIMESTAMP\"}" >> "$ROOT/.state/journal/$(date +%Y-%m-%d).jsonl" 2>/dev/null || true

    echo "{\"additionalContext\": \"LICENSE_ACTIVATED: Welcome, $CLIENT_NAME. Leopoldo is now activated with domains: $PRODUCTS. All skills and agents are available. Enjoy.\"}"
  else
    echo '{"additionalContext": "ACTIVATION_ERROR: Activation succeeded but no license data received. Contact hello@leopoldo.ai"}'
  fi
else
  ERROR="$(echo "$RESPONSE" | jq -r '.error // "Unknown error"' 2>/dev/null || echo "Unknown error")"
  echo "{\"additionalContext\": \"ACTIVATION_FAILED: $ERROR. Check your activation key and try again. If the problem persists, contact hello@leopoldo.ai\"}"
fi

exit 0
