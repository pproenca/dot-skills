---
title: Use min-width Over max-width for Breakpoints
impact: MEDIUM-HIGH
impactDescription: prevents override cascading and specificity conflicts
tags: bp, min-width, max-width, specificity, cascade
---

## Use min-width Over max-width for Breakpoints

max-width breakpoints create a cascade hazard: when you add a new intermediate breakpoint, existing max-width rules may overlap and produce invisible bugs where desktop styles leak into tablet views. min-width builds upward — you only add properties as screen space grows, so new breakpoints never break existing ones. While `bp-mobile-first-default` covers the general direction, this rule focuses on the specific cascade and specificity problems max-width introduces.

**Incorrect (max-width overriding desktop defaults downward):**

```html
<!-- Desktop-first: base = complex layout, then strip it away going down -->
<div class="flex gap-8 max-[1024px]:gap-6 max-[768px]:gap-4 max-[768px]:flex-col">
  <aside class="w-72 shrink-0 max-[1024px]:w-60 max-[768px]:w-full">
    <ul class="space-y-2">
      <li><a href="#" class="block rounded-md bg-blue-50 px-4 py-2 text-blue-700 max-[768px]:bg-transparent max-[768px]:px-0 max-[768px]:py-1">Overview</a></li>
      <li><a href="#" class="block rounded-md px-4 py-2 text-gray-600 max-[768px]:px-0 max-[768px]:py-1">Analytics</a></li>
      <li><a href="#" class="block rounded-md px-4 py-2 text-gray-600 max-[768px]:px-0 max-[768px]:py-1">Settings</a></li>
    </ul>
  </aside>
  <main class="flex-1 max-[768px]:border-t max-[768px]:border-l-0 border-l border-gray-200 max-[768px]:pl-0 max-[768px]:pt-4 pl-8">
    <h1 class="text-2xl font-bold max-[768px]:text-lg">Dashboard</h1>
  </main>
</div>
```

**Correct (min-width building upward from simple base):**

```html
<!-- Mobile-first: base = stacked layout, add complexity as space grows -->
<div class="flex flex-col gap-4 md:flex-row md:gap-8">
  <aside class="w-full md:w-60 lg:w-72 md:shrink-0">
    <ul class="space-y-2">
      <li><a href="#" class="block py-1 text-blue-700 md:rounded-md md:bg-blue-50 md:px-4 md:py-2">Overview</a></li>
      <li><a href="#" class="block py-1 text-gray-600 md:rounded-md md:px-4 md:py-2">Analytics</a></li>
      <li><a href="#" class="block py-1 text-gray-600 md:rounded-md md:px-4 md:py-2">Settings</a></li>
    </ul>
  </aside>
  <main class="flex-1 border-t border-gray-200 pt-4 md:border-l md:border-t-0 md:pl-8 md:pt-0">
    <h1 class="text-lg font-bold md:text-2xl">Dashboard</h1>
  </main>
</div>
```
