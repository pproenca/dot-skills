---
title: Use Fewer Borders — Replace With Spacing, Shadows, or Background Color
impact: MEDIUM
impactDescription: eliminates visual clutter from excessive border lines
tags: sep, borders, spacing, shadows, background, clutter
---

Borders are the default way to separate elements, but too many make the design feel busy and cluttered. Replace borders with box shadows, increased spacing, or different background colors for cleaner separation.

**Incorrect (borders everywhere):**
```html
<div class="divide-y border">
  <div class="border-b p-4">
    <h3 class="border-b pb-2 font-semibold">Section Title</h3>
    <p class="border-b py-2 text-sm text-gray-600">Content here</p>
    <div class="flex gap-2 border-t pt-2">
      <button class="rounded border px-3 py-1 text-sm">Edit</button>
      <button class="rounded border px-3 py-1 text-sm">Delete</button>
    </div>
  </div>
</div>
```

**Correct (clean separation without borders):**
```html
<div class="rounded-lg bg-white p-6 shadow-sm">
  <h3 class="font-semibold text-gray-900">Section Title</h3>
  <p class="mt-2 text-sm text-gray-600">Content here</p>
  <div class="mt-4 flex gap-2">
    <button class="rounded-lg bg-gray-100 px-3 py-1.5 text-sm font-medium text-gray-700">Edit</button>
    <button class="text-sm font-medium text-red-600">Delete</button>
  </div>
</div>
```

Reference: Refactoring UI — "Finishing Touches"
