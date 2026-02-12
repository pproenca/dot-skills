---
title: Use Vertical Offset for Natural-Looking Shadows
impact: MEDIUM
impactDescription: eliminates shadow-[0_0_Npx] glow effect by using Tailwind's vertically-offset shadow-lg utility
tags: depth, shadows, offset, light-source, realism
---

Shadows in real life come from a light source above. Use vertical offset (y > x) for natural-looking shadows. Equal x/y spread looks like a blurry border, not a shadow. Tailwind's default shadows already use vertical offset correctly.

**Incorrect (equal spread looks like a glow):**
```html
<div class="rounded-lg bg-white p-6 shadow-[0_0_20px_rgba(0,0,0,0.15)]">
  <h3 class="font-semibold">Card Title</h3>
  <p class="text-sm text-gray-600">Card content goes here</p>
</div>
```

**Correct (vertical offset mimics overhead light):**
```html
<div class="rounded-lg bg-white p-6 shadow-lg">
  <h3 class="font-semibold">Card Title</h3>
  <p class="text-sm text-gray-600">Card content goes here</p>
</div>
```

Reference: Refactoring UI — "Depth"
