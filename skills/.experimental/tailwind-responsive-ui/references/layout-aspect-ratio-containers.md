---
title: Use Aspect Ratio for Responsive Containers
impact: MEDIUM
impactDescription: eliminates layout shift from loading content
tags: layout, aspect-ratio, cls, responsive, media
---

## Use Aspect Ratio for Responsive Containers

Containers that rely on their content to determine height cause Cumulative Layout Shift (CLS) as images, videos, or embeds load. The page reflows and pushes content down, degrading both user experience and Core Web Vitals scores. Using Tailwind's `aspect-*` utilities reserves the correct space before content loads, producing zero layout shift regardless of viewport width.

**Incorrect (no height constraint, causes layout shift as content loads):**

```html
<div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
  <!-- Container has no defined height — collapses to 0px until the image loads -->
  <div class="overflow-hidden rounded-lg">
    <img src="/hero-banner.jpg" alt="Summer collection" class="w-full" />
  </div>
  <!-- Embed has no reserved space — page jumps when iframe renders -->
  <div class="overflow-hidden rounded-lg">
    <iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ" class="w-full" title="Product demo"></iframe>
  </div>
</div>

<!-- Card grid where image heights are inconsistent across cards -->
<div class="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-3">
  <div class="rounded-lg border">
    <img src="/product-a.jpg" alt="Product A" class="w-full" />
    <div class="p-4">
      <h3 class="font-medium">Product A</h3>
    </div>
  </div>
  <div class="rounded-lg border">
    <img src="/product-b.jpg" alt="Product B" class="w-full" />
    <div class="p-4">
      <h3 class="font-medium">Product B</h3>
    </div>
  </div>
</div>
```

**Correct (aspect ratio reserves space, zero layout shift):**

```html
<div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
  <!-- 16:9 space reserved immediately — no reflow when image loads -->
  <div class="aspect-video overflow-hidden rounded-lg">
    <img src="/hero-banner.jpg" alt="Summer collection" class="h-full w-full object-cover" />
  </div>
  <!-- iframe fills the reserved 16:9 container -->
  <div class="aspect-video overflow-hidden rounded-lg">
    <iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ" class="h-full w-full" title="Product demo" allowfullscreen></iframe>
  </div>
</div>

<!-- Consistent card image heights using aspect-square -->
<div class="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-3">
  <div class="rounded-lg border">
    <div class="aspect-square overflow-hidden rounded-t-lg">
      <img src="/product-a.jpg" alt="Product A" class="h-full w-full object-cover" />
    </div>
    <div class="p-4">
      <h3 class="font-medium">Product A</h3>
    </div>
  </div>
  <div class="rounded-lg border">
    <div class="aspect-square overflow-hidden rounded-t-lg">
      <img src="/product-b.jpg" alt="Product B" class="h-full w-full object-cover" />
    </div>
    <div class="p-4">
      <h3 class="font-medium">Product B</h3>
    </div>
  </div>
</div>
```

**Common aspect ratio utilities:**
- `aspect-video` -- 16:9, ideal for video embeds and hero banners
- `aspect-square` -- 1:1, ideal for product images and avatars
- `aspect-[4/3]` -- 4:3, good for photos and thumbnails
- `aspect-[3/2]` -- 3:2, classic photography ratio

Always pair aspect ratio containers with `object-cover` (or `object-contain`) on the inner media element to prevent stretching or letterboxing.
