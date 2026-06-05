# Waggle

A Claude Code hook that plays a short ASCII animation while Claude processes your prompt. You can install one or more dancers. If you have a pool of dancers, waggle picks one at random on each prompt.

```
  waggle             ghost           robot
  (> ^.^)>         ~( °o° )~       ┌[ □_□ ]┐
 <( ^.^ )>         ~( °o° )        └[ □_□ ]┘
 <(^.^ <)           ( °o° )~       ┌[ □_□ ]┘
```

## Available dancers

| Name | Preview |
|------|---------|
| waggle | `<( ^.^ )>` |
| crab | `(\/)====( ° ω ° )====(\/)`|
| fish | `<°)))><` |
| ghost | `~( °o° )~` |
| cheer | `╰( ^ᵕ^ )╯` |
| flower | `✿( ^‿^ )✿` |
| robot | `┌[ □_□ ]┐` |
| shades | `ᕕ( ⌐■_■)ᕗ ♪♬` |
| tableflip | `(╯ ˋ□ˊ)╯︵┻━┻` |
| tough | `ᕦ( ò_ó )ᕤ` |

## Demo

From within the waggle project in Claude Code, use `/demo` to preview any dancer before installing:

```
/demo              # lists available dancers
/demo waggle       # plays the waggle animation
/demo ghost        # plays the ghost animation
```

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

### Uninstall

```
/uninstall-waggle                    # removes everything globally
/uninstall-waggle fish               # removes just fish globally
/uninstall-waggle fish,ghost         # removes fish and ghost globally
/uninstall-waggle all                # removes everything globally (same as no arg)
/uninstall-waggle ~/myproject        # removes everything from a specific project
/uninstall-waggle fish ~/myproject   # removes just fish from a specific project
```

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

## Notes

- Waggle detects headless environments (CI, background agents, no TTY) and exits immediately — safe to install globally.
- The animation loops until Claude responds or the 10s hook timeout fires. The cleanup trap clears the terminal either way.
