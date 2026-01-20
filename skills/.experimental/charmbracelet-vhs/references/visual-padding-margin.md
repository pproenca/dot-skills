---
title: Use Padding and Margins Effectively
impact: LOW-MEDIUM
impactDescription: prevents content from touching edges
tags: visual, padding, margin, layout, framing
---

## Use Padding and Margins Effectively

Use `Padding` for space inside the terminal window and `Margin` with `MarginFill` for space outside. This prevents content from touching edges and creates a cleaner appearance.

**Incorrect (content touching edges):**

```tape
Output demo.gif

Set Padding 0

Type "mycli demo --output"
Enter
# Text touches window edges, looks cramped
```

**Correct (comfortable spacing):**

```tape
Output demo.gif

Set Padding 20
Set Margin 30
Set MarginFill "#282a36"

Type "mycli demo --output"
Enter
```

**Spacing strategies:**

```tape
# Minimal padding (compact)
Set Padding 10

# Standard padding (balanced)
Set Padding 20

# Generous padding (presentations)
Set Padding 40

# With decorative margin
Set Margin 40
Set MarginFill "#6B50FF"  # Brand color background
```

**Margin vs Padding:**
- **Padding**: Space inside the terminal, same color as background
- **Margin**: Space outside the terminal, can be different color/image

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
