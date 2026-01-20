---
title: Select Appropriate Theme
impact: MEDIUM
impactDescription: affects brand consistency and readability
tags: visual, theme, colors, branding
---

## Select Appropriate Theme

Choose a theme that matches your project's branding and provides good contrast. Dark themes work well for most terminal demos; light themes may be needed for specific documentation contexts.

**Incorrect (default theme may clash):**

```tape
Output demo.gif
# Default theme may not match your project's style
```

**Correct (themed for context):**

```tape
Output demo.gif

Set Theme "Catppuccin Mocha"  # Popular dark theme

Type "mycli demo"
Enter
```

**List available themes:**

```bash
vhs themes  # Shows all built-in themes
```

**Popular theme choices:**
- **Catppuccin Mocha/Frappe**: Modern, soft colors
- **Dracula**: Popular dark theme
- **One Dark**: Atom-style theme
- **Tokyo Night**: Calm, easy on eyes
- **Nord**: Minimal, arctic palette

**Custom theme:**

```tape
Set Theme {
  "name": "Custom",
  "background": "#1e1e2e",
  "foreground": "#cdd6f4",
  "cursor": "#f5e0dc"
}
```

Reference: [VHS README - Theme](https://github.com/charmbracelet/vhs#settings)
