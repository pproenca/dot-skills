---
title: Optimize Images with next/image Props
impact: LOW
impactDescription: Improves LCP by 100-500ms and eliminates Cumulative Layout Shift from images
tags: advanced, images, lcp, cls, core-web-vitals
---

## Optimize Images with next/image Props

Unoptimized images cause layout shifts when they load and delay Largest Contentful Paint. Using `next/image` with `priority` for above-the-fold images, `sizes` for responsive loading, and `placeholder` for perceived performance eliminates CLS and improves LCP scores.

**Incorrect (missing optimization props):**

```tsx
// components/ProductHero.tsx
import Image from 'next/image'

export function ProductHero({ product }: { product: Product }) {
  return (
    <div className="hero-banner">
      <Image
        src={product.heroImage}
        alt={product.name}
        width={1200}
        height={600}
        // Missing priority - LCP image loads with low priority
        // Missing sizes - downloads oversized image on mobile
      />
    </div>
  )
}
```

**Correct (optimized with priority, sizes, and placeholder):**

```tsx
// components/ProductHero.tsx
import Image from 'next/image'

export function ProductHero({ product }: { product: Product }) {
  return (
    <div className="hero-banner">
      <Image
        src={product.heroImage}
        alt={product.name}
        width={1200}
        height={600}
        priority // Preloads LCP image - improves LCP by 100-500ms
        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 80vw, 1200px"
        placeholder="blur"
        blurDataURL={product.heroImageBlur}
      />
    </div>
  )
}
```

**When to use each prop:**

| Prop | Use Case |
|------|----------|
| `priority` | Above-the-fold images, hero banners, LCP candidates |
| `sizes` | Responsive images that change size at breakpoints |
| `placeholder="blur"` | Large images where loading state is visible |
| `fill` | Images that should fill their container |

**Alternative (fill mode for responsive containers):**

```tsx
<div className="relative aspect-video">
  <Image
    src={product.heroImage}
    alt={product.name}
    fill
    sizes="(max-width: 768px) 100vw, 50vw"
    className="object-cover"
    priority
  />
</div>
```

Reference: [Image Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/images)
