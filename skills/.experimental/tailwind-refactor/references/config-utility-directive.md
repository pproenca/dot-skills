---
title: Replace @layer utilities with @utility
impact: CRITICAL
impactDescription: enables 100+ variant combinations per custom utility (hover, md, dark, etc.)
tags: config, utilities, custom-utilities, variants
---

## Replace @layer utilities with @utility

In Tailwind CSS v4, custom utilities defined with `@layer utilities` will not be recognized by the variant system. The new `@utility` directive registers each utility so that Tailwind automatically generates all variants — hover, focus, responsive breakpoints, dark mode, and every other modifier — without any additional configuration.

**Incorrect (what's wrong):**

```css
@layer utilities {
  .tab-4 {
    tab-size: 4;
  }
}
```

**Correct (what's right):**

```css
@utility tab-4 {
  tab-size: 4;
}
```

With `@utility`, you can immediately use `hover:tab-4`, `md:tab-4`, `dark:tab-4`, and any other variant combination in your templates without writing extra CSS.
