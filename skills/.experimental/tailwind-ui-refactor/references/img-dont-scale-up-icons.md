---
title: Don't Scale Up Icons Designed for Small Sizes
impact: LOW-MEDIUM
impactDescription: prevents blurry, unbalanced icons in feature sections
tags: img, icons, scaling, svg, illustration
---

Icons drawn for 16-24px look awkward at 64px+ — line strokes feel too thin and details are insufficient. For large icon displays, use illustrations, enclose icons in colored shapes, or use an icon set designed for large sizes.

**Incorrect (small icon scaled up):**
```html
<div class="flex flex-col items-center text-center">
  <svg class="h-16 w-16 text-blue-600"><!-- 24px icon stretched to 64px --></svg>
  <h3 class="mt-4 text-lg font-semibold">Fast Delivery</h3>
  <p class="mt-2 text-sm text-gray-600">Get your order in 24 hours</p>
</div>
```

**Correct (icon enclosed in a shape for visual weight):**
```html
<div class="flex flex-col items-center text-center">
  <div class="flex h-14 w-14 items-center justify-center rounded-xl bg-blue-100">
    <svg class="h-6 w-6 text-blue-600"><!-- icon at designed size --></svg>
  </div>
  <h3 class="mt-4 text-lg font-semibold text-gray-900">Fast Delivery</h3>
  <p class="mt-2 text-sm text-gray-600">Get your order in 24 hours</p>
</div>
```

Reference: Refactoring UI — "Working with Images"
