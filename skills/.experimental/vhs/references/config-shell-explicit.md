---
title: Explicitly Set Shell Type
impact: CRITICAL
impactDescription: ensures consistent cross-platform behavior
tags: config, shell, portability, environment
---

## Explicitly Set Shell Type

Always specify the shell explicitly with `Set Shell` to ensure consistent behavior across different machines and CI environments. Without this, VHS uses the system default shell, which varies between macOS (zsh), Linux (bash), and user configurations.

**Incorrect (relies on system default):**

```tape
Output demo.gif

Set FontSize 32

Type "echo $SHELL"
Enter
# Output varies: /bin/zsh, /bin/bash, /usr/bin/fish...
```

**Correct (explicit shell declaration):**

```tape
Output demo.gif

Set Shell "bash"
Set FontSize 32

Type "echo $SHELL"
Enter
# Always outputs /bin/bash
```

**Benefits:**
- Reproducible recordings across team members
- Consistent CI/CD behavior
- Predictable prompt and syntax highlighting

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
