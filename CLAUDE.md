# Waggle

A pair of Claude Code hooks that play an ASCII animation on the terminal input line while Claude works, then clear it when Claude is ready. Purely cosmetic — no effect on Claude's input or output.

## How it works

Two hooks coordinate the animation:

- `waggle-start.sh` (`UserPromptSubmit`) — detects the TTY, starts the animation as a background process, and exits 0 immediately so Claude can begin processing without delay.
- `waggle-stop.sh` (`Stop`) — fires when Claude finishes, sends SIGTERM to the animation process. The dispatcher's `trap cleanup EXIT` fires `\r\033[K` on the terminal input line, clearing the animation before Claude's response is shown.

The animation (`waggle.sh`, copied from `lib/dispatcher.sh`) writes frames directly to `/dev/$TTY` using carriage returns (`\r`) to stay on the input line. Because the dispatcher is disowned after backgrounding, `waggle-start.sh` detects the TTY before exiting and passes it as `WAGGLE_TERM_DEV` — the process tree is unreliable after disown.

It exits immediately with code 0 in headless environments (no TTY, non-writable TTY).

## Timing

Each dancer defines its own `frames` and `sleep_dur`. The dispatcher loops until killed by `waggle-stop.sh` (SIGTERM) or after a 600s safety deadline. Either way, `trap cleanup EXIT` clears the terminal.

## Adding waggle to a project

Use `/install-waggle [<dancer>] [<project-path>]` from within this project in Claude Code. For manual install:

1. Copy `lib/waggle-start.sh` to `.claude/hooks/waggle-start.sh` in the target repo
2. Copy `lib/dispatcher.sh` to `.claude/hooks/waggle.sh`
3. Copy `lib/waggle-stop.sh` to `.claude/hooks/waggle-stop.sh`
4. Create `.claude/hooks/waggle-dancers/` and copy one or more dancer scripts from `dancers/` into it
5. Add both hook entries to `.claude/settings.json` or `.claude/settings.local.json`:

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