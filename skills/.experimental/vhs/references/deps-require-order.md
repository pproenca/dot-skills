---
title: Place Require Before Settings
impact: CRITICAL
impactDescription: ensures early failure before any processing
tags: deps, require, order, structure
---

## Place Require Before Settings

Place all `Require` commands at the very top of your tape file, before settings and output declarations. This ensures VHS fails as early as possible if dependencies are missing, before spending time on configuration.

**Incorrect (Require after settings):**

```tape
Output demo.gif

Set Shell "bash"
Set FontSize 32
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"

Require glow
Require bat
# VHS already processed settings before failing
```

**Correct (Require first):**

```tape
# Dependencies
Require glow
Require bat

# Output
Output demo.gif

# Settings
Set Shell "bash"
Set FontSize 32
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
```

Reference: [VHS README - Require](https://github.com/charmbracelet/vhs#require)
