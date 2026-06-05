#!/usr/bin/env bash
# description: Install a dancer hook. Dancer defaults to waggle; scope defaults to global.
# usage: /install-waggle [<dancer>|<path>] [<path>]
set -euo pipefail

PROJ="${CLAUDE_PROJECT_DIR:-.}"
DANCERS_DIR="$PROJ/dancers"
DISPATCHER="$PROJ/lib/dispatcher.sh"

DANCER="waggle"
RAW_TARGET=""
if [[ "${1:-}" == */* || "${1:-}" == ~* ]]; then
  RAW_TARGET="$1"
elif [ -n "${1:-}" ]; then
  DANCER="$1"
  RAW_TARGET="${2:-}"
fi

[ -f "$DANCERS_DIR/$DANCER.sh" ] || { echo "ERROR: dancer '$DANCER' not found" >&2; exit 1; }

case "$RAW_TARGET" in
  "")
    HOOKS_DIR="$HOME/.claude/hooks"
    SETTINGS_FILE="$HOME/.claude/settings.json"
    HOOK_CMD="bash ~/.claude/hooks/waggle.sh"
    ;;
  *)
    ABS_TARGET="${RAW_TARGET/#\~/$HOME}"
    ABS_TARGET="$(cd "$ABS_TARGET" 2>/dev/null && pwd)" || { echo "ERROR: directory not found: $RAW_TARGET" >&2; exit 1; }
    HOOKS_DIR="$ABS_TARGET/.claude/hooks"
    SETTINGS_FILE="$ABS_TARGET/.claude/settings.json"
    HOOK_CMD="bash .claude/hooks/waggle.sh"
    ;;
esac

mkdir -p "$HOOKS_DIR"
cp "$DISPATCHER" "$HOOKS_DIR/waggle.sh"
chmod +x "$HOOKS_DIR/waggle.sh"
echo "installed: $HOOKS_DIR/waggle.sh"

DANCERS_INSTALL_DIR="$HOOKS_DIR/waggle-dancers"
mkdir -p "$DANCERS_INSTALL_DIR"
cp "$DANCERS_DIR/$DANCER.sh" "$DANCERS_INSTALL_DIR/$DANCER.sh"
echo "installed: $DANCERS_INSTALL_DIR/$DANCER.sh"

if grep -q "waggle\\.sh" "$SETTINGS_FILE" 2>/dev/null; then
  echo "already configured: $SETTINGS_FILE (skipped)"
  exit 0
fi

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required — install with: brew install jq" >&2; exit 1; }

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
