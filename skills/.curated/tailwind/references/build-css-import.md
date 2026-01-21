---
title: Use CSS Import Over @tailwind Directives
impact: CRITICAL
impactDescription: eliminates deprecated patterns, enables v4 features
tags: build, import, directives, migration, configuration
---

## Use CSS Import Over @tailwind Directives

Tailwind CSS v4 replaces the old `@tailwind` directives with a single CSS import statement. This enables automatic content detection and modern CSS features.

**Incorrect (v3 deprecated directives):**

```css
/* styles.css */
@tailwind base;
@tailwind components;
@tailwind utilities;
/* Requires explicit content configuration */
```

**Correct (v4 CSS import):**

```css
/* styles.css */
@import "tailwindcss";
/* Automatic content detection, zero configuration */
```

**Benefits:**
- Zero configuration required for most projects
- Automatic template file detection
- Built-in @import support without additional plugins
- Single source of truth for styles

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
