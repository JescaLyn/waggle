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

DANCERS_DIR="${WAGGLE_DANCERS_DIR:-$(cd "$(dirname "$0")" && pwd)/waggle-dancers}"
[ -d "$DANCERS_DIR" ] || exit 0

files=("$DANCERS_DIR"/*.sh)
[ -f "${files[0]}" ] || exit 0

if [ -n "${WAGGLE_DANCER:-}" ]; then
  dancer_file="$DANCERS_DIR/$WAGGLE_DANCER.sh"
  [ -f "$dancer_file" ] || exit 0
else
  count=${#files[@]}
  dancer_file="${files[$((RANDOM % count))]}"
fi

source "$dancer_file"
sleep_dur="${sleep_dur:-0.75}"
[ "${#frames[@]}" -eq 0 ] && exit 0

while true; do
  for frame in "${frames[@]}"; do
    printf '\r%s\033[K' "$frame" > "$TERM_DEV"
    sleep "$sleep_dur"
  done
done
