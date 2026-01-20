---
title: Place All Settings Before Commands
impact: CRITICAL
impactDescription: prevents silent setting failures
tags: config, settings, order, structure
---

## Place All Settings Before Commands

VHS requires all `Set` commands (except `TypingSpeed`) to appear before any non-setting or non-output commands. Settings placed after commands are silently ignored, causing recordings to use default values without warning.

**Incorrect (settings after commands are ignored):**

```tape
Output demo.gif

Type "echo hello"
Enter

Set FontSize 32
Set Theme "Catppuccin Mocha"
# These settings are silently ignored!
```

**Correct (all settings before commands):**

```tape
Output demo.gif

Set FontSize 32
Set Theme "Catppuccin Mocha"
Set Width 1200
Set Height 600

Type "echo hello"
Enter
```

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
