---
title: Memoize renderItem and List Item Components
impact: HIGH
impactDescription: prevents N re-renders on every scroll
tags: list, memo, renderItem, useCallback, optimization
---

## Memoize renderItem and List Item Components

Without memoization, every list item re-renders whenever the parent renders, causing jank during scroll.

**Incorrect (recreates function and components):**

```tsx
function ProductList({ products, onSelect }) {
  return (
    <FlatList
      data={products}
      // Anonymous function recreated every render
      renderItem={({ item }) => (
        <ProductCard
          product={item}
          // Inline handler recreated every render
          onPress={() => onSelect(item.id)}
        />
      )}
    />
  )
}

// ProductCard has no memo wrapper
function ProductCard({ product, onPress }) {
  return (
    <TouchableOpacity onPress={onPress}>
      <Text>{product.name}</Text>
      <Text>{product.price}</Text>
    </TouchableOpacity>
  )
}
// Every item re-renders on every parent render
```

**Correct (memoized function and components):**

```tsx
function ProductList({ products, onSelect }) {
  const renderItem = useCallback(({ item }) => (
    <ProductCard
      product={item}
      onSelect={onSelect}
    />
  ), [onSelect])

  const keyExtractor = useCallback((item) => item.id, [])

  return (
    <FlatList
      data={products}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
    />
  )
}

// Memoized component with stable props
const ProductCard = memo(function ProductCard({ product, onSelect }) {
  // Handler created once per item, not recreated on re-render
  const handlePress = useCallback(() => {
    onSelect(product.id)
  }, [product.id, onSelect])

  return (
    <TouchableOpacity onPress={handlePress}>
      <Text>{product.name}</Text>
      <Text>{product.price}</Text>
    </TouchableOpacity>
  )
})
```

**With extraData for dependent renders:**

```tsx
function SelectableList({ items, selectedId, onSelect }) {
  const renderItem = useCallback(({ item }) => (
    <SelectableItem
      item={item}
      isSelected={item.id === selectedId}
      onSelect={onSelect}
    />
  ), [selectedId, onSelect])

  return (
    <FlatList
      data={items}
      renderItem={renderItem}
      // extraData triggers re-render when selection changes
      extraData={selectedId}
    />
  )
}

const SelectableItem = memo(function SelectableItem({
  item,
  isSelected,
  onSelect
}) {
  const handlePress = useCallback(() => {
    onSelect(item.id)
  }, [item.id, onSelect])

  return (
    <TouchableOpacity
      onPress={handlePress}
      style={[styles.item, isSelected && styles.selected]}
    >
      <Text>{item.name}</Text>
    </TouchableOpacity>
  )
})
```

**Checklist for list optimization:**
- [ ] `renderItem` wrapped in `useCallback`
- [ ] `keyExtractor` wrapped in `useCallback`
- [ ] List item component wrapped in `memo`
- [ ] Event handlers use `useCallback` with stable deps
- [ ] `extraData` used when non-data state affects rendering

Reference: [React Native FlatList Optimization](https://reactnative.dev/docs/optimizing-flatlist-configuration)
