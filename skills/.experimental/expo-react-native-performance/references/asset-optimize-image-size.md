---
title: Request Appropriately Sized Images
impact: MEDIUM-HIGH
impactDescription: 50-90% bandwidth reduction
tags: asset, images, cdn, optimization
---

## Request Appropriately Sized Images

Loading full-resolution images for thumbnail displays wastes bandwidth and memory. Request images sized for their display dimensions using CDN resize parameters.

**Incorrect (full-size image for thumbnail):**

```typescript
// components/ProductCard.tsx
export function ProductCard({ product }: Props) {
  return (
    <View style={styles.card}>
      {/* 100×100 display, but downloading 2000×2000 original */}
      <Image
        source={{ uri: product.imageUrl }}
        style={{ width: 100, height: 100 }}
      />
      <Text>{product.name}</Text>
    </View>
  );
}
// Downloads 2MB image, displays at 100px, wastes bandwidth
```

**Correct (request thumbnail-sized image):**

```typescript
// utils/images.ts
export function getResizedImageUrl(url: string, width: number): string {
  // Cloudinary example
  return url.replace('/upload/', `/upload/w_${width},c_fill,f_auto/`);
  // Or imgix: `${url}?w=${width}&auto=format`
}

// components/ProductCard.tsx
export function ProductCard({ product }: Props) {
  const thumbnailUrl = getResizedImageUrl(product.imageUrl, 200);  // 2× for Retina

  return (
    <View style={styles.card}>
      <Image
        source={{ uri: thumbnailUrl }}
        style={{ width: 100, height: 100 }}
      />
      <Text>{product.name}</Text>
    </View>
  );
}
// Downloads 20KB thumbnail instead of 2MB original
```

**CDN resize services:** Cloudinary, imgix, Cloudflare Images, ImageKit

Reference: [Image Optimization](https://docs.imgix.com/en-US/getting-started/tutorials/responsive-design/rendering-images-in-react-native-faster-with-imgix)
