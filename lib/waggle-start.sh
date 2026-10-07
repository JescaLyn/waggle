#!/bin/bash
# UserPromptSubmit/PostToolUse hook: starts the waggle animation as a background process
# and exits immediately so Claude can begin processing. No-op if already running.
# waggle-stop.sh kills the animation when Claude finishes or asks a question.

HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)"

_SESSION_ID=""
if command -v python3 >/dev/null 2>&1; then
  _SESSION_ID=$(python3 -c "
import sys, json, os
try:
    if not os.isatty(sys.stdin.fileno()):
        d = json.load(sys.stdin)
        print(d.get('session_id', ''))
except Exception:
    pass
" 2>/dev/null)
fi

TERM_DEV=""
PID=$$
for _ in 1 2 3 4 5; do
  _PPID=$(ps -p "$PID" -o ppid= 2>/dev/null | tr -d ' ')
  { [ -z "$_PPID" ] || [ "$_PPID" = "1" ] || [ "$_PPID" = "$PID" ]; } && break
  TTY=$(ps -p "$_PPID" -o tty= 2>/dev/null | tr -d ' ')
  if [ -n "$TTY" ] && [ "$TTY" != "??" ]; then TERM_DEV="/dev/$TTY"; break; fi
  PID="$_PPID"
done
{ [ -z "$TERM_DEV" ] || [ ! -w "$TERM_DEV" ]; } && exit 0

PID_FILE="/tmp/waggle-${_SESSION_ID:-$$}.pid"

# Skip if animation is already running
if [ -f "$PID_FILE" ]; then
  _EXISTING=$(cat "$PID_FILE" 2>/dev/null)
  if [ -n "$_EXISTING" ] && kill -0 "$_EXISTING" 2>/dev/null; then
    exit 0
  fi
fi

# Prefer waggle.sh (installed copy) but fall back to dispatcher.sh (running from source)
if [ -f "$HOOKS_DIR/waggle.sh" ]; then
  _DISPATCHER="$HOOKS_DIR/waggle.sh"
elif [ -f "$HOOKS_DIR/dispatcher.sh" ]; then
  _DISPATCHER="$HOOKS_DIR/dispatcher.sh"
else
  exit 0
fi

WAGGLE_TERM_DEV="$TERM_DEV" \
WAGGLE_SESSION_ID="$_SESSION_ID" \
WAGGLE_PID_FILE="$PID_FILE" \
  bash "$_DISPATCHER" &
_WAGGLE_PID=$!
echo "$_WAGGLE_PID" > "$PID_FILE"
disown "$_WAGGLE_PID"
exit 0
