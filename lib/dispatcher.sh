#!/bin/bash
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

_MONITOR_PID=""
cleanup() {
  [ -n "$_MONITOR_PID" ] && kill "$_MONITOR_PID" 2>/dev/null
  printf '\r\033[K' > "$TERM_DEV" 2>/dev/null
}
trap cleanup EXIT TERM

DANCERS_DIR="${WAGGLE_DANCERS_DIR:-$(cd "$(dirname "$0")" && pwd)/waggle-dancers}"
[ -d "$DANCERS_DIR" ] || exit 0

files=("$DANCERS_DIR"/*.sh)
[ -f "${files[0]}" ] || exit 0

if [ -n "${WAGGLE_DANCER:-}" ]; then
  dancer_file="$DANCERS_DIR/$WAGGLE_DANCER.sh"
  [ -f "$dancer_file" ] || exit 0
else
  count=${#files[@]}
  if [ -n "$_SESSION_ID" ]; then
    _state_file="/tmp/waggle-first-${_SESSION_ID}"
    if [ ! -f "$_state_file" ]; then
      touch "$_state_file"
      dancer_file="$DANCERS_DIR/waggle.sh"
      [ -f "$dancer_file" ] || dancer_file="${files[$((RANDOM % count))]}"
    else
      dancer_file="${files[$((RANDOM % count))]}"
    fi
  else
    dancer_file="${files[$((RANDOM % count))]}"
  fi
fi

source "$dancer_file"
sleep_dur="${sleep_dur:-0.75}"
[ "${#frames[@]}" -eq 0 ] && exit 0

if command -v python3 >/dev/null 2>&1; then
  python3 -c '
import os, select, signal, sys
signal.signal(signal.SIGTTIN, signal.SIG_IGN)
term_dev, disp_pid = sys.argv[1], int(sys.argv[2])
try:
    fd = os.open(term_dev, os.O_RDONLY | os.O_NONBLOCK)
    try:
        while not select.select([fd], [], [], 0.05)[0]:
            pass
        os.kill(disp_pid, signal.SIGTERM)
    finally:
        os.close(fd)
except Exception:
    pass
' "$TERM_DEV" "$$" &
  _MONITOR_PID=$!
fi

cycles=0
max_cycles="${WAGGLE_MAX_CYCLES:-}"
while true; do
  for frame in "${frames[@]}"; do
    printf '\033[?2026h\0337\r       %s\033[K\0338\033[?2026l' "$frame" > "$TERM_DEV"
    sleep "$sleep_dur"
  done
  cycles=$((cycles + 1))
  [ -n "$max_cycles" ] && [ "$cycles" -ge "$max_cycles" ] && break
done
