# Waggle

A Claude Code hook that plays a short ASCII animation while Claude processes your prompt.

```
   (> ^.^)>
  <( ^.^ )>
  <(^.^ <)
```

Waggle picks a dancer at random from your installed pool on each prompt. It clears itself completely when done and exits silently in headless environments.

## Install

### Using the install command (recommended)

From within the waggle project in Claude Code:

```
/install-waggle                      # installs waggle globally (default dancer, global scope)
/install-waggle fish                 # installs fish globally
/install-waggle fish,ghost,crab      # installs a pool of three globally
/install-waggle all                  # installs every dancer globally
/install-waggle ~/myproject          # installs waggle into a specific project
/install-waggle fish ~/myproject     # installs fish into a specific project
/install-waggle all ~/myproject      # installs every dancer into a specific project
```

Install multiple dancers to build a pool — waggle picks one at random each prompt.

### Manual install

**1. Copy the dispatcher:**

```bash
# Global
cp lib/dispatcher.sh ~/.claude/hooks/waggle.sh
mkdir -p ~/.claude/hooks/waggle-dancers

# Project-level
cp lib/dispatcher.sh /path/to/your-project/.claude/hooks/waggle.sh
mkdir -p /path/to/your-project/.claude/hooks/waggle-dancers
```

**2. Copy one or more dancers into the pool:**

```bash
# Global
cp dancers/waggle.sh ~/.claude/hooks/waggle-dancers/waggle.sh

# Project-level
cp dancers/waggle.sh /path/to/your-project/.claude/hooks/waggle-dancers/waggle.sh
```

**3. Add the hook to your settings file:**

For global install (`~/.claude/settings.json`):

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

For project-level install (`.claude/settings.local.json` to keep it personal, or `.claude/settings.json` to share with your team):

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

## Uninstall

```
/uninstall-waggle                    # removes everything globally
/uninstall-waggle fish               # removes just fish globally
/uninstall-waggle fish,ghost         # removes fish and ghost globally
/uninstall-waggle all                # removes everything globally (same as no arg)
/uninstall-waggle ~/myproject        # removes everything from a specific project
/uninstall-waggle fish ~/myproject   # removes just fish from a specific project
```

## Available dancers

| Name | Description |
|------|-------------|
| waggle | The original — arms out, arms in |
| crab | Sideways shuffle |
| fish | Swims right, turns around |
| ghost | Spooky wiggle |
| cheer | Exuberant arm-waving |
| flower | Petals blooming side to side |
| robot | Stiff geometric arm raises |
| shades | Cool strut with music notes |
| tableflip | Frustration and redemption |
| tough | Flexing with a glare |

## Notes

- If your `settings.json` already has a `UserPromptSubmit` section, add the waggle entry to the existing hooks array rather than creating a second `UserPromptSubmit` key.
- Waggle detects headless environments (CI, background agents, no TTY) and exits immediately — safe to install globally.
- The animation loops until Claude responds or the 10s hook timeout fires. The cleanup trap clears the terminal either way.
