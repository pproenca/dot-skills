---
title: Add Inner Shadow to Prevent Image Background Bleed
impact: LOW
impactDescription: prevents images from blending into page background
tags: polish, images, shadows, inner-shadow, background-bleed
---

When a light-colored image is placed on a light background, its edges disappear. Instead of adding a border (which looks heavy), use an inner shadow or a subtle ring to define the image boundary.

**Incorrect (image blends into background):**
```html
<div class="bg-white p-4">
  <img src="/screenshot.png" class="rounded-lg" />
</div>
```

**Correct (subtle ring defines boundary):**
```html
<div class="bg-white p-4">
  <img src="/screenshot.png" class="rounded-lg ring-1 ring-gray-900/5" />
</div>
```

**Alternative (inner shadow effect):**
```html
<div class="bg-white p-4">
  <div class="relative overflow-hidden rounded-lg">
    <img src="/screenshot.png" class="block" />
    <div class="absolute inset-0 rounded-lg shadow-[inset_0_0_0_1px_rgba(0,0,0,0.05)]" />
  </div>
</div>
```

Reference: Refactoring UI — "Working with Images"
