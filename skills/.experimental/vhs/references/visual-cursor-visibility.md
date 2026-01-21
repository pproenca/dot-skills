---
title: Ensure Cursor Visibility
impact: LOW-MEDIUM
impactDescription: helps viewers track typing position
tags: visual, cursor, theme, tracking
---

## Ensure Cursor Visibility

Ensure your theme provides good cursor visibility. A clearly visible cursor helps viewers track where typing is happening, especially in longer recordings.

**Incorrect (cursor blends with background):**

```tape
Output demo.gif

Set Theme {
  "background": "#ffffff",
  "cursor": "#f0f0f0"
}
# Cursor nearly invisible on white background
```

**Correct (high-contrast cursor):**

```tape
Output demo.gif

Set Theme {
  "name": "Custom",
  "background": "#1e1e2e",
  "foreground": "#cdd6f4",
  "cursor": "#f5e0dc",
  "cursorAccent": "#1e1e2e"
}
```

**Using built-in themes with good cursors:**

```tape
Set Theme "Catppuccin Mocha"  # Pink cursor, high visibility
Set Theme "Dracula"           # Green cursor
Set Theme "One Dark"          # Blue cursor
```

**Test cursor visibility:**

```tape
Type "Look at the cursor position"
Sleep 1s
Left 10
Sleep 1s
# Cursor should be clearly visible at new position
```

Reference: [VHS README - Theme](https://github.com/charmbracelet/vhs#settings)
