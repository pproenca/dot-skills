---
title: Use Left-to-Right Variant Stacking
impact: HIGH
impactDescription: prevents broken responsive/state styles
tags: util, variants, stacking, order, syntax
---

## Use Left-to-Right Variant Stacking

Tailwind CSS v4 changes variant stacking from right-to-left to left-to-right. Update stacked variants to maintain correct behavior.

**Incorrect (v3 right-to-left order):**

```html
<ul class="*:py-2 first:*:pt-0 last:*:pb-0">
  <!-- Child selector applied before first/last -->
</ul>

<div class="group-hover:dark:bg-black">
  <!-- dark applied before group-hover -->
</div>
```

**Correct (v4 left-to-right order):**

```html
<ul class="*:py-2 *:first:pt-0 *:last:pb-0">
  <!-- Child selector first, then first/last -->
</ul>

<div class="dark:group-hover:bg-black">
  <!-- dark first, then group-hover -->
</div>
```

**Reading order:**
- Read variants left-to-right
- Outer context first, inner context last
- Matches natural language order: "in dark mode, on group hover, make background black"

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
