#!/bin/bash
PARENT_PID=$(ps -p "$$" -o ppid= | tr -d ' ')
PARENT_TTY=$(ps -p "$PARENT_PID" -o tty= 2>/dev/null | tr -d ' ')

{ [ -z "$PARENT_TTY" ] || [ "$PARENT_TTY" = "??" ]; } && exit 0

TERM_DEV="/dev/$PARENT_TTY"
[ -w "$TERM_DEV" ] || exit 0

cleanup() { printf '\r\033[K' > "$TERM_DEV" 2>/dev/null; }
trap cleanup EXIT

frames=('  (> ^.^)>  ' '  <( ^.^ )>  ' '  <(^.^ <)  ' '  <(     )>  ' '  (> ^.^)>  ' '  <(^.^ <)  ')
for _ in 1 2; do
  for frame in "${frames[@]}"; do
    printf '\r%s\033[K' "$frame" > "$TERM_DEV"
    sleep 0.75
  done
done
