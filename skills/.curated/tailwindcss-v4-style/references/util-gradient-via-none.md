---
title: Use via-none to Reset Gradient Stops
impact: MEDIUM-HIGH
impactDescription: prevents unexpected gradient behavior with variants
tags: util, gradients, via, variants, colors
---

## Use via-none to Reset Gradient Stops

Tailwind CSS v4 preserves gradient values across variants instead of resetting them. Explicitly use `via-none` to remove a middle stop.

**Incorrect (expecting gradient reset):**

```html
<div class="bg-linear-to-r from-red-500 via-orange-400 to-yellow-400
            dark:from-blue-500 dark:to-teal-400">
  <!-- v3: dark mode resets entire gradient -->
  <!-- v4: dark mode keeps via-orange-400! -->
</div>
```

**Correct (explicit via-none):**

```html
<div class="bg-linear-to-r from-red-500 via-orange-400 to-yellow-400
            dark:via-none dark:from-blue-500 dark:to-teal-400">
  <!-- Explicitly remove via stop in dark mode -->
</div>
```

**How v4 works:**
- Gradient stops are preserved across variants
- Each stop can be individually overridden
- Use `via-none` to convert 3-stop to 2-stop gradient
- More consistent with other utility behaviors

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
