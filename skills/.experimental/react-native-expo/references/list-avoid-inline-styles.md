---
title: Avoid Inline Styles in List Items
impact: HIGH
impactDescription: reduces object allocations by N items × M renders
tags: list, styles, performance, stylesheet, optimization
---

## Avoid Inline Styles in List Items

Inline style objects are recreated on every render. In lists, this multiplies across all visible items.

**Incorrect (inline styles in list items):**

```tsx
function ProductList({ products }) {
  return (
    <FlatList
      data={products}
      renderItem={({ item }) => (
        <View style={{
          padding: 16,
          marginBottom: 8,
          backgroundColor: 'white',
          borderRadius: 8,
        }}>
          <Text style={{
            fontSize: 16,
            fontWeight: 'bold',
            color: '#333',
          }}>
            {item.name}
          </Text>
          <Text style={{
            fontSize: 14,
            color: item.inStock ? 'green' : 'red',  // Dynamic
          }}>
            {item.price}
          </Text>
        </View>
      )}
    />
  )
}
// Creates new style objects for every item on every render
```

**Correct (StyleSheet with conditional composition):**

```tsx
const ProductCard = memo(function ProductCard({ product }) {
  return (
    <View style={styles.card}>
      <Text style={styles.name}>{product.name}</Text>
      <Text style={[
        styles.price,
        product.inStock ? styles.inStock : styles.outOfStock
      ]}>
        {product.price}
      </Text>
    </View>
  )
})

const styles = StyleSheet.create({
  card: {
    padding: 16,
    marginBottom: 8,
    backgroundColor: 'white',
    borderRadius: 8,
  },
  name: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  price: {
    fontSize: 14,
  },
  inStock: {
    color: 'green',
  },
  outOfStock: {
    color: 'red',
  },
})
```

**For truly dynamic styles, memoize:**

```tsx
const ProductCard = memo(function ProductCard({ product }) {
  // Memoize dynamic styles
  const dynamicStyle = useMemo(() => ({
    backgroundColor: product.featured ? '#fffce6' : 'white',
    borderColor: product.featured ? '#ffd700' : '#eee',
  }), [product.featured])

  return (
    <View style={[styles.card, dynamicStyle]}>
      <Text style={styles.name}>{product.name}</Text>
    </View>
  )
})
```

**Style array composition pattern:**

```tsx
// Pre-define all possible style combinations
const styles = StyleSheet.create({
  base: { padding: 16 },
  selected: { backgroundColor: '#e3f2fd' },
  disabled: { opacity: 0.5 },
  error: { borderColor: 'red', borderWidth: 1 },
})

// Compose without creating new objects
function ListItem({ item, isSelected, isDisabled, hasError }) {
  return (
    <View style={[
      styles.base,
      isSelected && styles.selected,
      isDisabled && styles.disabled,
      hasError && styles.error,
    ]}>
      {/* content */}
    </View>
  )
}
// False values are ignored in style arrays
```

**Benefits:**
- StyleSheet.create optimizes styles at compile time
- No object allocation during render
- Styles are reused across all instances

Reference: [React Native StyleSheet](https://reactnative.dev/docs/stylesheet)
