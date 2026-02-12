---
title: Use clamp() for Fluid Font Sizing
impact: HIGH
impactDescription: eliminates jumpy text resizing at breakpoints
tags: fluid, clamp, font-size, viewport-units, smooth-scaling
---

## Use clamp() for Fluid Font Sizing

Fixed font sizes with breakpoint overrides create jarring text jumps — at exactly 768px a heading snaps from one size to another in a single frame. `clamp()` produces smooth, continuous scaling between a minimum and maximum size based on the viewport width. In Tailwind v4, use arbitrary values with `clamp()` to eliminate every discrete size jump while still capping the range for readability on extremes.

**Incorrect (discrete size jumps at breakpoints):**

```html
<!-- Heading snaps from 1.5rem to 2.25rem at 768px and to 3.75rem at 1024px -->
<section class="px-4 py-12 md:px-8 lg:px-16">
  <h1 class="text-2xl font-bold md:text-4xl lg:text-6xl">
    Ship faster with fluid design
  </h1>
  <p class="mt-4 text-base text-gray-600 md:text-lg lg:text-xl">
    Our platform helps teams deliver responsive interfaces that look polished
    on every screen size — from phones to ultrawide monitors.
  </p>
</section>
```

**Correct (smooth scaling via clamp()):**

```html
<!-- Font scales continuously from 1.5rem at 320px to 3.75rem at 1280px — no jumps -->
<section class="px-4 py-12 md:px-8 lg:px-16">
  <h1 class="text-[clamp(1.5rem,1rem+2.5vw,3.75rem)] font-bold">
    Ship faster with fluid design
  </h1>
  <p class="mt-4 text-[clamp(1rem,0.875rem+0.625vw,1.25rem)] text-gray-600">
    Our platform helps teams deliver responsive interfaces that look polished
    on every screen size — from phones to ultrawide monitors.
  </p>
</section>
```

**Key principle:** The `clamp(min, preferred, max)` formula uses a viewport-relative middle value (e.g., `1rem + 2.5vw`) to create a linear scaling curve. The min and max cap the range so text never becomes too small on phones or absurdly large on ultrawides. Calculate the preferred value based on the viewport range where you want the transition to happen.
