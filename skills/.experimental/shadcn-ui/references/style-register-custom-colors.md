---
title: Register Custom Colors with Tailwind Theme
impact: MEDIUM-HIGH
impactDescription: enables custom colors as Tailwind utility classes
tags: style, tailwind, theme, colors, configuration
---

## Register Custom Colors with Tailwind Theme

Custom CSS variables must be registered with Tailwind to use them as utility classes. Unregistered variables require verbose arbitrary value syntax.

**Incorrect (unregistered custom color):**

```css
/* globals.css */
:root {
  --brand: oklch(0.637 0.237 25.331);
  --brand-foreground: oklch(0.985 0 0);
}
```

```tsx
// Must use arbitrary values everywhere
<div className="bg-[--brand] text-[--brand-foreground]">
  {/* Verbose, no autocomplete */}
</div>
```

**Correct (registered with Tailwind):**

```css
/* globals.css */
:root {
  --brand: oklch(0.637 0.237 25.331);
  --brand-foreground: oklch(0.985 0 0);
}

.dark {
  --brand: oklch(0.704 0.191 22.216);
  --brand-foreground: oklch(0.145 0 0);
}

@theme inline {
  --color-brand: var(--brand);
  --color-brand-foreground: var(--brand-foreground);
}
```

```tsx
// Use standard Tailwind classes
<div className="bg-brand text-brand-foreground hover:bg-brand/90">
  {/* Clean syntax, autocomplete works */}
</div>
```

**For Tailwind v3 (tailwind.config.js):**

```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: "var(--brand)",
        "brand-foreground": "var(--brand-foreground)",
      },
    },
  },
}
```

Reference: [Tailwind CSS Colors](https://tailwindcss.com/docs/customizing-colors)
