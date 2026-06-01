#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
WAGGLE_SRC="$SCRIPT_DIR/../../../../waggle.sh"

if [ ! -f "$WAGGLE_SRC" ]; then
  echo "ERROR: waggle.sh not found at $WAGGLE_SRC" >&2
  exit 1
fi

case "$1" in
  "")
    HOOKS_DIR="$HOME/.claude/hooks"
    SETTINGS_FILE="$HOME/.claude/settings.json"
    HOOK_CMD="bash $HOME/.claude/hooks/waggle.sh"
    ;;
  *)
    TARGET="${1/#\~/$HOME}"
    TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "ERROR: directory not found: $1" >&2; exit 1; }
    HOOKS_DIR="$TARGET/.claude/hooks"
    SETTINGS_FILE="$TARGET/.claude/settings.json"
    HOOK_CMD="bash .claude/hooks/waggle.sh"
    ;;
esac

mkdir -p "$HOOKS_DIR"
cp "$WAGGLE_SRC" "$HOOKS_DIR/waggle.sh"
chmod +x "$HOOKS_DIR/waggle.sh"
echo "installed: $HOOKS_DIR/waggle.sh"

if grep -q "waggle.sh" "$SETTINGS_FILE" 2>/dev/null; then
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
