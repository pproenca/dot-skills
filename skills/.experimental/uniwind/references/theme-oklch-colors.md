---
title: Use OKLCH Color Space for Perceptual Uniformity
impact: HIGH
impactDescription: creates more visually consistent color palettes across themes
tags: theme, oklch, colors, design-system
---

## Use OKLCH Color Space for Perceptual Uniformity

OKLCH provides perceptually uniform colors. Changing lightness or chroma produces visually consistent results, unlike hex or RGB.

**Incorrect (RGB-based colors with inconsistent contrast):**

```css
@theme {
  --color-primary-light: #60a5fa;  /* Looks okay */
  --color-primary: #3b82f6;        /* Looks darker than expected */
  --color-primary-dark: #2563eb;   /* Jump in perceived darkness */
}
```

**Correct (OKLCH for uniform perception):**

```css
@theme {
  /* OKLCH: lightness (0-100%), chroma, hue */
  --color-primary-light: oklch(75% 0.15 250);
  --color-primary: oklch(60% 0.15 250);
  --color-primary-dark: oklch(45% 0.15 250);

  /* Consistent 15% lightness steps */
}
```

**Benefits of OKLCH:**
- Predictable lightness gradients
- Better accessibility contrast ratios
- Easier to generate color scales programmatically
- More consistent across different displays

**When to use:**
- Building design systems
- Creating accessible color palettes
- Generating hover/active state variations

Reference: [OKLCH Color Picker](https://oklch.com/)
