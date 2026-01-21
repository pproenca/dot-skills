---
title: Right-Size Terminal Dimensions
impact: MEDIUM-HIGH
impactDescription: 2-4× file size impact from oversized dimensions
tags: output, dimensions, width, height, optimization
---

## Right-Size Terminal Dimensions

Set terminal dimensions appropriate for your content. Oversized terminals waste pixels on empty space, dramatically increasing file size. Undersized terminals clip content.

**Incorrect (oversized for content):**

```tape
Output demo.gif

Set Width 1920
Set Height 1080

Type "echo hello"
Enter
Sleep 2s
# Massive GIF with 90% empty space
```

**Correct (sized to content):**

```tape
Output demo.gif

Set Width 800
Set Height 400

Type "echo hello"
Enter
Sleep 2s
# Compact GIF, fast to load
```

**Dimension guidelines by content:**
| Content Type | Width | Height |
|--------------|-------|--------|
| Simple command | 600-800 | 300-400 |
| README demo | 1000-1200 | 500-600 |
| Full terminal | 1200-1400 | 700-800 |
| Wide output (logs) | 1400-1600 | 600-700 |

**Test your dimensions:**

```tape
Output test.gif
Set Width 1000
Set Height 500

# Run your longest command
Type "your-command --with --many --flags"
Enter
# Verify nothing is clipped
```

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
