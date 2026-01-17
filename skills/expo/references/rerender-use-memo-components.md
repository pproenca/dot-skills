---
title: Memoize Expensive Components with React.memo
impact: MEDIUM
impactDescription: prevents cascading re-renders from parent updates
tags: rerender, memo, optimization, components
---

## Memoize Expensive Components with React.memo

Wrap components that receive stable props in `React.memo()` to prevent re-renders when the parent component updates but the props haven't changed.

**Incorrect (re-renders on every parent update):**

```typescript
function ProductCard({ product, onAddToCart }) {
  return (
    <View style={styles.card}>
      <Image source={{ uri: product.imageUrl }} style={styles.image} />
      <Text style={styles.name}>{product.name}</Text>
      <Text style={styles.price}>${product.price}</Text>
      <Button title="Add to Cart" onPress={() => onAddToCart(product.id)} />
    </View>
  )
}

function ProductList({ products, cartCount }) {
  const handleAddToCart = useCallback((id) => addToCart(id), [])

  return (
    <View>
      <Text>Cart: {cartCount}</Text>  {/* Updates frequently */}
      {products.map(product => (
        <ProductCard
          key={product.id}
          product={product}
          onAddToCart={handleAddToCart}
        />  {/* All cards re-render when cartCount changes */}
      ))}
    </View>
  )
}
```

**Correct (memoized components skip re-renders):**

```typescript
const ProductCard = memo(function ProductCard({ product, onAddToCart }) {
  return (
    <View style={styles.card}>
      <Image source={{ uri: product.imageUrl }} style={styles.image} />
      <Text style={styles.name}>{product.name}</Text>
      <Text style={styles.price}>${product.price}</Text>
      <Button title="Add to Cart" onPress={() => onAddToCart(product.id)} />
    </View>
  )
})

function ProductList({ products, cartCount }) {
  const handleAddToCart = useCallback((id) => addToCart(id), [])

  return (
    <View>
      <Text>Cart: {cartCount}</Text>
      {products.map(product => (
        <ProductCard
          key={product.id}
          product={product}
          onAddToCart={handleAddToCart}  // Stable reference
        />  {/* Cards only re-render if product or callback changes */}
      ))}
    </View>
  )
}
```

**Custom comparison for complex props:**

```typescript
const ProductCard = memo(
  function ProductCard({ product, onAddToCart }) {
    // ... component body
  },
  (prevProps, nextProps) => {
    return prevProps.product.id === nextProps.product.id &&
           prevProps.product.price === nextProps.product.price
  }
)
```

**When to use memo:**
- List item components
- Components below frequently updating parents
- Components with expensive render logic
- Components receiving stable object/array props

**When NOT to use memo:**
- Components that always receive new props
- Very simple components (memo overhead > render cost)
- Components that need to always re-render

Reference: [React.memo Documentation](https://react.dev/reference/react/memo)
