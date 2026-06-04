#!/usr/bin/env bash
# description: Preview a dancer animation. No argument lists available dancers.
# usage: /demo [<dancer-name>]

PROJ="${CLAUDE_PROJECT_DIR:-.}"
DANCERS_DIR="$PROJ/dancers"

if [ -z "${1:-}" ]; then
  echo "Available dancers:"
  for f in "$DANCERS_DIR"/*.sh; do
    [ -f "$f" ] && echo "  $(basename "$f" .sh)"
  done
  exit 0
fi

DANCER_SCRIPT="$DANCERS_DIR/$1.sh"
if [ ! -f "$DANCER_SCRIPT" ]; then
  echo "ERROR: dancer '$1' not found" >&2
  echo "Available dancers:"
  for f in "$DANCERS_DIR"/*.sh; do
    [ -f "$f" ] && echo "  $(basename "$f" .sh)"
  done
  exit 1
fi

echo "Watch the terminal input line..."
bash "$DANCER_SCRIPT"
echo "Done."
