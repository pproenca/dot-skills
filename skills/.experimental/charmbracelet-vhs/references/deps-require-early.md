---
title: Use Require for Dependency Validation
impact: CRITICAL
impactDescription: prevents silent failures from missing programs
tags: deps, require, validation, fail-fast
---

## Use Require for Dependency Validation

Use `Require` commands to validate that all necessary programs are available before execution. Without `Require`, missing programs cause "command not found" errors to appear in your recording, wasting the entire render cycle.

**Incorrect (no dependency validation):**

```tape
Output demo.gif

Set Shell "bash"

Type "glow README.md"
Enter
Sleep 2s
# If glow isn't installed: "bash: glow: command not found" in your GIF
```

**Correct (fail-fast with Require):**

```tape
Output demo.gif

Require glow

Set Shell "bash"

Type "glow README.md"
Enter
Sleep 2s
# VHS fails immediately if glow is missing, before rendering
```

**Benefits:**
- Fails immediately with clear error message
- Saves render time on missing dependencies
- Documents tape file requirements explicitly

Reference: [VHS README - Require](https://github.com/charmbracelet/vhs#require)
