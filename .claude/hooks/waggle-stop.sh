#!/bin/bash
# Stop hook: kills the background waggle animation started by waggle-start.sh.

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

_kill_pid_file() {
  local pid_file="$1"
  [ -f "$pid_file" ] || return
  local _PID
  _PID=$(cat "$pid_file" 2>/dev/null)
  rm -f "$pid_file" 2>/dev/null || true
  [ -z "$_PID" ] && return
  kill "$_PID" 2>/dev/null || true
}

if [ -n "$_SESSION_ID" ]; then
  _kill_pid_file "/tmp/waggle-${_SESSION_ID}.pid"
else
  for _f in /tmp/waggle-*.pid; do
    _kill_pid_file "$_f"
  done
fi

exit 0
