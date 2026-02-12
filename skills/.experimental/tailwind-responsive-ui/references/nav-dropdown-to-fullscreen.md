---
title: Expand Dropdown Menus to Full-Width on Mobile
impact: MEDIUM
impactDescription: increases touch target area by 3-4× on mobile
tags: nav, dropdown, touch-targets, mobile, responsive
---

## Expand Dropdown Menus to Full-Width on Mobile

Narrow dropdown menus designed for mouse hover are difficult to use on touch devices. A `w-48` (192px) dropdown with `py-1` padding produces touch targets that are too small and too close together, leading to frequent mis-taps. On mobile, expand dropdowns to full viewport width with generous padding to create finger-friendly tap targets that meet the 44px minimum recommended by WCAG and Apple HIG.

**Incorrect (narrow dropdown with small touch targets on mobile):**

```html
<!-- 192px-wide dropdown with cramped items — nearly impossible to tap accurately on a phone -->
<div class="relative">
  <button
    type="button"
    class="flex items-center gap-1 text-sm font-medium text-gray-700 hover:text-gray-900"
  >
    Categories
    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
    </svg>
  </button>

  <div class="absolute left-0 top-full z-20 mt-1 w-48 rounded-md border bg-white py-1 shadow-lg">
    <a href="/category/electronics" class="block px-4 py-1.5 text-sm text-gray-700 hover:bg-gray-100">Electronics</a>
    <a href="/category/clothing" class="block px-4 py-1.5 text-sm text-gray-700 hover:bg-gray-100">Clothing</a>
    <a href="/category/home-garden" class="block px-4 py-1.5 text-sm text-gray-700 hover:bg-gray-100">Home & Garden</a>
    <a href="/category/sports" class="block px-4 py-1.5 text-sm text-gray-700 hover:bg-gray-100">Sports & Outdoors</a>
    <a href="/category/books" class="block px-4 py-1.5 text-sm text-gray-700 hover:bg-gray-100">Books</a>
    <a href="/category/toys" class="block px-4 py-1.5 text-sm text-gray-700 hover:bg-gray-100">Toys & Games</a>
  </div>
</div>
```

**Correct (full-width dropdown on mobile, positioned dropdown on desktop):**

```html
<!-- Full-width on mobile with generous touch targets, narrow positioned dropdown on desktop -->
<div class="relative md:static">
  <button
    type="button"
    aria-expanded="false"
    class="flex items-center gap-1 text-sm font-medium text-gray-700 hover:text-gray-900"
  >
    Categories
    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
    </svg>
  </button>

  <div class="absolute inset-x-0 top-full z-20 mt-1 rounded-md border bg-white shadow-lg md:inset-x-auto md:left-0 md:w-48">
    <div class="py-2 md:py-1">
      <a href="/category/electronics" class="block px-4 py-3 text-base text-gray-700 active:bg-gray-100 md:py-2 md:text-sm md:hover:bg-gray-100">Electronics</a>
      <a href="/category/clothing" class="block px-4 py-3 text-base text-gray-700 active:bg-gray-100 md:py-2 md:text-sm md:hover:bg-gray-100">Clothing</a>
      <a href="/category/home-garden" class="block px-4 py-3 text-base text-gray-700 active:bg-gray-100 md:py-2 md:text-sm md:hover:bg-gray-100">Home & Garden</a>
      <a href="/category/sports" class="block px-4 py-3 text-base text-gray-700 active:bg-gray-100 md:py-2 md:text-sm md:hover:bg-gray-100">Sports & Outdoors</a>
      <a href="/category/books" class="block px-4 py-3 text-base text-gray-700 active:bg-gray-100 md:py-2 md:text-sm md:hover:bg-gray-100">Books</a>
      <a href="/category/toys" class="block px-4 py-3 text-base text-gray-700 active:bg-gray-100 md:py-2 md:text-sm md:hover:bg-gray-100">Toys & Games</a>
    </div>
  </div>
</div>
```

**Key principle:** Use `absolute inset-x-0 md:inset-x-auto md:left-0 md:w-48` so the dropdown spans full width on mobile but snaps to a fixed-width positioned menu on desktop. Increase padding with `py-3 md:py-2` and font size with `text-base md:text-sm` on mobile to ensure each touch target exceeds the 44px minimum. Use `active:bg-gray-100` instead of `hover:bg-gray-100` on mobile for immediate tap feedback.
