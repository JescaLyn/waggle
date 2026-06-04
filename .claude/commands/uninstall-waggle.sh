#!/usr/bin/env bash
# description: Remove a dancer hook. First arg is dancer name (default: waggle); second arg is project path (default: global).
# usage: /uninstall-waggle [<dancer>] [<project-path>]

PROJ="${CLAUDE_PROJECT_DIR:-.}"
bash "$PROJ/.claude/skills/uninstall-waggle/scripts/uninstall.sh" "$@"
