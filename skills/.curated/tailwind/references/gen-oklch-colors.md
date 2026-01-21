---
title: Use OKLCH Color Space for Vivid Colors
impact: HIGH
impactDescription: 20-30% wider color gamut, perceptually uniform
tags: gen, colors, oklch, p3, modern-css
---

## Use OKLCH Color Space for Vivid Colors

Tailwind CSS v4 defaults to OKLCH color space, providing wider P3 gamut colors and perceptually uniform lightness. Use OKLCH syntax for custom colors.

**Incorrect (legacy sRGB hex values):**

```css
@theme {
  --color-accent-500: #7c3aed;
  --color-success-500: #22c55e;
  --color-warning-500: #f59e0b;
}
```

**Correct (OKLCH with wider gamut):**

```css
@theme {
  --color-accent-500: oklch(0.585 0.233 303.9);
  --color-success-500: oklch(0.723 0.191 142.5);
  --color-warning-500: oklch(0.769 0.188 70.08);
}
```

**Benefits:**
- More vivid colors on P3 displays
- Perceptually uniform lightness across hues
- Better gradient interpolation
- Future-proof for HDR displays

**Note:** OKLCH colors gracefully fall back to sRGB on older displays.

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
