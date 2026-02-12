---
title: Design Mobile-First at ~400px, Then Expand
impact: MEDIUM-HIGH
impactDescription: prevents desktop-first layouts that collapse poorly on mobile
tags: space, responsive, mobile-first, breakpoints
---

Start designing at a small viewport (~400px) where space is constrained and decisions are forced. Then expand to larger breakpoints by adding columns and increasing spacing. Mobile-first produces cleaner, more focused designs.

**Incorrect (desktop layout force-shrunk onto mobile):**
```html
<div class="grid grid-cols-3 gap-6 p-8">
  <div class="rounded-lg border p-6">
    <h3 class="text-xl font-bold">Feature One</h3>
    <p class="mt-3 text-gray-600">Description of the first feature with details.</p>
  </div>
  <div class="rounded-lg border p-6">
    <h3 class="text-xl font-bold">Feature Two</h3>
    <p class="mt-3 text-gray-600">Description of the second feature with details.</p>
  </div>
  <div class="rounded-lg border p-6">
    <h3 class="text-xl font-bold">Feature Three</h3>
    <p class="mt-3 text-gray-600">Description of the third feature with details.</p>
  </div>
</div>
```

**Correct (mobile-first, progressive enhancement):**
```html
<div class="grid gap-4 p-4 sm:grid-cols-2 sm:gap-6 sm:p-6 lg:grid-cols-3 lg:p-8">
  <div class="rounded-lg border p-4 sm:p-6">
    <h3 class="text-xl font-bold">Feature One</h3>
    <p class="mt-3 text-gray-600">Description of the first feature with details.</p>
  </div>
  <div class="rounded-lg border p-4 sm:p-6">
    <h3 class="text-xl font-bold">Feature Two</h3>
    <p class="mt-3 text-gray-600">Description of the second feature with details.</p>
  </div>
  <div class="rounded-lg border p-4 sm:p-6">
    <h3 class="text-xl font-bold">Feature Three</h3>
    <p class="mt-3 text-gray-600">Description of the third feature with details.</p>
  </div>
</div>
```

Reference: Refactoring UI — "Layout and Spacing"
