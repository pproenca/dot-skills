---
title: Swap Background Images at Breakpoints
impact: LOW-MEDIUM
impactDescription: serves appropriately sized hero images — saves 200-500KB on mobile
tags: rmedia, background-image, performance, hero, art-direction
---

## Swap Background Images at Breakpoints

A single high-resolution hero background loaded on all devices wastes bandwidth — a 2400px-wide JPEG can be 500KB+ that mobile users download over cellular connections despite only needing 640px of it. Tailwind's responsive arbitrary values let you swap `background-image` at each breakpoint, serving smaller files to smaller screens. For content images (not decorative backgrounds), prefer `<picture>` with `srcset` for even better browser-native resolution switching.

**Incorrect (single high-res background loaded on all devices):**

```html
<!-- 2400px hero image (~500KB) downloads even on a 375px mobile screen on 3G -->
<section class="relative bg-[url('/hero-2400.jpg')] bg-cover bg-center">
  <div class="bg-black/40 px-4 py-24 md:py-32 lg:py-40">
    <div class="mx-auto max-w-4xl text-center">
      <h1 class="text-3xl font-bold text-white md:text-5xl">
        Discover Your Next Adventure
      </h1>
      <p class="mt-4 text-lg text-white/90 md:text-xl">
        Handpicked destinations, curated experiences, unforgettable memories.
      </p>
      <a href="/explore" class="mt-8 inline-block rounded-lg bg-white px-6 py-3 font-semibold text-gray-900 shadow-lg hover:bg-gray-100">
        Start Exploring
      </a>
    </div>
  </div>
</section>
```

**Correct (responsive background images swapped per breakpoint):**

```html
<!-- Mobile gets 640px (~80KB), tablet 1200px (~200KB), desktop 2400px (~500KB) -->
<section class="relative bg-[url('/hero-640.jpg')] md:bg-[url('/hero-1200.jpg')] lg:bg-[url('/hero-2400.jpg')] bg-cover bg-center">
  <div class="bg-black/40 px-4 py-24 md:py-32 lg:py-40">
    <div class="mx-auto max-w-4xl text-center">
      <h1 class="text-3xl font-bold text-white md:text-5xl">
        Discover Your Next Adventure
      </h1>
      <p class="mt-4 text-lg text-white/90 md:text-xl">
        Handpicked destinations, curated experiences, unforgettable memories.
      </p>
      <a href="/explore" class="mt-8 inline-block rounded-lg bg-white px-6 py-3 font-semibold text-gray-900 shadow-lg hover:bg-gray-100">
        Start Exploring
      </a>
    </div>
  </div>
</section>
```

**Key principle:** Use Tailwind's responsive prefixes with arbitrary background-image values (`bg-[url('/small.jpg')] md:bg-[url('/medium.jpg')] lg:bg-[url('/large.jpg')]`) to serve appropriately sized images per breakpoint. For content images where SEO and accessibility matter, prefer `<picture>` with `<source srcset>` elements instead — it gives the browser native control over resolution switching and provides proper `alt` text.
