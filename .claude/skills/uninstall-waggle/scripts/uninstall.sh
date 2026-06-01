#!/bin/bash
set -euo pipefail

DANCER="${1:-waggle}"

case "${2:-}" in
  "")
    HOOKS_DIR="$HOME/.claude/hooks"
    SETTINGS_FILE="$HOME/.claude/settings.json"
    ;;
  *)
    TARGET="${2/#\~/$HOME}"
    TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "ERROR: directory not found: $2" >&2; exit 1; }
    HOOKS_DIR="$TARGET/.claude/hooks"
    SETTINGS_FILE="$TARGET/.claude/settings.json"
    ;;
esac

HOOK_FILE="$HOOKS_DIR/$DANCER.sh"
if [ -f "$HOOK_FILE" ]; then
  rm "$HOOK_FILE"
  echo "removed: $HOOK_FILE"
else
  echo "not installed: $HOOK_FILE (skipped)"
fi

if ! grep -q "$DANCER\\.sh" "$SETTINGS_FILE" 2>/dev/null; then
  echo "not configured: $SETTINGS_FILE (skipped)"
  exit 0
fi

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required to update settings.json — install it with: brew install jq" >&2; exit 1; }

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
jq --arg dancer "$DANCER" \
  '.hooks.UserPromptSubmit = [(.hooks.UserPromptSubmit // [])[] | select((.hooks // []) | map(.command // "") | map(test($dancer + "\\.sh")) | any | not)]' \
  "$SETTINGS_FILE" > "$TMP" && mv "$TMP" "$SETTINGS_FILE"
echo "updated: $SETTINGS_FILE"
