---
title: Avoid key Prop Inside FlashList Items
impact: HIGH
impactDescription: preserves cell recycling, prevents performance degradation
tags: list, flashlist, key, recycling
---

## Avoid key Prop Inside FlashList Items

Using the `key` prop inside FlashList item components breaks cell recycling. FlashList needs to reuse component instances, but `key` forces React to create new instances.

**Incorrect (key breaks recycling):**

```typescript
import { FlashList } from '@shopify/flash-list'

function ProductList({ products }) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => (
        <View key={item.id}>  {/* Breaks recycling! */}
          <ProductImage key={`img-${item.id}`} uri={item.imageUrl} />
          <Text key={`name-${item.id}`}>{item.name}</Text>
          <Text key={`price-${item.id}`}>{item.price}</Text>
        </View>
      )}
      estimatedItemSize={120}
    />
  )
}
// FlashList falls back to FlatList behavior, losing performance benefits
```

**Correct (no key props inside items):**

```typescript
import { FlashList } from '@shopify/flash-list'

function ProductList({ products }) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => (
        <View>
          <ProductImage uri={item.imageUrl} />
          <Text>{item.name}</Text>
          <Text>{item.price}</Text>
        </View>
      )}
      keyExtractor={item => item.id}  // Use keyExtractor instead
      estimatedItemSize={120}
    />
  )
}
// Cell recycling works properly
```

**When mapping child arrays, use index (acceptable in recycled context):**

```typescript
function ProductCard({ product }) {
  return (
    <View>
      <Text>{product.name}</Text>
      {product.tags.map((tag, index) => (
        <Tag key={index} label={tag} />  // Index key OK for stable arrays
      ))}
    </View>
  )
}
```

**Note:** This rule is specific to FlashList. In regular React components and FlatList, keys are important for reconciliation.

Reference: [FlashList Performance Tips](https://shopify.github.io/flash-list/docs/fundamentals/performant-components)
