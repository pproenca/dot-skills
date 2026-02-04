---
title: Prefetch Images Before Display
impact: MEDIUM-HIGH
impactDescription: 0ms display delay vs 200-500ms on demand
tags: asset, prefetch, caching, images
---

## Prefetch Images Before Display

Use `Image.prefetch()` to download images before they're needed. This enables instant display when the user navigates to a screen or scrolls to new content.

**Incorrect (images load when component mounts):**

```typescript
// screens/ProductDetails.tsx
export function ProductDetails({ productId }: Props) {
  const { data: product } = useQuery(['product', productId], fetchProduct);

  // Images start loading after component renders
  return (
    <ScrollView>
      {product?.images.map((img) => (
        <Image key={img.id} source={{ uri: img.url }} style={styles.image} />
      ))}
    </ScrollView>
  );
}
// User sees loading placeholders, then images pop in
```

**Correct (prefetch on hover/focus):**

```typescript
// components/ProductCard.tsx
import { Image } from 'expo-image';

export function ProductCard({ product, onPress }: Props) {
  const prefetchImages = useCallback(() => {
    product.images.forEach((img) => {
      Image.prefetch(img.url);
    });
  }, [product.images]);

  return (
    <Pressable
      onPress={onPress}
      onHoverIn={prefetchImages}
      onPressIn={prefetchImages}
    >
      <Image source={{ uri: product.thumbnailUrl }} style={styles.thumbnail} />
      <Text>{product.name}</Text>
    </Pressable>
  );
}
// Images already cached when user opens details
```

**Alternative:** Prefetch during list scroll using `onViewableItemsChanged`.

Reference: [expo-image prefetch](https://docs.expo.dev/versions/latest/sdk/image/#imageprefetch)
