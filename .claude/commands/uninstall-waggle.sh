#!/usr/bin/env bash
# description: Remove a dancer or the entire waggle hook. No dancer arg removes everything; scope defaults to global.
# usage: /uninstall-waggle [<dancer>|<path>] [<path>]
set -euo pipefail

DANCER=""
RAW_TARGET=""
if [[ "${1:-}" == */* || "${1:-}" == ~* ]]; then
  RAW_TARGET="$1"
elif [ -n "${1:-}" ]; then
  DANCER="$1"
  RAW_TARGET="${2:-}"
fi

case "$RAW_TARGET" in
  "")
    HOOKS_DIR="$HOME/.claude/hooks"
    SETTINGS_FILE="$HOME/.claude/settings.json"
    ;;
  *)
    ABS_TARGET="${RAW_TARGET/#\~/$HOME}"
    ABS_TARGET="$(cd "$ABS_TARGET" 2>/dev/null && pwd)" || { echo "ERROR: directory not found: $RAW_TARGET" >&2; exit 1; }
    HOOKS_DIR="$ABS_TARGET/.claude/hooks"
    SETTINGS_FILE="$ABS_TARGET/.claude/settings.json"
    ;;
esac

DISPATCHER="$HOOKS_DIR/waggle.sh"
DANCERS_INSTALL_DIR="$HOOKS_DIR/waggle-dancers"

remove_hook_entry() {
  grep -q "waggle\\.sh" "$SETTINGS_FILE" 2>/dev/null || { echo "not configured: $SETTINGS_FILE (skipped)"; return; }
  command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required — install with: brew install jq" >&2; exit 1; }
  TMP=$(mktemp)
  trap 'rm -f "$TMP"' EXIT
  jq '.hooks.UserPromptSubmit = [(.hooks.UserPromptSubmit // [])[] | select((.hooks // []) | map(.command // "") | map(test("waggle\\.sh")) | any | not)]' \
    "$SETTINGS_FILE" > "$TMP" && mv "$TMP" "$SETTINGS_FILE"
  echo "updated: $SETTINGS_FILE"
}

if [ -z "$DANCER" ]; then
  if [ -f "$DISPATCHER" ]; then
    rm "$DISPATCHER"; echo "removed: $DISPATCHER"
  else
    echo "not installed: $DISPATCHER (skipped)"
  fi
  if [ -d "$DANCERS_INSTALL_DIR" ]; then
    rm -rf "$DANCERS_INSTALL_DIR"; echo "removed: $DANCERS_INSTALL_DIR"
  fi
  remove_hook_entry
else
  DANCER_FILE="$DANCERS_INSTALL_DIR/$DANCER.sh"
  if [ ! -f "$DANCER_FILE" ]; then
    echo "not installed: $DANCER_FILE (skipped)"; exit 0
  fi
  rm "$DANCER_FILE"; echo "removed: $DANCER_FILE"
  remaining=("$DANCERS_INSTALL_DIR"/*.sh)
  if [ ! -f "${remaining[0]}" ]; then
    rm -f "$DISPATCHER"
    rm -rf "$DANCERS_INSTALL_DIR"
    echo "no dancers remain — removed dispatcher and pool"
    remove_hook_entry
  fi
fi
