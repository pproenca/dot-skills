---
title: Optimize Images with Responsive Sizing and Lazy Loading
impact: HIGH
impactDescription: 40-70% image bandwidth reduction
tags: cwv, images, srcset, lazy-loading, responsive
---

## Optimize Images with Responsive Sizing and Lazy Loading

Serving a single full-resolution image to all devices wastes bandwidth on mobile and delays Time to Interactive. Responsive `srcset` delivers appropriately sized images per viewport, and `loading="lazy"` defers offscreen images until the user scrolls near them.

**Incorrect (single oversized image loaded eagerly for all devices):**

```tsx
function PropertyGallery({ images }: { images: PropertyImage[] }) {
  return (
    <div className="gallery-grid">
      {images.map((image) => (
        <img
          key={image.id}
          src={image.originalUrl} // 4000x3000 image served to 375px mobile viewport
          alt={image.caption}
          className="gallery-image"
        />
      ))}
    </div>
  )
}
```

**Correct (responsive srcset with lazy loading for offscreen images):**

```tsx
function PropertyGallery({ images }: { images: PropertyImage[] }) {
  return (
    <div className="gallery-grid">
      {images.map((image, index) => (
        <img
          key={image.id}
          src={image.sizes.medium}
          srcSet={`
            ${image.sizes.small} 400w,
            ${image.sizes.medium} 800w,
            ${image.sizes.large} 1200w,
            ${image.sizes.xlarge} 2000w
          `}
          sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
          alt={image.caption}
          loading={index < 4 ? "eager" : "lazy"} // first 4 images load immediately
          decoding="async"
          className="gallery-image"
        />
      ))}
    </div>
  )
}

interface PropertyImage {
  id: string
  caption: string
  originalUrl: string
  sizes: {
    small: string   // 400px wide
    medium: string  // 800px wide
    large: string   // 1200px wide
    xlarge: string  // 2000px wide
  }
}
```

Reference: [web.dev — Responsive Images](https://web.dev/articles/responsive-images)
