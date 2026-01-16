---
title: Avoid Inline Functions in List renderItem
impact: HIGH
impactDescription: prevents component recreation on every render
tags: list, renderItem, callbacks, memoization
---

## Avoid Inline Functions in List renderItem

Inline arrow functions in renderItem create new function instances on every parent render, causing all list items to re-render even when data hasn't changed.

**Incorrect (inline function recreated every render):**

```typescript
import { FlashList } from '@shopify/flash-list'

function ProductList({ products, onAddToCart }) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => (
        <ProductCard
          product={item}
          onAddToCart={() => onAddToCart(item.id)}  // New function every render
        />
      )}
      estimatedItemSize={120}
    />
  )
}
```

**Correct (stable callback references):**

```typescript
import { useCallback } from 'react'
import { FlashList } from '@shopify/flash-list'

function ProductList({ products, onAddToCart }) {
  const renderItem = useCallback(({ item }) => (
    <ProductCard
      product={item}
      productId={item.id}
      onAddToCart={onAddToCart}
    />
  ), [onAddToCart])

  return (
    <FlashList
      data={products}
      renderItem={renderItem}
      estimatedItemSize={120}
    />
  )
}

// ProductCard receives productId and calls onAddToCart(productId) internally
const ProductCard = memo(function ProductCard({ product, productId, onAddToCart }) {
  const handlePress = useCallback(() => {
    onAddToCart(productId)
  }, [productId, onAddToCart])

  return (
    <Pressable onPress={handlePress}>
      <Text>{product.name}</Text>
    </Pressable>
  )
})
```

**Alternative (extract to named component):**

```typescript
function ProductList({ products, onAddToCart }) {
  return (
    <FlashList
      data={products}
      renderItem={ProductCardRenderer}
      extraData={onAddToCart}
      estimatedItemSize={120}
    />
  )
}

const ProductCardRenderer = memo(({ item, extraData }) => (
  <ProductCard product={item} onAddToCart={extraData} />
))
```
