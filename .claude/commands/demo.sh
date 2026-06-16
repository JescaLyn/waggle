#!/usr/bin/env bash
# description: Preview a dancer animation. No argument lists available dancers. /demo all cycles through all.
# usage: /demo [<dancer-name>|all]

PROJ="${CLAUDE_PROJECT_DIR:-.}"
DANCERS_DIR="$PROJ/dancers"

if [ -z "${1:-}" ]; then
  echo "Available dancers:"
  for f in "$DANCERS_DIR"/*.sh; do
    [ -f "$f" ] && echo "  $(basename "$f" .sh)"
  done
  exit 0
fi

if [ "$1" = "all" ]; then
  echo "Watch the terminal input line... (cycling through all dancers)"
  dancers=()
  dancers+=("waggle")
  while IFS= read -r f; do
    name=$(basename "$f" .sh)
    [ "$name" != "waggle" ] && dancers+=("$name")
  done < <(find "$DANCERS_DIR" -maxdepth 1 -name "*.sh" -type f | sort)

  # Timeout for /demo all is set statically in .claude/settings.json (currently 60s,
  # ~52s for 10 dancers). Bump it if you add enough dancers that /demo all gets cut off.
  for dancer in "${dancers[@]}"; do
    WAGGLE_DANCER="$dancer" WAGGLE_DANCERS_DIR="$DANCERS_DIR" WAGGLE_MAX_CYCLES=1 WAGGLE_LABEL="$dancer" bash "$PROJ/lib/dispatcher.sh"
  done

  echo "Done."
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
WAGGLE_DANCER="$DANCER" WAGGLE_DANCERS_DIR="$DANCERS_DIR" WAGGLE_MAX_CYCLES=2 bash "$PROJ/lib/dispatcher.sh"
echo "Done."
