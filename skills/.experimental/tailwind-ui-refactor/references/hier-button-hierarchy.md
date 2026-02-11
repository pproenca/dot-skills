---
title: Style Buttons by Visual Hierarchy, Not Semantic Importance
impact: CRITICAL
impactDescription: eliminates competing CTAs that confuse users
tags: hier, buttons, actions, cta, primary, secondary, tertiary
---

Not every button deserves to be a big, colorful, primary button. Style buttons based on their position in the action hierarchy: primary (solid fill), secondary (outline or muted), tertiary (text-only link style). Destructive actions need prominence only when they're the primary action.

**Incorrect (all buttons look equally important):**
```html
<div class="flex gap-2">
  <button class="rounded-lg bg-blue-600 px-4 py-2 font-bold text-white">Save</button>
  <button class="rounded-lg bg-blue-600 px-4 py-2 font-bold text-white">Cancel</button>
  <button class="rounded-lg bg-red-600 px-4 py-2 font-bold text-white">Delete</button>
</div>
```

**Correct (clear action hierarchy):**
```html
<div class="flex items-center gap-3">
  <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Save</button>
  <button class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Cancel</button>
  <button class="text-sm font-medium text-red-600">Delete</button>
</div>
```

Reference: Refactoring UI — "Hierarchy is Everything"
