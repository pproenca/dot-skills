---
title: Avoid Excessive Theme Variables
impact: CRITICAL
impactDescription: reduces CSS variable overhead by 50-80%
tags: gen, theme, variables, optimization, bundle
---

## Avoid Excessive Theme Variables

Every `@theme` variable generates a CSS custom property and multiple utility classes. Define only the tokens your design system actually needs.

**Incorrect (excessive variables):**

```css
@theme {
  /* 50 color shades when only 5 are used */
  --color-gray-50: oklch(0.985 0 0);
  --color-gray-100: oklch(0.967 0 0);
  --color-gray-150: oklch(0.945 0 0);
  --color-gray-200: oklch(0.923 0 0);
  /* ...40 more shades... */
  --color-gray-950: oklch(0.145 0 0);

  /* Generates hundreds of unused utilities */
}
```

**Correct (minimal token set):**

```css
@theme {
  /* Only define colors actually used in the design */
  --color-gray-100: oklch(0.967 0 0);
  --color-gray-300: oklch(0.869 0 0);
  --color-gray-500: oklch(0.708 0 0);
  --color-gray-700: oklch(0.373 0 0);
  --color-gray-900: oklch(0.21 0 0);
}
```

**Benefits:**
- Smaller CSS output (fewer variables and utilities)
- Faster CSS parsing in browser
- Clearer design system constraints
- Better maintainability

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)
