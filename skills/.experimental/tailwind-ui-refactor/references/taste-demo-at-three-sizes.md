---
title: Demo Every Component at 320px, 768px, and 1440px Before Finalizing
impact: CRITICAL
impactDescription: prevents 2-5× responsive rework by catching breakage at 320px, 768px, and 1440px before shipping
tags: taste, demo, responsive, validation, breakpoints
---

A component that looks great at one viewport width was never finished. Before considering any refactoring complete, mentally render the component at three sizes: 320px (small phone), 768px (tablet), 1440px (desktop). Check that text doesn't truncate unexpectedly, flex items wrap gracefully, and the visual hierarchy still works at every size.

**Incorrect (looks great at 1024px, breaks at 320px):**
```html
<div class="flex items-center gap-6 rounded-lg border p-6">
  <img class="h-16 w-16 rounded-full" src="/avatar.jpg" alt="Sarah Chen" />
  <div>
    <h3 class="text-lg font-semibold text-gray-900">Sarah Chen</h3>
    <p class="text-sm text-gray-600">Senior Product Designer at Acme Corp · San Francisco, CA</p>
  </div>
  <button class="ml-auto rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Connect</button>
</div>
```

**Correct (works at all three sizes):**
```html
<div class="flex flex-col gap-4 rounded-lg border p-4 sm:flex-row sm:items-center sm:gap-6 sm:p-6">
  <img class="h-12 w-12 rounded-full sm:h-16 sm:w-16" src="/avatar.jpg" alt="Sarah Chen" />
  <div class="min-w-0 flex-1">
    <h3 class="text-base font-semibold text-gray-900 sm:text-lg">Sarah Chen</h3>
    <p class="truncate text-sm text-gray-600">Senior Product Designer at Acme Corp</p>
  </div>
  <button class="w-full rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white sm:w-auto">Connect</button>
</div>
```

**Demo checklist at each size:**
- **320px:** Does text wrap or truncate cleanly? Does the layout stack vertically? Are touch targets at least 44px?
- **768px:** Does the layout transition gracefully? Are there awkward gaps from rigid breakpoints?
- **1440px:** Is content width constrained? Does the hierarchy still guide the eye or does it get lost in whitespace?

A component that breaks at any of these three sizes was never finished — it was abandoned at the first viewport that looked right.

Reference: Ken Kocienda, Creative Selection — Apple's demo culture required showing working prototypes, not static mockups
