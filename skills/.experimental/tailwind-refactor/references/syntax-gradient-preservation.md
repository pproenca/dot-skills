---
title: Reset Gradient Stops Explicitly in Variants
impact: MEDIUM
impactDescription: prevents unexpected gradient inheritance
tags: syntax, gradients, variants, v4-migration
---

## Reset Gradient Stops Explicitly in Variants

In Tailwind v3, gradient color stops were reset when a variant changed the `from-*` value. In v4, gradient stops are preserved across variants, meaning a `to-*` value set in the base state will persist into `dark:` or `hover:` variants. You must explicitly set all gradient stops for each variant to avoid unexpected color combinations.

**Incorrect (what's wrong):**

```html
<!-- to-yellow-400 persists into dark mode — unintended gradient -->
<div class="bg-linear-to-r from-red-500 to-yellow-400 dark:from-blue-500">
  Yellow leaks into dark mode gradient
</div>
```

**Correct (what's right):**

```html
<!-- Explicitly set all stops per variant -->
<div class="bg-linear-to-r from-red-500 to-yellow-400 dark:from-blue-500 dark:to-teal-400">
  Each variant fully defines its gradient
</div>
```

To clear a `via-*` stop in a variant, use `dark:via-none`.
