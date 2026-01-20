---
title: Use Comments to Document Tape Structure
impact: MEDIUM
impactDescription: improves maintainability and team collaboration
tags: config, comments, documentation, maintenance
---

## Use Comments to Document Tape Structure

Add comments using `#` to document the purpose of tape sections, explain timing choices, and note any non-obvious behavior. Comments are stripped from output and help future maintainers understand your intent.

**Incorrect (no documentation):**

```tape
Output demo.gif
Set Shell "bash"
Set FontSize 32
Set Width 1200
Set Height 600
Type "npm install"
Enter
Sleep 5s
Type "npm run build"
Enter
Sleep 10s
```

**Correct (documented structure):**

```tape
# Demo: npm project build workflow
# Author: Team Name
# Last updated: 2026-01

Output demo.gif

# Terminal configuration
Set Shell "bash"
Set FontSize 32
Set Width 1200
Set Height 600

# Install dependencies (wait for completion)
Type "npm install"
Enter
Sleep 5s  # npm install typically takes 3-5s on this project

# Run build process
Type "npm run build"
Enter
Sleep 10s  # Build takes ~8s, adding buffer for CI variance
```

Reference: [VHS README](https://github.com/charmbracelet/vhs)
