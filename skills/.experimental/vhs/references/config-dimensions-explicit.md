---
title: Set Explicit Terminal Dimensions
impact: HIGH
impactDescription: prevents content clipping and inconsistent layouts
tags: config, width, height, dimensions, layout
---

## Set Explicit Terminal Dimensions

Always specify `Width` and `Height` to ensure your content fits properly and renders consistently. Default dimensions may clip long commands or output, and vary across VHS versions.

**Incorrect (relying on defaults):**

```tape
Output demo.gif

Type "ls -la /usr/local/bin | head -20"
Enter
# Content may be clipped if default width is too narrow
```

**Correct (explicit dimensions for content):**

```tape
Output demo.gif

Set Width 1200
Set Height 600

Type "ls -la /usr/local/bin | head -20"
Enter
```

**Recommended dimensions:**
- Documentation/README: 1200×600 (wide, compact height)
- Full terminal demos: 1200×800 (standard aspect ratio)
- Social media: 800×600 (square-ish for previews)
- Minimal examples: 800×400 (compact)

Reference: [VHS README - Settings](https://github.com/charmbracelet/vhs#settings)
