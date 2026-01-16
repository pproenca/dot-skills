---
title: Lazy Load Offscreen Images and Iframes
impact: CRITICAL
impactDescription: reduces initial page weight by 30-60%
tags: cwv, lazy-loading, images, performance, lcp
---

## Lazy Load Offscreen Images and Iframes

Loading all images upfront wastes bandwidth and delays LCP. Lazy loading defers offscreen resources until the user scrolls near them.

**Incorrect (all images load immediately):**

```html
<!-- All 50 product images load on page load -->
<div class="product-grid">
  <img src="product-1.jpg" alt="Product 1">
  <img src="product-2.jpg" alt="Product 2">
  <!-- ... 48 more images ... -->
  <img src="product-50.jpg" alt="Product 50">
</div>
<!-- 15MB of images downloaded before user can interact -->

<!-- YouTube embed loads 1MB+ immediately -->
<iframe src="https://youtube.com/embed/abc123"></iframe>
```

**Correct (lazy load below-fold content):**

```html
<!-- Above-fold hero loads immediately -->
<img
  src="hero.webp"
  alt="Featured product"
  fetchpriority="high"
>

<!-- Below-fold images lazy load -->
<div class="product-grid">
  <img src="product-1.jpg" alt="Product 1" loading="lazy">
  <img src="product-2.jpg" alt="Product 2" loading="lazy">
  <!-- Browser loads images as user scrolls -->
</div>

<!-- Lazy load iframe with facade -->
<lite-youtube videoid="abc123" playlabel="Play video">
  <button type="button" class="lty-playbtn">
    <span class="visually-hidden">Play video</span>
  </button>
</lite-youtube>
<!-- Loads ~300KB facade instead of 1MB+ YouTube embed -->
```

**Lazy loading guidelines:**
- Never lazy load LCP/above-fold images
- Use native `loading="lazy"` for broad support
- Replace heavy embeds (YouTube, maps) with facades
- Use IntersectionObserver for custom lazy loading

Reference: [web.dev Lazy Loading](https://web.dev/articles/lazy-loading-images)
