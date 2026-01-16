---
title: Optimize Largest Contentful Paint
impact: CRITICAL
impactDescription: LCP under 2.5s improves SEO rankings by 8-15%
tags: cwv, lcp, performance, loading, images
---

## Optimize Largest Contentful Paint

LCP measures how long the largest visible element takes to render. A slow LCP (over 2.5s) hurts SEO rankings and causes users to perceive the page as slow.

**Incorrect (blocking LCP element):**

```html
<head>
  <!-- Render-blocking CSS -->
  <link rel="stylesheet" href="all-styles.css">
  <!-- Blocking fonts -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto">
</head>
<body>
  <!-- Hero image without optimization -->
  <img src="hero-4k.jpg" alt="Hero banner">
  <!-- LCP element loads after all CSS and fonts -->
</body>
```

**Correct (prioritized LCP element):**

```html
<head>
  <!-- Preload LCP image -->
  <link rel="preload" as="image" href="hero-optimized.webp" fetchpriority="high">
  <!-- Critical CSS inlined -->
  <style>/* Above-fold styles */</style>
  <!-- Non-critical CSS deferred -->
  <link rel="stylesheet" href="styles.css" media="print" onload="this.media='all'">
</head>
<body>
  <!-- Optimized hero with explicit dimensions -->
  <img
    src="hero-optimized.webp"
    alt="Hero banner"
    width="1200"
    height="600"
    fetchpriority="high"
    decoding="async"
  >
  <!-- LCP element loads first, renders within 2.5s -->
</body>
```

**LCP optimization strategies:**
- Preload LCP images with `fetchpriority="high"`
- Use WebP/AVIF formats (30-50% smaller than JPEG)
- Inline critical CSS, defer non-critical styles
- Set explicit width/height to prevent layout shifts

Reference: [web.dev LCP](https://web.dev/articles/lcp)
