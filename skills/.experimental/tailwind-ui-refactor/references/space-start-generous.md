---
title: Start With Too Much Whitespace, Then Remove
impact: CRITICAL
impactDescription: transforms cramped amateur layouts into professional interfaces
tags: space, whitespace, padding, margin, layout
---

Dense interfaces feel overwhelming and amateurish. Start with more whitespace than you think you need, then remove it until it looks right. It's easier to remove space than to add it later.

**Incorrect (cramped, insufficient spacing):**
```html
<div class="rounded border p-2">
  <h3 class="text-lg font-bold">Project Alpha</h3>
  <p class="text-sm text-gray-600">Due: March 15</p>
  <p class="text-sm text-gray-600">A new marketing campaign for Q2 launch targeting enterprise customers.</p>
  <button class="mt-1 rounded bg-blue-600 px-3 py-1 text-sm text-white">View Details</button>
</div>
```

**Correct (generous spacing feels premium):**
```html
<div class="rounded-lg border p-6">
  <h3 class="text-lg font-semibold text-gray-900">Project Alpha</h3>
  <p class="mt-1 text-sm text-gray-500">Due: March 15</p>
  <p class="mt-3 text-sm leading-relaxed text-gray-600">A new marketing campaign for Q2 launch targeting enterprise customers.</p>
  <button class="mt-5 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">View Details</button>
</div>
```

Reference: Refactoring UI — "Layout and Spacing"
