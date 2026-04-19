#!/bin/bash
#
# Leopoldo Plugin Health Check
# Verifies plugin installation integrity after install.
# Works on macOS and Linux.

set -e

PASS="OK"
FAIL="[FAIL]"
STATUS_OK=true

# --- Detect project directory ---
if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "pyproject.toml" ] && [ ! -f "Cargo.toml" ]; then
    echo "Error: Not a project directory. Run this script from your project root."
    exit 1
fi

# --- Detect format ---
FORMAT=""
SKILLS_DIR=""
AGENTS_DIR=""

if [ -d ".claude/skills" ]; then
    FORMAT="Claude Code"
    SKILLS_DIR=".claude/skills"
    AGENTS_DIR=".claude/agents"
elif [ -f ".claude-plugin/plugin.json" ]; then
    FORMAT="Cowork"
    SKILLS_DIR="skills"
    AGENTS_DIR="agents"
else
    echo "Error: No Leopoldo plugin detected."
    echo "Expected .claude/skills/ (Claude Code) or .claude-plugin/plugin.json (Cowork)."
    exit 1
fi

# --- Count skills ---
SKILL_COUNT=0
if [ -d "$SKILLS_DIR" ]; then
    SKILL_COUNT=$(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
fi
SKILL_STATUS="$SKILL_COUNT found"
if [ "$SKILL_COUNT" -eq 0 ]; then
    SKILL_STATUS="$SKILL_COUNT found $FAIL"
    STATUS_OK=false
fi

# --- Count agents ---
AGENT_COUNT=0
if [ -d "$AGENTS_DIR" ]; then
    AGENT_COUNT=$(find "$AGENTS_DIR" -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
fi
AGENT_STATUS="$AGENT_COUNT found"
if [ "$AGENT_COUNT" -eq 0 ]; then
    AGENT_STATUS="$AGENT_COUNT found $FAIL"
    STATUS_OK=false
fi

# --- Check engine skills ---
ENGINE_STATUS="$FAIL"
if find "$SKILLS_DIR" -type d -name "update-checker" 2>/dev/null | grep -q . || \
   find "$SKILLS_DIR" -type d -name "leopoldo-setup" 2>/dev/null | grep -q .; then
    ENGINE_STATUS="$PASS"
else
    STATUS_OK=false
fi

# --- Check essentials skills ---
ESSENTIALS_STATUS="$FAIL"
if find "$SKILLS_DIR" -type d -name "brand-kit" 2>/dev/null | grep -q . || \
   find "$SKILLS_DIR" -type d -name "executive-briefing" 2>/dev/null | grep -q .; then
    ESSENTIALS_STATUS="$PASS"
else
    STATUS_OK=false
fi

# --- Check plugin.yaml ---
PLUGIN_NAME="Unknown"
PLUGIN_VERSION="Unknown"
if [ -f "plugin.yaml" ]; then
    PLUGIN_NAME=$(grep -m1 '^name:' plugin.yaml 2>/dev/null | sed 's/^name:[[:space:]]*//' || echo "Unknown")
    PLUGIN_VERSION=$(grep -m1 '^version:' plugin.yaml 2>/dev/null | sed 's/^version:[[:space:]]*//' || echo "Unknown")
elif [ -f "plugin.yml" ]; then
    PLUGIN_NAME=$(grep -m1 '^name:' plugin.yml 2>/dev/null | sed 's/^name:[[:space:]]*//' || echo "Unknown")
    PLUGIN_VERSION=$(grep -m1 '^version:' plugin.yml 2>/dev/null | sed 's/^version:[[:space:]]*//' || echo "Unknown")
fi
PLUGIN_LABEL="$PLUGIN_NAME v$PLUGIN_VERSION"

# --- Check hooks (Cowork only) ---
HOOKS_STATUS="N/A (Claude Code format)"
if [ "$FORMAT" = "Cowork" ]; then
    if [ -f "hooks.json" ] || [ -f ".claude-plugin/hooks.json" ]; then
        HOOKS_STATUS="$PASS"
    else
        HOOKS_STATUS="$FAIL"
        STATUS_OK=false
    fi
fi

# --- Print summary ---
echo ""
echo "Leopoldo Plugin Health Check"
echo "============================"
echo ""
printf "Format:     %s\n" "$FORMAT"
printf "Plugin:     %s\n" "$PLUGIN_LABEL"
printf "Skills:     %s\n" "$SKILL_STATUS"
printf "Agents:     %s\n" "$AGENT_STATUS"
printf "Engine:     %s\n" "$ENGINE_STATUS"
printf "Essentials: %s\n" "$ESSENTIALS_STATUS"
printf "Hooks:      %s\n" "$HOOKS_STATUS"
echo ""

if [ "$STATUS_OK" = true ]; then
    echo "Status: All checks passed. Plugin is ready to use."
else
    echo "Status: Issues detected. Reinstall the plugin or visit leopoldo.ai/support."
fi
echo ""
