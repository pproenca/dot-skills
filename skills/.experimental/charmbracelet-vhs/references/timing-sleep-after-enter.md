---
title: Add Sleep After Commands for Output
impact: HIGH
impactDescription: ensures command output is captured before next action
tags: timing, sleep, output, visibility
---

## Add Sleep After Commands for Output

Always add a `Sleep` command after `Enter` to give the command time to execute and display output. Without this, VHS may proceed to the next command before output is visible, creating confusing recordings.

**Incorrect (no wait for output):**

```tape
Type "npm install"
Enter
Type "npm run build"
Enter
# Install output never visible, immediately types next command
```

**Correct (sleep for output visibility):**

```tape
Type "npm install"
Enter
Sleep 3s  # Wait for install to show progress

Type "npm run build"
Enter
Sleep 5s  # Wait for build output
```

**Adjust sleep duration based on command:**
- Simple echo/print: 500ms-1s
- File operations: 1-2s
- Network operations: 2-5s
- Build/compile: 5-30s

Reference: [VHS README - Sleep](https://github.com/charmbracelet/vhs#sleep)
