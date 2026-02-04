---
title: Reduce Android Overdraw
impact: LOW-MEDIUM
impactDescription: 20-30% rendering improvement on Android
tags: platform, android, overdraw, rendering
---

## Reduce Android Overdraw

Overdraw occurs when the same pixel is drawn multiple times per frame. On Android, excessive overdraw significantly impacts performance. Remove unnecessary backgrounds and flatten view hierarchies.

**Incorrect (multiple overlapping backgrounds):**

```typescript
// components/ProductCard.tsx
export function ProductCard({ product }: Props) {
  return (
    <View style={{ backgroundColor: 'white' }}>
      <View style={{ backgroundColor: 'white', padding: 16 }}>
        <View style={{ backgroundColor: '#f5f5f5', borderRadius: 8 }}>
          <Image source={{ uri: product.image }} style={styles.image} />
        </View>
        <View style={{ backgroundColor: 'white' }}>
          <Text>{product.name}</Text>
        </View>
      </View>
    </View>
  );
}
// Same pixels painted 3-4 times per frame
```

**Correct (single background, flat hierarchy):**

```typescript
// components/ProductCard.tsx
export function ProductCard({ product }: Props) {
  return (
    <View style={styles.card}>
      <Image source={{ uri: product.image }} style={styles.image} />
      <Text style={styles.name}>{product.name}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: 'white',
    padding: 16,
    borderRadius: 8,
  },
  image: { /* ... */ },
  name: { /* ... */ },
});
// Each pixel painted only once
```

**Debug overdraw on Android:**
1. Developer Options > Debug GPU Overdraw
2. Blue = 1× overdraw, Green = 2×, Pink = 3×, Red = 4×
3. Target: mostly blue with minimal green

Reference: [Android Overdraw](https://developer.android.com/topic/performance/rendering/overdraw)
