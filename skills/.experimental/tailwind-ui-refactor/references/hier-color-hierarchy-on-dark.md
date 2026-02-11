---
title: Use Opacity or Muted Colors for Hierarchy on Colored Backgrounds
impact: MEDIUM-HIGH
impactDescription: maintains readable hierarchy on brand and dark backgrounds
tags: hier, dark-mode, colored-backgrounds, opacity, contrast
---

On colored or dark backgrounds, you can't use gray text for de-emphasis — it looks disabled. Instead, reduce opacity or use a color that matches the background hue but with reduced saturation and increased lightness.

**Incorrect (gray text on colored background looks broken):**
```html
<div class="rounded-lg bg-blue-600 p-6">
  <h3 class="text-xl font-bold text-white">Premium Plan</h3>
  <p class="text-sm text-gray-400">Everything you need to grow</p>
  <p class="text-3xl font-bold text-white">$49/mo</p>
</div>
```

**Correct (opacity-based hierarchy on colored background):**
```html
<div class="rounded-lg bg-blue-600 p-6">
  <h3 class="text-xl font-bold text-white">Premium Plan</h3>
  <p class="text-sm text-blue-100">Everything you need to grow</p>
  <p class="text-3xl font-bold text-white">$49/mo</p>
</div>
```

**Alternative (using opacity):**
```html
<div class="rounded-lg bg-blue-600 p-6">
  <h3 class="text-xl font-bold text-white">Premium Plan</h3>
  <p class="text-sm text-white/60">Everything you need to grow</p>
  <p class="text-3xl font-bold text-white">$49/mo</p>
</div>
```

Reference: Refactoring UI — "Hierarchy is Everything"
