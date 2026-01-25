---
title: Use OKLCH Color Format for Theme Variables
impact: MEDIUM-HIGH
impactDescription: perceptually uniform colors with better dark mode transitions
tags: style, oklch, colors, theming, css-variables
---

## Use OKLCH Color Format for Theme Variables

shadcn/ui uses OKLCH color format for perceptually uniform color adjustments. HSL and hex values produce inconsistent lightness across hues.

**Incorrect (HSL with inconsistent perception):**

```css
:root {
  --primary: hsl(220, 90%, 50%);     /* Blue */
  --destructive: hsl(0, 90%, 50%);   /* Red */
  /* Both 50% lightness but red appears brighter */
}

.dark {
  --primary: hsl(220, 90%, 70%);     /* Lighter blue */
  --destructive: hsl(0, 90%, 70%);   /* Lighter red - too bright! */
}
```

**Correct (OKLCH with perceptual uniformity):**

```css
:root {
  --primary: oklch(0.488 0.243 264.376);      /* Blue */
  --destructive: oklch(0.577 0.245 27.325);   /* Red */
  /* Same perceptual lightness */
}

.dark {
  --primary: oklch(0.707 0.165 254.624);      /* Lighter blue */
  --destructive: oklch(0.704 0.191 22.216);   /* Lighter red - balanced */
}
```

**OKLCH format:** `oklch(lightness chroma hue)`
- Lightness: 0 (black) to 1 (white)
- Chroma: 0 (gray) to ~0.4 (vivid)
- Hue: 0-360 degrees

**Benefits:**
- Predictable contrast ratios
- Uniform appearance across different hues
- Better accessibility compliance

Reference: [shadcn/ui Theming](https://ui.shadcn.com/docs/theming)
