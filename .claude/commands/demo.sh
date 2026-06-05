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

DANCER="$1"
if [ ! -f "$DANCERS_DIR/$DANCER.sh" ]; then
  echo "ERROR: dancer '$DANCER' not found" >&2
  echo "Available dancers:"
  for f in "$DANCERS_DIR"/*.sh; do
    [ -f "$f" ] && echo "  $(basename "$f" .sh)"
  done
  exit 1
fi

echo "Watch the terminal input line..."
WAGGLE_DANCER="$DANCER" WAGGLE_DANCERS_DIR="$DANCERS_DIR" bash "$PROJ/lib/dispatcher.sh"
echo "Done."
