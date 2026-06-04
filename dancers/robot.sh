#!/bin/bash
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

cleanup() { printf '\r\033[K' > "$TERM_DEV" 2>/dev/null; }
trap cleanup EXIT

frames=(' ┌[ □_□ ]┐' ' └[ □_□ ]┘' ' ┌[ □_□ ]┘' ' └[ □_□ ]┘' ' └[ □_□ ]┐' ' └[ □_□ ]┘')
for _ in 1 2; do
  for frame in "${frames[@]}"; do
    printf '\r%s\033[K' "$frame" > "$TERM_DEV"
    sleep 0.75
  done
done
