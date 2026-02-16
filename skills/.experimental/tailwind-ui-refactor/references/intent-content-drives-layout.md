---
title: Let Real Content Determine Layout — Not the Other Way Around
impact: HIGH
impactDescription: prevents 2-3 layout rewrites by designing around actual data from the start
tags: intent, content-first, layout, data, real-content
---

Designing a layout and then pouring content into it leads to components that fight their data. A two-column grid looks great with equal-length items but breaks with one 3-word item and one paragraph. Start from the actual content shape, then find the right container for it.

**Incorrect (forcing content into a pre-decided grid):**
```html
<div class="grid grid-cols-3 gap-6">
  <div class="rounded-lg border p-4">
    <h3 class="font-semibold text-gray-900">Revenue</h3>
    <p class="mt-2 text-3xl font-bold text-gray-900">$48,290</p>
  </div>
  <div class="rounded-lg border p-4">
    <h3 class="font-semibold text-gray-900">Detailed Customer Acquisition Cost Breakdown</h3>
    <p class="mt-2 text-3xl font-bold text-gray-900">$12.40 avg (paid: $18.20, organic: $3.10, referral: $8.50)</p>
  </div>
  <div class="rounded-lg border p-4">
    <h3 class="font-semibold text-gray-900">NPS</h3>
    <p class="mt-2 text-3xl font-bold text-gray-900">72</p>
  </div>
</div>
```

**Correct (layout adapts to content shape):**
```html
<div class="flex flex-wrap gap-6">
  <div class="rounded-lg border p-4">
    <h3 class="text-sm font-medium text-gray-500">Revenue</h3>
    <p class="mt-1 text-3xl font-bold text-gray-900">$48,290</p>
  </div>
  <div class="min-w-[280px] rounded-lg border p-4">
    <h3 class="text-sm font-medium text-gray-500">Customer Acquisition Cost</h3>
    <p class="mt-1 text-2xl font-bold text-gray-900">$12.40 avg</p>
    <p class="mt-1 text-sm text-gray-500">Paid $18.20 · Organic $3.10 · Referral $8.50</p>
  </div>
  <div class="rounded-lg border p-4">
    <h3 class="text-sm font-medium text-gray-500">NPS</h3>
    <p class="mt-1 text-3xl font-bold text-gray-900">72</p>
  </div>
</div>
```

Before choosing a grid, list the actual content items and their sizes. If items vary widely, use `flex-wrap` instead of rigid columns.

**Taste checkpoint:** After building the layout, populate it with real data — including edge cases. What happens with a 3-word title vs. a 30-word title? An empty description vs. a paragraph? A name like "Jo" vs. "Alexander Bartholomew III"? The layout should gracefully handle the full range of real content, not just the happy path.

Reference: Refactoring UI — "Start with a Feature, Not a Layout" · Ken Kocienda, Creative Selection — Apple tested with real content, not placeholder data
