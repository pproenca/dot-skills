---
title: Replace overflow-ellipsis with text-ellipsis
impact: CRITICAL
impactDescription: prevents build failure on deprecated class name
tags: dep, text, overflow, truncation
---

## Replace overflow-ellipsis with text-ellipsis

The `overflow-ellipsis` utility has been removed in Tailwind CSS v4. It was renamed to `text-ellipsis` to better reflect that it sets the `text-overflow` CSS property. Any remaining usage of `overflow-ellipsis` will cause a build failure in v4. Additionally, consider using the `truncate` utility as a single-class shorthand that combines `text-ellipsis`, `overflow-hidden`, and `whitespace-nowrap`.

**Incorrect (what's wrong):**

```html
<p class="overflow-ellipsis overflow-hidden whitespace-nowrap">
  This text will be truncated with an ellipsis when it overflows.
</p>
```

**Correct (what's right):**

```html
<p class="text-ellipsis overflow-hidden whitespace-nowrap">
  This text will be truncated with an ellipsis when it overflows.
</p>

<!-- Or use the truncate shorthand which applies all three at once -->
<p class="truncate">
  This text will be truncated with an ellipsis when it overflows.
</p>
```
