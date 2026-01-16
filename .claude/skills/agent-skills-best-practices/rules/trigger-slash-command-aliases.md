---
title: Include Slash Command Aliases in Description
impact: HIGH
impactDescription: enables explicit user invocation alongside automatic
tags: trigger, slash-commands, aliases, user-invocation
---

## Include Slash Command Aliases in Description

When users might invoke your skill explicitly via slash command, mention that command in the description. This helps Claude recognize explicit invocations and provides discoverability.

**Incorrect (no slash command mention):**

```yaml
---
name: commit-helper
description: Creates well-formatted git commits following conventional commit standards.
---
```

```text
# User types "/commit" - skill doesn't trigger
# User types "use the commit skill" - might work
# Explicit invocation path is broken
```

**Correct (includes slash command reference):**

```yaml
---
name: commit-helper
description: Creates well-formatted git commits following conventional commit standards. This skill should be used when the user wants to commit changes, types /commit, or asks to create a commit message.
---
```

```text
# User types "/commit" - skill triggers
# User types "commit my changes" - skill triggers
# Both invocation paths work
```

**Common slash command patterns:**
- `/commit` - Git operations
- `/review` - Code review
- `/test` - Test running
- `/deploy` - Deployment
- `/docs` - Documentation generation

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
