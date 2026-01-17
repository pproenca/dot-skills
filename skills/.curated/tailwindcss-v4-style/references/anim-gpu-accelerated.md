---
title: Use GPU-Accelerated Transform Properties
impact: LOW-MEDIUM
impactDescription: 60fps animations, avoids layout thrashing
tags: anim, gpu, transform, performance, compositing
---

## Use GPU-Accelerated Transform Properties

Animate `transform` and `opacity` properties instead of layout-triggering properties like `width`, `height`, `top`, or `left`. GPU-accelerated properties don't trigger layout recalculation.

**Incorrect (layout-triggering animation):**

```html
<div class="transition-all duration-300 w-20 hover:w-40">
  <!-- Animating width triggers layout on every frame -->
</div>

<div class="absolute top-0 hover:top-10 transition-all">
  <!-- Animating top triggers layout recalculation -->
</div>
```

**Correct (GPU-accelerated animation):**

```html
<div class="transition-transform duration-300 scale-100 hover:scale-x-150">
  <!-- Transform is GPU-accelerated, no layout triggers -->
</div>

<div class="absolute transition-transform hover:translate-y-10">
  <!-- Translate is GPU-accelerated -->
</div>
```

**GPU-accelerated properties:**
- `transform` (translate, rotate, scale, skew)
- `opacity`
- `filter` (blur, brightness, etc.)

**Layout-triggering properties (avoid animating):**
- `width`, `height`
- `top`, `right`, `bottom`, `left`
- `margin`, `padding`
- `font-size`

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
