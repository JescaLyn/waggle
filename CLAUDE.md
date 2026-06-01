# Waggle

A `UserPromptSubmit` hook for Claude Code that plays a short ASCII animation on the terminal input line while Claude processes a prompt, then clears itself. Purely cosmetic — no effect on Claude's input or output.

## How it works

The script detects the parent process's TTY via `ps` and writes animation frames directly to `/dev/$PARENT_TTY` using carriage returns (`\r`) to stay on one line, with `\033[K` to erase after each frame. A `trap cleanup EXIT` fires `\r\033[K` on any exit, including SIGTERM from a hook timeout. Without the trap, a timeout kill leaves animation characters on screen that corrupt subsequent Claude output.

It exits immediately with code 0 in headless environments (no TTY, non-writable TTY).

## Timing

6 frames × 2 cycles × 0.75s = 9 seconds total. One second under Claude Code's default 10s hook timeout. If the timeout fires anyway, the trap ensures the terminal still clears cleanly.

## Adding waggle to a project

1. Copy `waggle.sh` to `.claude/hooks/waggle.sh` in the target repo
2. Add a `UserPromptSubmit` entry to `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/waggle.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

For global install, copy to `~/.claude/hooks/waggle.sh` and use that path in `~/.claude/settings.json`.

## Animation sequence

```
  (> ^.^)>    arms right
  <( ^.^ )>   arms out
  <(^.^ <)    arms left
  <(     )>   arms out, blank
  (> ^.^)>    arms right
  <(^.^ <)    arms left
```
