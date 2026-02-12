---
title: Stack Elements on Mobile, Row on Desktop
impact: CRITICAL
impactDescription: fixes overflow on 100% of screens under 768px
tags: layout, flexbox, mobile-first, stacking, responsive
---

## Stack Elements on Mobile, Row on Desktop

The most common responsive pattern is elements sitting side-by-side on desktop that must stack vertically on mobile. Starting with `flex-row` as the default causes horizontal overflow on narrow screens because flex items get squeezed into unusable widths. Always start with `flex-col` (mobile-first) and switch to `flex-row` at wider breakpoints.

**Incorrect (flex-row default that overflows on mobile):**

```html
<!-- Items squeeze to ~100px each on a 375px screen, text truncates and images distort -->
<div class="flex flex-row gap-6">
  <div class="w-1/3 rounded-lg border p-4">
    <img src="/feature-1.jpg" alt="Feature 1" class="h-32 w-full object-cover" />
    <h3 class="text-lg font-semibold">Real-time Sync</h3>
    <p class="text-sm text-gray-600">Collaborate with your team in real time across all devices.</p>
  </div>
  <div class="w-1/3 rounded-lg border p-4">
    <img src="/feature-2.jpg" alt="Feature 2" class="h-32 w-full object-cover" />
    <h3 class="text-lg font-semibold">Smart Search</h3>
    <p class="text-sm text-gray-600">Find anything instantly with AI-powered search.</p>
  </div>
  <div class="w-1/3 rounded-lg border p-4">
    <img src="/feature-3.jpg" alt="Feature 3" class="h-32 w-full object-cover" />
    <h3 class="text-lg font-semibold">Analytics</h3>
    <p class="text-sm text-gray-600">Track performance with detailed dashboards.</p>
  </div>
</div>
```

**Correct (stack on mobile, row on desktop with mobile-first approach):**

```html
<!-- Stacks vertically on mobile, switches to row at md breakpoint -->
<div class="flex flex-col gap-4 md:flex-row md:gap-6">
  <div class="rounded-lg border p-4 md:w-1/3">
    <img src="/feature-1.jpg" alt="Feature 1" class="h-32 w-full rounded object-cover" />
    <h3 class="mt-3 text-lg font-semibold">Real-time Sync</h3>
    <p class="mt-1 text-sm text-gray-600">Collaborate with your team in real time across all devices.</p>
  </div>
  <div class="rounded-lg border p-4 md:w-1/3">
    <img src="/feature-2.jpg" alt="Feature 2" class="h-32 w-full rounded object-cover" />
    <h3 class="mt-3 text-lg font-semibold">Smart Search</h3>
    <p class="mt-1 text-sm text-gray-600">Find anything instantly with AI-powered search.</p>
  </div>
  <div class="rounded-lg border p-4 md:w-1/3">
    <img src="/feature-3.jpg" alt="Feature 3" class="h-32 w-full rounded object-cover" />
    <h3 class="mt-3 text-lg font-semibold">Analytics</h3>
    <p class="mt-1 text-sm text-gray-600">Track performance with detailed dashboards.</p>
  </div>
</div>
```

**Key principle:** `flex-col` is the mobile default; `md:flex-row` opts into horizontal layout only when there is enough room. Width constraints like `md:w-1/3` should also be breakpoint-prefixed so items remain full-width on mobile.
