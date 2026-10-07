# Waggle

A set of Claude Code hooks that play an ASCII animation on the terminal input line while Claude works, then clear it when Claude is ready for input. Purely cosmetic — no effect on Claude's input or output.

## How it works

Four hook entries coordinate the animation:

- `waggle-start.sh` (`UserPromptSubmit`) — detects the TTY, starts the animation as a background process, and exits 0 immediately so Claude can begin processing without delay.
- `waggle-stop.sh` (`PreToolUse`, matcher: `AskUserQuestion`) — clears the animation before Claude asks for user input.
- `waggle-start.sh` (`PostToolUse`) — restarts the animation after a tool completes, so it resumes after permission prompts and AskUserQuestion answers. Idempotent: skips if the animation is already running.
- `waggle-stop.sh` (`Stop`) — fires when Claude finishes, sends SIGTERM to the animation process.

The animation dispatcher (`lib/dispatcher.sh`, installed as `waggle.sh`) writes frames directly to `/dev/$TTY` using carriage returns (`\r`) to stay on the input line. Because the dispatcher is disowned after backgrounding, `waggle-start.sh` detects the TTY before exiting and passes it as `WAGGLE_TERM_DEV` — the process tree is unreliable after disown.

This project runs hooks directly from `lib/` and points the dispatcher at `dancers/` via `WAGGLE_DANCERS_DIR`. Installed copies in other projects use `.claude/hooks/` with a `waggle-dancers/` subdirectory.

It exits immediately with code 0 in headless environments (no TTY, non-writable TTY).

## Timing

Each dancer defines its own `frames` and `sleep_dur`. The dispatcher loops until killed by `waggle-stop.sh` (SIGTERM), by the keypress monitor (user starts typing), or after a 600s safety deadline. Either way, `trap cleanup EXIT` clears the terminal. The keypress monitor is a background python3 process that watches the TTY for input and SIGTERMs the dispatcher, covering permission prompts and other cases where the user types mid-turn.

## Adding waggle to a project

Use `/install-waggle [<dancer>] [<project-path>]` from within this project in Claude Code. For manual install:

1. Copy `lib/waggle-start.sh` to `.claude/hooks/waggle-start.sh` in the target repo
2. Copy `lib/dispatcher.sh` to `.claude/hooks/waggle.sh`
3. Copy `lib/waggle-stop.sh` to `.claude/hooks/waggle-stop.sh`
4. Create `.claude/hooks/waggle-dancers/` and copy one or more dancer scripts from `dancers/` into it
5. Add the hook entries to `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/waggle-start.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "AskUserQuestion",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/waggle-stop.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/waggle-start.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/waggle-stop.sh"
          }
        ]
      }
    ]
  }
}
```

For global install, copy all three scripts to `~/.claude/hooks/`, create `~/.claude/hooks/waggle-dancers/`, and use `~/.claude/hooks/waggle-start.sh` / `~/.claude/hooks/waggle-stop.sh` paths in `~/.claude/settings.json`.

## Animation sequence (waggle dancer)

```
  (> ^.^)>   arms right
 <( ^.^ )>   arms out
 <(^.^ <)    arms left
 <(     )>   arms out, blank
  (> ^.^)>   arms right
 <(^.^ <)    arms left
```