#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DANCERS_DIR="$SCRIPT_DIR/../../../../dancers"

DANCER="${1:-waggle}"
DANCER_SRC="$DANCERS_DIR/$DANCER.sh"

if [ ! -f "$DANCER_SRC" ]; then
  echo "ERROR: dancer '$DANCER' not found" >&2
  exit 1
fi

case "${2:-}" in
  "")
    HOOKS_DIR="$HOME/.claude/hooks"
    SETTINGS_FILE="$HOME/.claude/settings.json"
    HOOK_CMD="bash $HOME/.claude/hooks/$DANCER.sh"
    ;;
  *)
    TARGET="${2/#\~/$HOME}"
    TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "ERROR: directory not found: $2" >&2; exit 1; }
    HOOKS_DIR="$TARGET/.claude/hooks"
    SETTINGS_FILE="$TARGET/.claude/settings.json"
    HOOK_CMD="bash .claude/hooks/$DANCER.sh"
    ;;
esac

mkdir -p "$HOOKS_DIR"
cp "$DANCER_SRC" "$HOOKS_DIR/$DANCER.sh"
chmod +x "$HOOKS_DIR/$DANCER.sh"
echo "installed: $HOOKS_DIR/$DANCER.sh"

if grep -q "$DANCER\\.sh" "$SETTINGS_FILE" 2>/dev/null; then
  echo "already configured: $SETTINGS_FILE (skipped)"
  exit 0
fi

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required to update settings.json — install it with: brew install jq" >&2; exit 1; }

ENTRY=$(jq -n --arg cmd "$HOOK_CMD" '{hooks: [{type: "command", command: $cmd, timeout: 10}]}')

if [ ! -f "$SETTINGS_FILE" ]; then
  jq -n --argjson e "$ENTRY" '{"hooks": {"UserPromptSubmit": [$e]}}' > "$SETTINGS_FILE"
  echo "created: $SETTINGS_FILE"
else
  TMP=$(mktemp)
  trap 'rm -f "$TMP"' EXIT
  jq --argjson e "$ENTRY" '.hooks.UserPromptSubmit = ((.hooks.UserPromptSubmit // []) + [$e])' \
    "$SETTINGS_FILE" > "$TMP" && mv "$TMP" "$SETTINGS_FILE"
  echo "updated: $SETTINGS_FILE"
fi
