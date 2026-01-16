---
title: Minimize Cumulative Layout Shift
impact: CRITICAL
impactDescription: CLS under 0.1 prevents frustrating misclicks
tags: cwv, cls, layout-shift, images, fonts
---

## Minimize Cumulative Layout Shift

CLS measures visual stability. Layout shifts cause users to click wrong elements, lose reading position, and perceive poor quality. Target CLS below 0.1.

**Incorrect (elements cause layout shifts):**

```html
<!-- Image without dimensions -->
<img src="product.jpg" alt="Product photo">
<!-- Content below shifts down when image loads -->

<!-- Late-loading ad slot -->
<div class="ad-container"></div>
<!-- Injects 300px tall ad, pushes content down -->

<!-- Font swap shifts text -->
<style>
  body { font-family: 'Custom Font', sans-serif; }
</style>
<!-- Text reflows when custom font loads -->
```

**Correct (stable layout reserved):**

```html
<!-- Explicit dimensions prevent shift -->
<img
  src="product.jpg"
  alt="Product photo"
  width="400"
  height="300"
  style="aspect-ratio: 4/3;"
>

<!-- Reserved space for ad -->
<div class="ad-container" style="min-height: 250px;">
  <!-- Ad loads into reserved space -->
</div>

<!-- Font with fallback metrics -->
<style>
  @font-face {
    font-family: 'Custom Font';
    src: url('custom.woff2') format('woff2');
    font-display: optional;
    size-adjust: 105%;
    ascent-override: 95%;
  }
</style>
<!-- Fallback font metrics match custom font -->
```

**CLS prevention strategies:**
- Always set width/height or aspect-ratio on images
- Reserve space for ads, embeds, and iframes
- Use `font-display: optional` or match fallback metrics
- Avoid inserting content above existing content

Reference: [web.dev CLS](https://web.dev/articles/cls)
