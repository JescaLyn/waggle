#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DANCERS_DIR="$SCRIPT_DIR/../../../../dancers"

if [ -z "$1" ]; then
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

bash "$DANCER_SCRIPT"
