---
title: Add Window Decorations for Polish
impact: MEDIUM
impactDescription: creates professional-looking terminal appearance
tags: visual, windowbar, decoration, polish, branding
---

## Add Window Decorations for Polish

Use `WindowBar` and related settings to add macOS-style window decorations, giving your recordings a polished, professional look.

**Incorrect (no window decoration):**

```tape
Output demo.gif

Type "mycli demo"
Enter
# Plain terminal, no visual context
```

**Correct (with window decorations):**

```tape
Output demo.gif

Set WindowBar Colorful
Set WindowBarSize 40
Set BorderRadius 10

Type "mycli demo"
Enter
```

**WindowBar options:**
- `Rings`: macOS-style colored dots on left
- `RingsRight`: Colored dots on right
- `Colorful`: Vibrant colored dots on left
- `ColorfulRight`: Vibrant dots on right

**Combined with margins:**

```tape
Set WindowBar Colorful
Set WindowBarSize 40
Set BorderRadius 12
Set Margin 20
Set MarginFill "#1e1e2e"  # Match theme background
Set Padding 10

# Creates a nicely framed terminal window
```

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
