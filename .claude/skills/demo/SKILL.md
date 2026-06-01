---
name: demo
description: Demo a dancer animation in the terminal input line. No argument lists available dancers.
argument-hint: <dancer-name>
---

Demo the dancer. Arguments: `$ARGUMENTS`

Run:
```bash
bash ".claude/skills/demo/scripts/demo.sh" $ARGUMENTS
```

If `$ARGUMENTS` is blank, display the list of available dancers from the script output and stop.

Otherwise, tell the user to watch the bottom of their terminal, then run the command and wait. When it finishes, confirm which dancer ran.
