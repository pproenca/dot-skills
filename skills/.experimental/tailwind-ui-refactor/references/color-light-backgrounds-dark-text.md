---
title: Use Light-Colored Backgrounds With Dark Text for Badges
impact: MEDIUM
impactDescription: prevents unreadable white-on-dark badge text
tags: color, badges, pills, status, readability
---

Colored badges with white text are hard to make accessible — the background needs to be dark enough for white text, which makes the badge visually heavy. Use light background + dark text for better readability and lighter visual weight.

**Incorrect (dark background, white text — too heavy):**
```html
<div class="flex gap-2">
  <span class="rounded-full bg-green-600 px-3 py-1 text-xs font-bold text-white">Active</span>
  <span class="rounded-full bg-yellow-600 px-3 py-1 text-xs font-bold text-white">Pending</span>
  <span class="rounded-full bg-red-600 px-3 py-1 text-xs font-bold text-white">Failed</span>
</div>
```

**Correct (light background, dark text — lighter and more readable):**
```html
<div class="flex gap-2">
  <span class="rounded-full bg-green-50 px-2.5 py-0.5 text-xs font-medium text-green-700">Active</span>
  <span class="rounded-full bg-yellow-50 px-2.5 py-0.5 text-xs font-medium text-yellow-700">Pending</span>
  <span class="rounded-full bg-red-50 px-2.5 py-0.5 text-xs font-medium text-red-700">Failed</span>
</div>
```

Reference: Refactoring UI — "Working with Color"
