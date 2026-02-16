---
title: Use a Constrained Spacing Scale, Not Arbitrary Values
impact: CRITICAL
impactDescription: eliminates inconsistent spacing across the entire UI
tags: space, spacing-scale, consistency, design-system, tailwind-config
---

A linear spacing scale (2, 4, 6, 8...) creates too many similar options and leads to inconsistent decisions. Use a constrained scale where each step is noticeably different from the last: 4, 8, 12, 16, 24, 32, 48, 64, 96. Tailwind's default scale works well.

**Incorrect (arbitrary spacing values):**
```html
<div class="space-y-[7px]">
  <h3 class="mb-[5px] text-lg font-bold">Title</h3>
  <p class="mb-[13px] text-sm text-gray-600">Description text here</p>
  <button class="mt-[11px] rounded bg-blue-600 px-[15px] py-[9px] text-white">Action</button>
</div>
```

**Correct (Tailwind's systematic scale):**
```html
<div class="space-y-3">
  <h3 class="text-lg font-bold">Title</h3>
  <p class="text-sm text-gray-600">Description text here</p>
  <button class="mt-4 rounded bg-blue-600 px-4 py-2 text-white">Action</button>
</div>
```

**Taste checkpoint:** After applying systematic spacing, ask: "Does this feel mechanical or natural?" Systematic spacing is the foundation, but identical spacing between every section of a page can feel robotic. Use your system as the vocabulary, but vary it to create rhythm — tighter spacing for related sections, more generous spacing for section breaks.

Reference: Refactoring UI — "Layout and Spacing"
