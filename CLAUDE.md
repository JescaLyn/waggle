# Waggle

A `UserPromptSubmit` hook for Claude Code that plays a short ASCII animation on the terminal input line while Claude processes a prompt, then clears itself. Purely cosmetic — no effect on Claude's input or output.

## How it works

The script detects the parent process's TTY via `ps` and writes animation frames directly to `/dev/$PARENT_TTY` using carriage returns (`\r`) to stay on one line, with `\033[K` to erase after each frame. A `trap cleanup EXIT` fires `\r\033[K` on any exit, including SIGTERM from a hook timeout. Without the trap, a timeout kill leaves animation characters on screen that corrupt subsequent Claude output.

It exits immediately with code 0 in headless environments (no TTY, non-writable TTY).

## Timing

Each dancer defines its own `frames` and `sleep_dur`. The dispatcher loops forever — the animation runs until Claude responds (hook receives SIGTERM) or the 10s hook timeout fires. Either way, the `trap cleanup EXIT` clears the terminal.

## Adding waggle to a project

Use `/install-waggle [<dancer>] [<project-path>]` from within this project in Claude Code. For manual install:

1. Copy `lib/dispatcher.sh` to `.claude/hooks/waggle.sh` in the target repo
2. Create `.claude/hooks/waggle-dancers/` and copy one or more dancer scripts from `dancers/` into it
3. Add a `UserPromptSubmit` entry to `.claude/settings.json` or `.claude/settings.local.json`:

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

For global install, copy to `~/.claude/hooks/waggle.sh`, create `~/.claude/hooks/waggle-dancers/`, and use that path in `~/.claude/settings.json`.

## Animation sequence (waggle dancer)

```
  (> ^.^)>   arms right
 <( ^.^ )>   arms out
 <(^.^ <)    arms left
 <(     )>   arms out, blank
  (> ^.^)>   arms right
 <(^.^ <)    arms left
```
