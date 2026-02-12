---
title: Reduce Grid Columns at Narrower Breakpoints
impact: CRITICAL
impactDescription: prevents content from becoming unreadably narrow
tags: layout, grid, columns, responsive, cards
---

## Reduce Grid Columns at Narrower Breakpoints

A 4-column grid on a 375px mobile screen means each item gets roughly 80px of width -- far too narrow for any meaningful content like card text, images, or form fields. Progressively reduce columns as the viewport shrinks: 4 columns on desktop, 2 on tablet, 1 on mobile. This keeps each item at a readable, tappable size.

**Incorrect (fixed 4-column grid at all screen sizes):**

```html
<!-- Each card gets ~80px on mobile — text wraps every word, images are thumbnails -->
<div class="grid grid-cols-4 gap-4 p-4">
  <div class="rounded-lg border bg-white p-4 shadow-sm">
    <img src="/product-1.jpg" alt="Wireless Headphones" class="h-24 w-full object-cover" />
    <h3 class="mt-2 font-medium">Wireless Headphones</h3>
    <p class="text-sm text-gray-500">$79.99</p>
  </div>
  <div class="rounded-lg border bg-white p-4 shadow-sm">
    <img src="/product-2.jpg" alt="USB-C Hub" class="h-24 w-full object-cover" />
    <h3 class="mt-2 font-medium">USB-C Hub</h3>
    <p class="text-sm text-gray-500">$49.99</p>
  </div>
  <div class="rounded-lg border bg-white p-4 shadow-sm">
    <img src="/product-3.jpg" alt="Mechanical Keyboard" class="h-24 w-full object-cover" />
    <h3 class="mt-2 font-medium">Mechanical Keyboard</h3>
    <p class="text-sm text-gray-500">$129.99</p>
  </div>
  <div class="rounded-lg border bg-white p-4 shadow-sm">
    <img src="/product-4.jpg" alt="Monitor Stand" class="h-24 w-full object-cover" />
    <h3 class="mt-2 font-medium">Monitor Stand</h3>
    <p class="text-sm text-gray-500">$34.99</p>
  </div>
</div>
```

**Correct (progressive column reduction: 1 → 2 → 4):**

```html
<!-- 1 column on mobile, 2 on sm/md, 4 on lg+ — each card stays readable -->
<div class="grid grid-cols-1 gap-4 p-4 sm:grid-cols-2 lg:grid-cols-4">
  <div class="rounded-lg border bg-white p-4 shadow-sm">
    <img src="/product-1.jpg" alt="Wireless Headphones" class="h-40 w-full rounded object-cover" />
    <h3 class="mt-2 font-medium">Wireless Headphones</h3>
    <p class="text-sm text-gray-500">$79.99</p>
  </div>
  <div class="rounded-lg border bg-white p-4 shadow-sm">
    <img src="/product-2.jpg" alt="USB-C Hub" class="h-40 w-full rounded object-cover" />
    <h3 class="mt-2 font-medium">USB-C Hub</h3>
    <p class="text-sm text-gray-500">$49.99</p>
  </div>
  <div class="rounded-lg border bg-white p-4 shadow-sm">
    <img src="/product-3.jpg" alt="Mechanical Keyboard" class="h-40 w-full rounded object-cover" />
    <h3 class="mt-2 font-medium">Mechanical Keyboard</h3>
    <p class="text-sm text-gray-500">$129.99</p>
  </div>
  <div class="rounded-lg border bg-white p-4 shadow-sm">
    <img src="/product-4.jpg" alt="Monitor Stand" class="h-40 w-full rounded object-cover" />
    <h3 class="mt-2 font-medium">Monitor Stand</h3>
    <p class="text-sm text-gray-500">$34.99</p>
  </div>
</div>
```

**Key principle:** Start with `grid-cols-1` as the mobile base, then increase with `sm:grid-cols-2` and `lg:grid-cols-4`. Each card maintains a minimum usable width at every breakpoint. The gap can also be adjusted per breakpoint if needed (`gap-3 md:gap-4 lg:gap-6`).
