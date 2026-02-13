---
title: Use @theme inline for Non-Utility Design Tokens
impact: MEDIUM
impactDescription: prevents unwanted utility class generation from internal tokens
tags: config, theme, design-tokens, v4-migration
---

## Use @theme inline for Non-Utility Design Tokens

Tailwind v4.1 introduced `@theme inline` for CSS variables that should be available in your CSS via `var()` but should NOT generate utility classes. This is useful for internal design tokens like animation timing, component-specific values, or intermediate calculations that would pollute the utility namespace.

**Incorrect (what's wrong):**

```css
@theme {
  --color-brand: #3b82f6;
  --animation-duration-fast: 150ms;
  --animation-duration-normal: 300ms;
  --sidebar-width: 280px;
}
```

This generates utility classes like `animation-duration-fast`, `sidebar-width` — classes nobody should use directly.

**Correct (what's right):**

```css
/* Public tokens — generate utility classes */
@theme {
  --color-brand: #3b82f6;
}

/* Internal tokens — available via var() but no utility classes */
@theme inline {
  --animation-duration-fast: 150ms;
  --animation-duration-normal: 300ms;
  --sidebar-width: 280px;
}
```

```css
/* Reference internal tokens in your CSS */
.sidebar {
  width: var(--sidebar-width);
  transition: transform var(--animation-duration-normal);
}
```
