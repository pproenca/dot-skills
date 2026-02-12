---
title: Use Scroll Snap for Carousel-Like Mobile Interfaces
impact: MEDIUM
impactDescription: replaces 50 to 200 lines of JS with CSS
tags: touch, scroll-snap, carousel, mobile, css
---

## Use Scroll Snap for Carousel-Like Mobile Interfaces

CSS scroll snap provides native-feeling, momentum-based swipe behavior for image galleries, card carousels, and tabbed content without any JavaScript. It is hardware-accelerated, respects user scroll preferences, and works identically across all modern mobile browsers. Replacing custom JS-based carousels with scroll snap reduces bundle size, eliminates touch-event handling bugs, and delivers a smoother experience that matches platform-native behavior users already expect.

**Incorrect (JavaScript-based carousel with manual touch event handling):**

```html
<!-- Heavy JS dependency, janky swipe, breaks with fast flicks, no momentum -->
<div id="carousel" class="relative overflow-hidden">
  <div id="carousel-track" class="flex transition-transform duration-300" style="transform: translateX(0)">
    <div class="w-full flex-shrink-0 p-4">
      <img src="/slide-1.jpg" alt="Summer Collection" class="h-64 w-full rounded-xl object-cover" />
      <h3 class="mt-3 text-xl font-bold">Summer Collection</h3>
    </div>
    <div class="w-full flex-shrink-0 p-4">
      <img src="/slide-2.jpg" alt="New Arrivals" class="h-64 w-full rounded-xl object-cover" />
      <h3 class="mt-3 text-xl font-bold">New Arrivals</h3>
    </div>
    <div class="w-full flex-shrink-0 p-4">
      <img src="/slide-3.jpg" alt="Best Sellers" class="h-64 w-full rounded-xl object-cover" />
      <h3 class="mt-3 text-xl font-bold">Best Sellers</h3>
    </div>
  </div>
  <button id="prev" class="absolute left-2 top-1/2 -translate-y-1/2 rounded-full bg-white/80 p-2">&#8249;</button>
  <button id="next" class="absolute right-2 top-1/2 -translate-y-1/2 rounded-full bg-white/80 p-2">&#8250;</button>
</div>
<script>
  // 50+ lines of touch start/move/end handlers, translateX math, boundary checks...
</script>
```

**Correct (pure CSS scroll snap — zero JavaScript, native momentum):**

```html
<!-- Native scroll snap: smooth, momentum-based, hardware-accelerated, no JS needed -->
<div class="flex snap-x snap-mandatory gap-4 overflow-x-auto scroll-smooth px-4 pb-4 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
  <article class="w-[90%] flex-shrink-0 snap-center md:w-[45%] lg:w-[30%]">
    <img src="/slide-1.jpg" alt="Summer Collection" class="h-64 w-full rounded-xl object-cover" />
    <h3 class="mt-3 text-xl font-bold">Summer Collection</h3>
    <p class="mt-1 text-gray-600">Lightweight fabrics for warm days ahead.</p>
  </article>
  <article class="w-[90%] flex-shrink-0 snap-center md:w-[45%] lg:w-[30%]">
    <img src="/slide-2.jpg" alt="New Arrivals" class="h-64 w-full rounded-xl object-cover" />
    <h3 class="mt-3 text-xl font-bold">New Arrivals</h3>
    <p class="mt-1 text-gray-600">Fresh drops added every week.</p>
  </article>
  <article class="w-[90%] flex-shrink-0 snap-center md:w-[45%] lg:w-[30%]">
    <img src="/slide-3.jpg" alt="Best Sellers" class="h-64 w-full rounded-xl object-cover" />
    <h3 class="mt-3 text-xl font-bold">Best Sellers</h3>
    <p class="mt-1 text-gray-600">Top picks loved by our community.</p>
  </article>
  <article class="w-[90%] flex-shrink-0 snap-center md:w-[45%] lg:w-[30%]">
    <img src="/slide-4.jpg" alt="Sale" class="h-64 w-full rounded-xl object-cover" />
    <h3 class="mt-3 text-xl font-bold">End of Season Sale</h3>
    <p class="mt-1 text-gray-600">Up to 60% off select styles.</p>
  </article>
</div>
```
