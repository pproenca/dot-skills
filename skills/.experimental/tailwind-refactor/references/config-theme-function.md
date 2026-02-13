---
title: Replace theme() Function with CSS Variables
impact: CRITICAL
impactDescription: prevents deprecation warnings across 100% of custom CSS using theme()
tags: config, theme-function, css-variables, deprecation
---

## Replace theme() Function with CSS Variables

The `theme()` function is deprecated in Tailwind CSS v4. All design tokens defined in `@theme` are now exposed as standard CSS custom properties, so you should reference them with `var()` instead. This aligns Tailwind with native CSS tooling and eliminates a proprietary function from your stylesheets.

**Incorrect (what's wrong):**

```css
.banner {
  background-color: theme(colors.red.500);
  width: theme(screens.xl);
  font-family: theme(fontFamily.sans);
}
```

**Correct (what's right):**

```css
.banner {
  background-color: var(--color-red-500);
  width: var(--breakpoint-xl);
  font-family: var(--font-sans);
}
```

Note: CSS variables cannot be used inside `@media` condition values. In media queries, use `theme()` with the CSS variable name syntax as a temporary workaround:

```css
@media (width >= theme(--breakpoint-xl)) {
  /* styles */
}
```
