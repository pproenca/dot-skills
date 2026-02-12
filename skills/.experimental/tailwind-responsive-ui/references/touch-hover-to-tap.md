---
title: Replace Hover Interactions with Tap-Friendly Alternatives
impact: MEDIUM
impactDescription: ensures functionality works on 60%+ of web traffic (mobile)
tags: touch, hover, mobile-first, interaction, accessibility
---

## Replace Hover Interactions with Tap-Friendly Alternatives

Hover-dependent UI patterns — tooltips that appear on hover, dropdowns that open on hover, action buttons that reveal on hover — simply do not work on touch screens. Over 60% of web traffic comes from devices without a hover capability, so hiding critical functionality behind `:hover` effectively makes it inaccessible to the majority of users. Always ensure the content or action is reachable via tap/click, using hover as a progressive enhancement on desktop only.

**Incorrect (actions only visible on hover — inaccessible on touch devices):**

```html
<!-- Card actions are invisible on mobile because group-hover never triggers on tap -->
<div class="group relative rounded-lg border bg-white p-4 shadow-sm">
  <img src="/product.jpg" alt="Wireless Headphones" class="h-48 w-full rounded object-cover" />
  <h3 class="mt-3 text-lg font-semibold">Wireless Headphones</h3>
  <p class="text-sm text-gray-600">$79.99</p>

  <!-- These actions are completely hidden on touch devices -->
  <div class="absolute inset-0 flex items-center justify-center gap-2 rounded-lg bg-black/40 opacity-0 transition-opacity group-hover:opacity-100">
    <button class="rounded-full bg-white px-4 py-2 text-sm font-medium">Quick View</button>
    <button class="rounded-full bg-blue-600 px-4 py-2 text-sm font-medium text-white">Add to Cart</button>
  </div>
</div>
```

**Correct (actions visible on mobile, hover-reveal on desktop):**

```html
<!-- Actions always visible on mobile, hover-reveal as enhancement on desktop -->
<div class="group relative rounded-lg border bg-white p-4 shadow-sm">
  <img src="/product.jpg" alt="Wireless Headphones" class="h-48 w-full rounded object-cover" />
  <h3 class="mt-3 text-lg font-semibold">Wireless Headphones</h3>
  <p class="text-sm text-gray-600">$79.99</p>

  <!-- Visible by default on mobile (opacity-100), hidden on desktop until hover -->
  <div class="mt-3 flex gap-2 opacity-100 transition-opacity md:absolute md:inset-0 md:mt-0 md:items-center md:justify-center md:rounded-lg md:bg-black/40 md:opacity-0 md:group-hover:opacity-100">
    <button class="rounded-full border border-gray-300 bg-white px-4 py-2 text-sm font-medium md:border-0">Quick View</button>
    <button class="rounded-full bg-blue-600 px-4 py-2 text-sm font-medium text-white">Add to Cart</button>
  </div>
</div>
```
