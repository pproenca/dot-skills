---
title: Design in Grayscale First, Add Color Last
impact: HIGH
impactDescription: forces proper hierarchy through spacing and contrast before color becomes a crutch
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

**Correct (hierarchy works in grayscale, color only on status badge):**
```html
<div class="space-y-2 p-4">
  <h3 class="text-base font-semibold text-gray-900">Project Alpha</h3>
  <span class="rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-700">Active</span>
  <p class="text-sm text-gray-600">Design Phase — 3 tasks remaining</p>
  <p class="text-xs text-gray-400">Due: March 15</p>
</div>
```

Reference: Refactoring UI — "Working with Color"
