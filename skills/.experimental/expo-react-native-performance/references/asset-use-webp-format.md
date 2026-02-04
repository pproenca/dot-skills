---
title: Use WebP Format for Images
impact: MEDIUM-HIGH
impactDescription: 25-35% smaller than JPEG at same quality
tags: asset, webp, format, compression
---

## Use WebP Format for Images

WebP provides superior compression compared to JPEG and PNG while maintaining quality. Serve WebP images to reduce bandwidth and improve load times.

**Incorrect (using JPEG/PNG):**

```typescript
// assets/images.ts
export const images = {
  hero: require('./hero.jpg'),      // 450KB
  product: require('./product.png'), // 280KB
  background: require('./bg.jpg'),   // 320KB
};
// Total: 1050KB
```

**Correct (using WebP):**

```typescript
// assets/images.ts
export const images = {
  hero: require('./hero.webp'),      // 290KB (35% smaller)
  product: require('./product.webp'), // 180KB (36% smaller)
  background: require('./bg.webp'),   // 210KB (34% smaller)
};
// Total: 680KB (35% reduction)
```

**Converting existing images:**

```bash
# Using cwebp (install via Homebrew)
cwebp -q 80 input.jpg -o output.webp

# Batch convert with expo-optimize
npx expo-optimize ./assets
```

**For remote images:** Request WebP from CDN with `f_auto` or `auto=format` parameter.

**Compatibility:** WebP is supported on iOS 14+ and all Android versions. For older iOS, provide JPEG fallback.

Reference: [expo-optimize](https://www.npmjs.com/package/expo-optimize)
