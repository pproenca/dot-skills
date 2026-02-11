---
title: Overlap Elements to Create Visual Layers
impact: LOW-MEDIUM
impactDescription: adds dimensional interest to flat card layouts
tags: depth, overlap, layers, z-index, offset
---

Overlapping elements slightly creates a sense of layered depth. Offset images from their containers, let cards overlap section boundaries, or use negative margins to create visual interest.

**Incorrect (everything aligned, flat):**
```html
<div class="bg-blue-600 px-6 py-12">
  <h2 class="text-center text-2xl font-bold text-white">Our Team</h2>
</div>
<div class="px-6 py-8">
  <div class="grid grid-cols-3 gap-6">
    <div class="rounded-lg bg-white p-4 shadow">Team member card</div>
    <div class="rounded-lg bg-white p-4 shadow">Team member card</div>
    <div class="rounded-lg bg-white p-4 shadow">Team member card</div>
  </div>
</div>
```

**Correct (cards overlap the hero section):**
```html
<div class="bg-blue-600 px-6 pb-24 pt-12">
  <h2 class="text-center text-2xl font-bold text-white">Our Team</h2>
</div>
<div class="-mt-16 px-6">
  <div class="mx-auto grid max-w-5xl grid-cols-3 gap-6">
    <div class="rounded-lg bg-white p-4 shadow-lg">Team member card</div>
    <div class="rounded-lg bg-white p-4 shadow-lg">Team member card</div>
    <div class="rounded-lg bg-white p-4 shadow-lg">Team member card</div>
  </div>
</div>
```

Reference: Refactoring UI — "Depth"
