---
title: Replace transform-none with Individual Transform Resets
impact: CRITICAL
impactDescription: prevents broken transform resets
tags: dep, transform, scale, rotate, translate
---

## Replace transform-none with Individual Transform Resets

Tailwind CSS v4 uses individual CSS transform properties (`scale`, `rotate`, `translate`) instead of the composite `transform` property. This means `transform-none` no longer resets individual transforms like `scale-150` or `rotate-45`, because they are applied via separate CSS properties that `transform: none` does not affect. You must reset each transform property individually using `scale-none`, `rotate-none`, or `translate-none`.

**Incorrect (what's wrong):**

```html
<!-- transform-none does NOT reset scale in v4 because scale uses its own CSS property -->
<div class="scale-150 hover:transform-none">
  This element stays scaled on hover in v4
</div>
<div class="rotate-45 translate-x-4 md:transform-none">
  This element stays rotated and translated on md in v4
</div>
```

**Correct (what's right):**

```html
<!-- Reset each individual transform property -->
<div class="scale-150 hover:scale-none">
  This element resets scale on hover
</div>
<div class="rotate-45 translate-x-4 md:rotate-none md:translate-x-0">
  This element resets rotation and translation on md
</div>
```
