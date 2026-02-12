---
title: Scale Heading Sizes Independently Across Breakpoints
impact: MEDIUM-HIGH
impactDescription: maintains visual hierarchy ratio at every screen size
tags: fluid, headings, hierarchy, type-scale, proportional-scaling
---

## Scale Heading Sizes Independently Across Breakpoints

Don't scale all headings by the same ratio across breakpoints. An h1 that is 3x body size on desktop would dominate a small mobile screen, while an h3 that is 1.2x body size on desktop might look nearly identical to body text if reduced further on mobile. Each heading level needs its own scaling curve — the hierarchy should compress on mobile (smaller ratio between levels) and expand on desktop (larger ratio) so every level remains visually distinct without overwhelming the viewport.

**Incorrect (uniform scaling ratio across all heading levels):**

```html
<!-- Every heading doubles at md: — h1 dominates mobile, h3 barely differs from body on desktop -->
<div class="mx-auto max-w-4xl px-4 py-8">
  <h1 class="text-3xl font-bold text-gray-900 md:text-6xl">Product Features</h1>
  <h2 class="mt-8 text-2xl font-semibold text-gray-800 md:text-4xl">Performance</h2>
  <p class="mt-2 text-base text-gray-600 md:text-lg">
    Optimized for speed with sub-100ms response times.
  </p>
  <h3 class="mt-6 text-xl font-medium text-gray-700 md:text-2xl">Caching Layer</h3>
  <p class="mt-2 text-base text-gray-600 md:text-lg">
    Intelligent edge caching reduces server load by 80%.
  </p>
</div>
```

**Correct (independent scaling — tighter ratios on mobile, wider on desktop):**

```html
<!-- h1: 1.67× jump, h2: 1.33× jump, h3: 1.14× jump — hierarchy preserved at both sizes -->
<div class="mx-auto max-w-4xl px-4 py-8">
  <h1 class="text-3xl font-bold text-gray-900 md:text-5xl">Product Features</h1>
  <h2 class="mt-8 text-2xl font-semibold text-gray-800 md:text-3xl">Performance</h2>
  <p class="mt-2 text-base text-gray-600 md:text-lg">
    Optimized for speed with sub-100ms response times.
  </p>
  <h3 class="mt-6 text-xl font-medium text-gray-700 md:text-[1.375rem]">Caching Layer</h3>
  <p class="mt-2 text-base text-gray-600 md:text-lg">
    Intelligent edge caching reduces server load by 80%.
  </p>
</div>
```

**Key principle:** On mobile, the heading scale is compressed (h1=1.875rem, h2=1.5rem, h3=1.25rem — tight steps). On desktop, h1 jumps to 3rem while h2 only reaches 1.875rem and h3 stays at 1.375rem. This gives h1 the dramatic presence it needs on large screens without overwhelming mobile, while h2 and h3 grow just enough to remain distinct.
