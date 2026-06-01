# Waggle

A Claude Code hook that plays a short ASCII animation while Claude processes your prompt — so the response delay doesn't feel like a hang.

```
  (> ^.^)>
  <( ^.^ )>
  <(^.^ <)
```

Waggle runs for about 9 seconds, then clears itself completely. It leaves no trace in the conversation and exits silently in headless environments.

## Install

### Project level

Adds Waggle to one repo. Use `.claude/settings.local.json` to keep it personal (not committed), or `.claude/settings.json` to share it with your team.

**1. Copy the script:**

```bash
cp waggle.sh /path/to/your-project/.claude/hooks/waggle.sh
```

**2. Add the hook to `.claude/settings.local.json` (or `.claude/settings.json`):**

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

### Global level

Adds Waggle to every project you open in Claude Code.

**1. Copy the script:**

```bash
cp waggle.sh ~/.claude/hooks/waggle.sh
```

**2. Add the hook to `~/.claude/settings.json`:**

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/waggle.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

## Notes

- If your `settings.json` already has a `UserPromptSubmit` section, add the waggle entry to the existing hooks array rather than creating a second `UserPromptSubmit` key.
- Waggle detects headless environments (CI, background agents, no TTY) and exits immediately — safe to install globally.
