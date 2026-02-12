---
title: Add Overlays or Reduce Contrast for Text Over Images
impact: LOW-MEDIUM
impactDescription: prevents unreadable text over images via bg-gradient-to-t from-black/60 overlay
tags: img, overlay, text-contrast, hero, background
---

White text directly on a photo is unreadable on light areas. Add a semi-transparent dark overlay between the image and text, or use a gradient overlay that darkens from bottom up.

**Incorrect (text directly on image):**
```html
<div class="relative h-96">
  <img src="/hero.jpg" class="h-full w-full object-cover" />
  <div class="absolute inset-0 flex items-center justify-center">
    <h1 class="text-4xl font-bold text-white">Welcome to Our Platform</h1>
  </div>
</div>
```

**Correct (gradient overlay ensures readability):**
```html
<div class="relative h-96">
  <img src="/hero.jpg" class="h-full w-full object-cover" />
  <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
  <div class="absolute inset-0 flex items-end p-8">
    <h1 class="text-4xl font-bold text-white">Welcome to Our Platform</h1>
  </div>
</div>
```

Reference: Refactoring UI — "Working with Images"
