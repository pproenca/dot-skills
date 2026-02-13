---
title: Replace @tailwind Directives with @import
impact: CRITICAL
impactDescription: prevents 100% build failure on v4
tags: config, directives, v4-migration, css-first
---

## Replace @tailwind Directives with @import

Tailwind CSS v4 removes the `@tailwind` directive entirely. The new CSS-first configuration model uses a single `@import "tailwindcss"` statement that replaces all three legacy directives. Without this change, your project will fail to compile on v4.

**Incorrect (what's wrong):**

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

**Correct (what's right):**

```css
@import "tailwindcss";
```

If your project needs prefixed classes to avoid collisions with existing CSS, use the prefix option:

```css
@import "tailwindcss" prefix(tw);
```

This produces classes like `tw:flex`, `tw:mt-4`, and `tw:text-red-500` instead of their unprefixed equivalents.
