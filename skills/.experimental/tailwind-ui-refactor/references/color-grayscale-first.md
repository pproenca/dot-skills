---
title: Design in Grayscale First, Add Color Last
impact: HIGH
impactDescription: prevents color-dependent hierarchy by establishing contrast through size, weight, and grayscale first
tags: color, grayscale, hierarchy, process, design-flow
---

Designing in grayscale forces you to establish hierarchy through spacing, size, weight, and contrast. Color added on top of good hierarchy enhances it. Color used to compensate for bad hierarchy masks the problem.

**Incorrect (relying on color for hierarchy):**
```html
<div class="space-y-2 p-4">
  <h3 class="text-base text-blue-800">Project Alpha</h3>
  <span class="rounded bg-green-100 px-2 py-1 text-green-700">Active</span>
  <p class="text-sm text-purple-600">Design Phase — 3 tasks remaining</p>
  <p class="text-xs text-orange-500">Due: March 15</p>
</div>
```

**Correct (hierarchy works in grayscale, color only enhances):**
```html
<!-- Step 1: establish hierarchy in grayscale -->
<div class="space-y-2 p-4">
  <h3 class="text-base font-semibold text-gray-900">Project Alpha</h3>
  <span class="rounded-full bg-gray-100 px-2 py-0.5 text-xs font-medium text-gray-600">Active</span>
  <p class="text-sm text-gray-600">Design Phase — 3 tasks remaining</p>
  <p class="text-xs text-gray-500">Due: March 15</p>
</div>

<!-- Step 2: add color to enhance (only badge changes) -->
<div class="space-y-2 p-4">
  <h3 class="text-base font-semibold text-gray-900">Project Alpha</h3>
  <span class="rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-700">Active</span>
  <p class="text-sm text-gray-600">Design Phase — 3 tasks remaining</p>
  <p class="text-xs text-gray-500">Due: March 15</p>
</div>
```

The only difference between Step 1 and Step 2 is the badge color. If the hierarchy breaks without color, the grayscale structure needs more work.

**Taste checkpoint:** After adding color, toggle it back to grayscale mentally. Does the hierarchy still work? If removing color breaks the hierarchy, the underlying structure needs more work — color should enhance, never compensate.

Reference: Refactoring UI — "Working with Color"
