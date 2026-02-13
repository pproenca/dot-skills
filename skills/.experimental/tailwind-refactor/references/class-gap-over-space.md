---
title: Prefer gap-* over space-x/y-* in Flex/Grid
impact: HIGH
impactDescription: eliminates margin-based spacing in flex/grid layouts
tags: class, gap, space, flex, grid
---

## Prefer gap-* over space-x/y-* in Flex/Grid

In flex and grid layouts, `gap-*` uses the native CSS `gap` property, which handles dynamic children correctly without selector hacks. The `space-x/y-*` utilities work by applying margins via `:not(:last-child)` selectors (changed from v3's `> * + *`), which can cause unexpected spacing when children are conditionally shown or hidden. Note: `space-*` is still a fully supported utility in v4 — this is a quality improvement, not a required migration.

**Incorrect (space-* with margin selectors):**

```html
<div class="flex flex-col space-y-4">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</div>
```

**Correct (gap-* with native CSS gap):**

```html
<div class="flex flex-col gap-4">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</div>
```

**When NOT to use this pattern:**
- `gap` only works inside flex and grid containers — for non-flex/grid stacked children, `space-*` remains the correct approach
- `space-*` is still valid when you need margin-based spacing for legacy layout reasons
