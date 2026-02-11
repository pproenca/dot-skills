---
title: Define a Fixed Shadow Scale — Small to Extra Large
impact: MEDIUM
impactDescription: creates consistent elevation system across the UI
tags: depth, shadows, elevation, scale, consistency
---

Instead of picking random shadow values, define a 5-level shadow scale. Small shadows for buttons and cards. Medium for dropdowns. Large for modals and dialogs. Apply shadows from this scale consistently.

**Incorrect (random shadow values):**
```html
<div class="space-y-4">
  <button class="rounded bg-blue-600 px-4 py-2 text-white shadow-[0_2px_8px_rgba(0,0,0,0.3)]">Click Me</button>
  <div class="rounded border p-4 shadow-[0_4px_20px_rgba(0,0,0,0.15)]">Card content</div>
  <div class="fixed inset-0 flex items-center justify-center">
    <div class="rounded-lg bg-white p-6 shadow-[0_10px_60px_rgba(0,0,0,0.4)]">Modal</div>
  </div>
</div>
```

**Correct (systematic Tailwind shadow scale):**
```html
<div class="space-y-4">
  <button class="rounded-lg bg-blue-600 px-4 py-2 text-white shadow-sm">Click Me</button>
  <div class="rounded-lg p-4 shadow">Card content</div>
  <div class="fixed inset-0 flex items-center justify-center">
    <div class="rounded-lg bg-white p-6 shadow-xl">Modal</div>
  </div>
</div>
```

Reference: Refactoring UI — "Depth"
