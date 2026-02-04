---
title: Memoize List Item Components
impact: CRITICAL
impactDescription: prevents re-render of unchanged items
tags: list, memo, react-memo, item-component
---

## Memoize List Item Components

Wrap list item components in `React.memo()` to prevent re-rendering when their props haven't changed. Without memoization, all visible items re-render whenever the parent component updates.

**Incorrect (item re-renders on every list update):**

```typescript
// components/ProductCard.tsx
interface ProductCardProps {
  product: Product;
  onPress: (id: string) => void;
}

export function ProductCard({ product, onPress }: ProductCardProps) {
  return (
    <Pressable onPress={() => onPress(product.id)}>
      <Image source={{ uri: product.imageUrl }} style={styles.image} />
      <Text>{product.name}</Text>
      <Text>${product.price}</Text>
    </Pressable>
  );
}
// Every card re-renders when any card changes
```

**Correct (memoized item only re-renders on prop change):**

```typescript
// components/ProductCard.tsx
interface ProductCardProps {
  product: Product;
  onPress: (id: string) => void;
}

export const ProductCard = memo(function ProductCard({
  product,
  onPress,
}: ProductCardProps) {
  return (
    <Pressable onPress={() => onPress(product.id)}>
      <Image source={{ uri: product.imageUrl }} style={styles.image} />
      <Text>{product.name}</Text>
      <Text>${product.price}</Text>
    </Pressable>
  );
});
// Only re-renders if product or onPress reference changes
```

**Important:** Ensure `onPress` is stable (use `useCallback`) or memo won't help since the function reference changes every render.

Reference: [React.memo](https://react.dev/reference/react/memo)
