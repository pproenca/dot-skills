---
title: Use Env for Environment Variables
impact: MEDIUM
impactDescription: cleaner than export commands, persists throughout recording
tags: cmd, env, environment, variables, configuration
---

## Use Env for Environment Variables

Use the `Env` command to set environment variables instead of typing `export` commands. `Env` sets variables before the shell starts, making them available immediately and keeping your tape cleaner.

**Incorrect (typing export commands):**

```tape
Type "export NODE_ENV=production"
Enter
Type "export DEBUG=true"
Enter
Type "npm start"
Enter
# Clutters recording with setup commands
```

**Correct (using Env command):**

```tape
Env NODE_ENV production
Env DEBUG true

Type "npm start"
Enter
# Variables are set, recording focuses on the demo
```

**Complex values with spaces:**

```tape
Env GREETING "Hello World"
Env PATH "/custom/bin:$PATH"

Type "echo $GREETING"
Enter
```

**When NOT to use this pattern:**
- When demonstrating how to set environment variables
- When the export itself is part of the tutorial

Reference: [VHS README - Env](https://github.com/charmbracelet/vhs#env)
