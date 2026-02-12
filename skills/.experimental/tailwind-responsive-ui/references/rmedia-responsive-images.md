---
title: Use Responsive Image Sizing with Object-Fit
impact: MEDIUM
impactDescription: prevents image overflow and maintains aspect ratio across breakpoints
tags: rmedia, images, object-fit, aspect-ratio, responsive
---

## Use Responsive Image Sizing with Object-Fit

Images with fixed `width` and `height` attributes overflow their containers on small screens — a 600px-wide image will cause horizontal scroll on any device narrower than that. Use `w-full` to make images fill their container, `object-cover` to maintain aspect ratio without letterboxing, and responsive height classes to give each breakpoint an appropriate crop. This lets the container dictate dimensions instead of the image dictating the layout.

**Incorrect (fixed dimensions that overflow on mobile):**

```html
<!-- 600px image overflows on a 375px screen, causing horizontal scrollbar -->
<article class="mx-auto max-w-3xl px-4">
  <h2 class="text-xl font-semibold text-gray-900">Mountain Retreat Getaway</h2>
  <p class="mt-2 text-gray-600">Escape to the peaks for a weekend of hiking and fresh air.</p>
  <img
    src="/retreat-hero.jpg"
    alt="Mountain cabin surrounded by pine trees"
    width="600"
    height="400"
  />
  <p class="mt-4 text-sm text-gray-500">Photo by Alex Rivera</p>
</article>
```

**Correct (fluid width with responsive height and object-fit):**

```html
<!-- Image fills container width, height adapts per breakpoint, object-cover prevents distortion -->
<article class="mx-auto max-w-3xl px-4">
  <h2 class="text-xl font-semibold text-gray-900">Mountain Retreat Getaway</h2>
  <p class="mt-2 text-gray-600">Escape to the peaks for a weekend of hiking and fresh air.</p>
  <img
    src="/retreat-hero.jpg"
    alt="Mountain cabin surrounded by pine trees"
    class="mt-4 w-full h-48 md:h-64 lg:h-80 object-cover rounded-lg"
  />
  <p class="mt-4 text-sm text-gray-500">Photo by Alex Rivera</p>
</article>
```

**Key principle:** Let the container control image width with `w-full`, use `object-cover` to preserve aspect ratio without distortion, and set explicit responsive heights (`h-48 md:h-64 lg:h-80`) so the image crop feels intentional at every screen size. Never rely on HTML `width`/`height` attributes for layout — those are for CLS prevention, not responsive sizing.
