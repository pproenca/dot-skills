---
title: Serve Responsive Images with srcset
impact: CRITICAL
impactDescription: reduces image payload by 40-70% on mobile
tags: cwv, images, srcset, responsive, performance
---

## Serve Responsive Images with srcset

Serving desktop-sized images to mobile devices wastes bandwidth and slows LCP. Use srcset and sizes to deliver appropriately-sized images for each viewport.

**Incorrect (one size for all devices):**

```html
<!-- 2000px image served to all devices -->
<img src="hero-2000.jpg" alt="Hero image">
<!-- Mobile users download 2MB when 200KB would suffice -->

<div style="background-image: url('banner-4k.jpg')"></div>
<!-- No responsive background image support -->
```

**Correct (responsive images with srcset):**

```html
<img
  src="hero-800.jpg"
  srcset="
    hero-400.jpg 400w,
    hero-800.jpg 800w,
    hero-1200.jpg 1200w,
    hero-2000.jpg 2000w
  "
  sizes="(max-width: 600px) 100vw,
         (max-width: 1200px) 50vw,
         800px"
  alt="Hero image"
  loading="lazy"
>
<!-- Browser selects optimal size based on viewport and DPR -->

<picture>
  <source
    media="(max-width: 600px)"
    srcset="banner-mobile.webp"
    type="image/webp"
  >
  <source
    srcset="banner-desktop.webp"
    type="image/webp"
  >
  <img src="banner-desktop.jpg" alt="Banner">
</picture>
<!-- Different crops for mobile vs desktop -->
```

**Responsive image guidelines:**
- Provide 3-5 image sizes spanning common viewports
- Use `sizes` attribute to hint expected display width
- Include WebP/AVIF sources with fallback
- Use `loading="lazy"` for below-fold images

Reference: [MDN Responsive Images](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images)
