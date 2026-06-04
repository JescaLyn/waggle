#!/usr/bin/env bash
# description: Install a dancer hook. First arg is dancer name (default: waggle); second arg is project path (default: global).
# usage: /install-waggle [<dancer>] [<project-path>]

PROJ="${CLAUDE_PROJECT_DIR:-.}"
bash "$PROJ/.claude/skills/install-waggle/scripts/install.sh" "$@"
