---
title: Convert Inline Spacing to Stack Spacing on Mobile
impact: MEDIUM
impactDescription: prevents horizontal overflow on narrow screens
tags: rspac, inline, stack, space-x, space-y, flex-direction
---

## Convert Inline Spacing to Stack Spacing on Mobile

Horizontal spacing (`space-x-*`, `gap` in a flex-row) doesn't work when elements stack vertically on mobile. If a flex container switches from `flex-row` to `flex-col` but keeps `space-x-*`, the horizontal margins remain on elements that are now stacked -- creating invisible left margins and no vertical separation. The spacing axis must follow the layout direction: vertical (`space-y-*`) when stacked, horizontal (`space-x-*`) when inline.

**Incorrect (horizontal spacing stays even when items wrap/stack):**

```html
<!-- space-x-4 adds left margin to each item, but on mobile they stack and the margin creates a left indent with no vertical gap -->
<div class="flex flex-wrap space-x-4">
  <a href="/docs" class="inline-flex items-center rounded-md bg-gray-100 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-200">
    <svg class="mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>
    Documentation
  </a>
  <a href="/api" class="inline-flex items-center rounded-md bg-gray-100 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-200">
    <svg class="mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" /></svg>
    API Reference
  </a>
  <a href="/support" class="inline-flex items-center rounded-md bg-gray-100 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-200">
    <svg class="mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192l-3.536 3.536M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-5 0a4 4 0 11-8 0 4 4 0 018 0z" /></svg>
    Support
  </a>
</div>
```

**Correct (spacing axis switches with layout direction):**

```html
<!-- Vertical stack with space-y-3 on mobile, horizontal row with space-x-4 on md+ — spacing follows the axis -->
<div class="flex flex-col space-y-3 md:flex-row md:space-y-0 md:space-x-4">
  <a href="/docs" class="inline-flex items-center rounded-md bg-gray-100 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-200">
    <svg class="mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>
    Documentation
  </a>
  <a href="/api" class="inline-flex items-center rounded-md bg-gray-100 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-200">
    <svg class="mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" /></svg>
    API Reference
  </a>
  <a href="/support" class="inline-flex items-center rounded-md bg-gray-100 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-200">
    <svg class="mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192l-3.536 3.536M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-5 0a4 4 0 11-8 0 4 4 0 018 0z" /></svg>
    Support
  </a>
</div>
```
