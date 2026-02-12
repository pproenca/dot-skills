---
title: Use Responsive Gap for Grid and Flex Spacing
impact: HIGH
impactDescription: maintains visual rhythm across all screen sizes
tags: rspac, gap, grid, flex, rhythm
---

## Use Responsive Gap for Grid and Flex Spacing

Gap between grid and flex items must scale with available space. A `gap-8` (32px) between cards in a 3-column desktop grid feels balanced, but that same 32px gap in a single-column mobile layout wastes 8.5% of the 375px viewport width on empty space between every item. Progressive gap values preserve visual rhythm without sacrificing mobile content density.

**Incorrect (fixed gap wastes mobile space):**

```html
<!-- gap-8 = 32px between items regardless of screen — too much air on a single-column mobile layout -->
<section class="px-4">
  <h2 class="mb-6 text-xl font-bold text-gray-900">Featured Articles</h2>
  <div class="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
    <article class="overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm">
      <img src="/article-1.jpg" alt="Getting Started with TypeScript" class="h-48 w-full object-cover" />
      <div class="p-4">
        <h3 class="font-semibold text-gray-900">Getting Started with TypeScript</h3>
        <p class="mt-1 text-sm text-gray-600">A practical introduction to type-safe JavaScript development.</p>
      </div>
    </article>
    <article class="overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm">
      <img src="/article-2.jpg" alt="CSS Grid Deep Dive" class="h-48 w-full object-cover" />
      <div class="p-4">
        <h3 class="font-semibold text-gray-900">CSS Grid Deep Dive</h3>
        <p class="mt-1 text-sm text-gray-600">Master two-dimensional layouts with modern CSS Grid.</p>
      </div>
    </article>
    <article class="overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm">
      <img src="/article-3.jpg" alt="Node.js Performance Tips" class="h-48 w-full object-cover" />
      <div class="p-4">
        <h3 class="font-semibold text-gray-900">Node.js Performance Tips</h3>
        <p class="mt-1 text-sm text-gray-600">Optimize your server-side JavaScript for production workloads.</p>
      </div>
    </article>
  </div>
</section>
```

**Correct (progressive gap increases per breakpoint):**

```html
<!-- gap-3 on mobile, gap-6 on tablet, gap-8 on desktop — rhythm matches available space -->
<section class="px-4">
  <h2 class="mb-4 text-xl font-bold text-gray-900 md:mb-6">Featured Articles</h2>
  <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 md:gap-6 lg:grid-cols-3 lg:gap-8">
    <article class="overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm">
      <img src="/article-1.jpg" alt="Getting Started with TypeScript" class="h-48 w-full object-cover" />
      <div class="p-4">
        <h3 class="font-semibold text-gray-900">Getting Started with TypeScript</h3>
        <p class="mt-1 text-sm text-gray-600">A practical introduction to type-safe JavaScript development.</p>
      </div>
    </article>
    <article class="overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm">
      <img src="/article-2.jpg" alt="CSS Grid Deep Dive" class="h-48 w-full object-cover" />
      <div class="p-4">
        <h3 class="font-semibold text-gray-900">CSS Grid Deep Dive</h3>
        <p class="mt-1 text-sm text-gray-600">Master two-dimensional layouts with modern CSS Grid.</p>
      </div>
    </article>
    <article class="overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm">
      <img src="/article-3.jpg" alt="Node.js Performance Tips" class="h-48 w-full object-cover" />
      <div class="p-4">
        <h3 class="font-semibold text-gray-900">Node.js Performance Tips</h3>
        <p class="mt-1 text-sm text-gray-600">Optimize your server-side JavaScript for production workloads.</p>
      </div>
    </article>
  </div>
</section>
```
