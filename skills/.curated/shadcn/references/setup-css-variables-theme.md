---
title: Enable CSS Variables for Consistent Theming
impact: CRITICAL
impactDescription: enables dark mode and design system consistency
tags: setup, css-variables, theming, tailwind, configuration
---

## Enable CSS Variables for Consistent Theming

Setting `cssVariables: true` in components.json enables the CSS variable-based theming system. Without this, dark mode and theme customization fail.

**Incorrect (utility classes without variables):**

```json
// components.json
{
  "tailwind": {
    "cssVariables": false
  }
}
```

```css
/* Generated component uses hardcoded colors */
.button {
  @apply bg-zinc-900 text-zinc-50;
}
/* Dark mode requires separate class overrides for every color */
```

**Correct (CSS variables enabled):**

```json
// components.json
{
  "tailwind": {
    "cssVariables": true,
    "baseColor": "neutral"
  }
}
```

```css
/* globals.css - single source of truth */
:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
  --primary: oklch(0.205 0 0);
  --primary-foreground: oklch(0.985 0 0);
}

.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  --primary: oklch(0.922 0 0);
  --primary-foreground: oklch(0.205 0 0);
}
```

Components automatically adapt to theme changes via CSS variables.

Reference: [shadcn/ui Theming](https://ui.shadcn.com/docs/theming)
