---
title: Use next/image for Automatic Optimization
impact: LOW-MEDIUM
impactDescription: Automatic WebP/AVIF conversion, lazy loading, and responsive sizing; reduces image payload by 30-70%
tags: advanced, images, optimization, Core-Web-Vitals
---

## Use next/image for Automatic Optimization

The `next/image` component automatically optimizes images: converting to modern formats (WebP, AVIF), lazy loading below-the-fold images, generating responsive sizes, and preventing Cumulative Layout Shift (CLS).

**Incorrect (regular img tag):**

```typescript
// ❌ No optimization
export default function Hero() {
  return (
    <img
      src="/hero.jpg"        // Original 2MB file served
      alt="Hero image"
      // No dimensions = CLS
      // No lazy loading = blocks render
      // No responsive sizes = mobile loads desktop image
    />
  )
}
```

**Correct (next/image):**

```typescript
import Image from 'next/image'

export default function Hero() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero image"
      width={1200}
      height={600}
      priority           // Preload LCP image
    />
  )
}
// Automatically:
// - Converts to WebP/AVIF
// - Serves correct size for device
// - Prevents layout shift (width/height reserved)
// - Lazy loads by default
```

**Responsive images:**

```typescript
import Image from 'next/image'

export default function ProductImage({ src, alt }) {
  return (
    <Image
      src={src}
      alt={alt}
      fill                    // Fill parent container
      sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
      className="object-cover"
    />
  )
}
// Generates srcset for different viewport sizes
```

**Priority for above-the-fold images:**

```typescript
// ❌ LCP image lazy loaded (delays paint)
<Image src="/hero.jpg" alt="Hero" width={1200} height={600} />

// ✓ LCP image preloaded
<Image src="/hero.jpg" alt="Hero" width={1200} height={600} priority />
```

**External images configuration:**

```javascript
// next.config.js
module.exports = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'cdn.example.com',
        pathname: '/images/**',
      },
      {
        protocol: 'https',
        hostname: '*.cloudinary.com',
      },
    ],
  },
}
```

**Placeholder for loading state:**

```typescript
import Image from 'next/image'

export default function ProductImage({ src, alt, blurDataURL }) {
  return (
    <Image
      src={src}
      alt={alt}
      width={400}
      height={400}
      placeholder="blur"
      blurDataURL={blurDataURL}  // Base64 blur placeholder
    />
  )
}
```

**When NOT to use next/image:**
- SVG icons (use inline SVG or `<img>`)
- Animated GIFs (optimization may break animation)
- Images that need CSS `background-image`

Reference: [Next.js Image Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/images)
