---
title: Use Underscores in Grid Arbitrary Values
impact: MEDIUM
impactDescription: prevents broken grid layouts
tags: syntax, grid, arbitrary-values, v4-migration
---

## Use Underscores in Grid Arbitrary Values

Tailwind v4 no longer converts commas to spaces in arbitrary values. Since grid template definitions use spaces to separate track sizes, you must use underscores (which Tailwind converts to spaces) instead of commas. This is consistent with how other arbitrary values handle spaces throughout the framework.

**Incorrect (what's wrong):**

```html
<!-- v3 comma syntax — v4 no longer converts commas to spaces -->
<div class="grid grid-cols-[max-content,1fr,auto]">
  Broken grid in v4
</div>
```

**Correct (what's right):**

```html
<!-- v4 underscore syntax — underscores become spaces -->
<div class="grid grid-cols-[max-content_1fr_auto]">
  Working grid in v4
</div>
```
