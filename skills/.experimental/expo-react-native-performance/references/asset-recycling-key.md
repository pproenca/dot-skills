---
title: Use recyclingKey in FlashList Images
impact: MEDIUM-HIGH
impactDescription: prevents stale image display in recycled cells
tags: asset, flashlist, recycling, images
---

## Use recyclingKey in FlashList Images

FlashList recycles views, which can cause the previous image to flash before the new one loads. Use `recyclingKey` to ensure images update immediately when cells are recycled.

**Incorrect (stale images flash in recycled cells):**

```typescript
// components/ProductCard.tsx
export function ProductCard({ product }: Props) {
  return (
    <View style={styles.card}>
      <Image
        source={{ uri: product.imageUrl }}
        style={styles.image}
      />
      <Text>{product.name}</Text>
    </View>
  );
}
// When scrolling fast, old product image shows briefly before new one loads
```

**Correct (recyclingKey prevents stale images):**

```typescript
// components/ProductCard.tsx
import { Image } from 'expo-image';

export function ProductCard({ product }: Props) {
  return (
    <View style={styles.card}>
      <Image
        source={{ uri: product.imageUrl }}
        recyclingKey={product.id}
        placeholder={product.blurhash}
        style={styles.image}
      />
      <Text>{product.name}</Text>
    </View>
  );
}
// Image clears immediately when cell is recycled, shows placeholder
```

**How it works:**
- `recyclingKey` tells expo-image when the source has changed
- When key changes, image immediately shows placeholder instead of stale content
- Combined with BlurHash, provides smooth visual experience

Reference: [expo-image recyclingKey](https://docs.expo.dev/versions/latest/sdk/image/#recyclingkey)
