---
title: Use @theme inline and @theme static for Variable Control
impact: MEDIUM
impactDescription: eliminates unnecessary CSS variable indirection
tags: theme, inline, static, variables, optimization
---

## Use @theme inline and @theme static for Variable Control

Tailwind v4 provides `@theme inline` and `@theme static` modifiers to control how theme variables are emitted in the CSS output. Use `inline` to avoid CSS variable indirection, and `static` to force variable generation for shared libraries.

**Incorrect (default @theme when runtime variables aren't needed):**

```css
@theme {
  --font-sans: "Inter", sans-serif;
  --color-brand: oklch(0.623 0.214 259.1);
}
/* Generates CSS variables on :root that may never be read at runtime */
/* .font-sans { font-family: var(--font-sans); } */
/* Nested variable resolution can produce unexpected results */
```

**Correct (@theme inline for direct value inlining):**

```css
@theme inline {
  --font-sans: "Inter", sans-serif;
  --color-brand: oklch(0.623 0.214 259.1);
}
/* No CSS variables on :root — values are inlined into utilities */
/* .font-sans { font-family: "Inter", sans-serif; } */
/* .text-brand { color: oklch(0.623 0.214 259.1); } */
```

**Use @theme static for shared libraries:**

```css
@theme static {
  --color-primary: var(--color-brand-500);
  --color-secondary: var(--color-blue-500);
}
/* Variables always emitted on :root, even if unused in this package */
/* Consumers in other packages can reference these variables */
```

**When to use each:**
- `@theme` (default) — most cases, balances runtime access with output size
- `@theme inline` — when you don't need runtime CSS variable access (e.g., fonts, static values)
- `@theme static` — when building shared libraries where consumers reference your variables

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)
