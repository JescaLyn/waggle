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

**1. Copy the hook scripts and dispatcher:**

```bash
# Global
mkdir -p ~/.claude/hooks
cp lib/waggle-start.sh lib/waggle-stop.sh ~/.claude/hooks/
cp lib/dispatcher.sh ~/.claude/hooks/waggle.sh
mkdir -p ~/.claude/hooks/waggle-dancers

# Project-level
mkdir -p /path/to/project/.claude/hooks
cp lib/waggle-start.sh lib/waggle-stop.sh /path/to/project/.claude/hooks/
cp lib/dispatcher.sh /path/to/project/.claude/hooks/waggle.sh
mkdir -p /path/to/project/.claude/hooks/waggle-dancers
```

**2. Copy one or more dancers into the pool:**

```bash
# Global
cp dancers/waggle.sh ~/.claude/hooks/waggle-dancers/

# Project-level
cp dancers/waggle.sh /path/to/project/.claude/hooks/waggle-dancers/
```

**3. Add the hooks to your settings file:**

For global install, add to `~/.claude/settings.json`. For project-level, add to `.claude/settings.local.json` (personal) or `.claude/settings.json` (shared with team). Adjust paths to match:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/waggle-start.sh",
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
            "command": "bash ~/.claude/hooks/waggle-stop.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/waggle-start.sh",
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
            "command": "bash ~/.claude/hooks/waggle-stop.sh"
          }
        ]
      }
    ]
  }
}
```

## Notes

- Waggle detects headless environments (CI, background agents, no TTY) and exits immediately, so it is safe to install globally.
- The animation persists across Claude's full turn. It starts on prompt submit, pauses before user input prompts, resumes after tool use, and stops when Claude finishes. A keypress monitor also stops the animation if you start typing mid-turn.
- A 600-second safety deadline ensures the animation never runs indefinitely.
