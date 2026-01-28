---
title: Avoid Anonymous Functions in JSX
impact: MEDIUM
impactDescription: reduces function allocations per render
tags: render, anonymous-functions, jsx, optimization, memory
---

## Avoid Anonymous Functions in JSX

Anonymous functions in JSX are recreated on every render, causing unnecessary memory allocation and breaking memoization.

**Incorrect (anonymous functions in render):**

```tsx
function ProductCard({ product, onBuy, onSave }) {
  return (
    <View>
      <Text>{product.name}</Text>
      <Text>${product.price}</Text>

      {/* New function created every render */}
      <TouchableOpacity onPress={() => onBuy(product.id)}>
        <Text>Buy</Text>
      </TouchableOpacity>

      {/* New function created every render */}
      <TouchableOpacity onPress={() => onSave(product.id)}>
        <Text>Save</Text>
      </TouchableOpacity>

      {/* New function AND new object every render */}
      <View style={{ marginTop: 10 }}>
        <Text onPress={() => console.log(product)}>Details</Text>
      </View>
    </View>
  )
}
```

**Correct (stable function references):**

```tsx
const ProductCard = memo(function ProductCard({ product, onBuy, onSave }) {
  const handleBuy = useCallback(() => {
    onBuy(product.id)
  }, [product.id, onBuy])

  const handleSave = useCallback(() => {
    onSave(product.id)
  }, [product.id, onSave])

  const handleDetails = useCallback(() => {
    console.log(product)
  }, [product])

  return (
    <View>
      <Text>{product.name}</Text>
      <Text>${product.price}</Text>

      <TouchableOpacity onPress={handleBuy}>
        <Text>Buy</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={handleSave}>
        <Text>Save</Text>
      </TouchableOpacity>

      <View style={styles.detailsContainer}>
        <Text onPress={handleDetails}>Details</Text>
      </View>
    </View>
  )
})

const styles = StyleSheet.create({
  detailsContainer: { marginTop: 10 },
})
```

**For simple components without memoization needs:**

```tsx
// If the component is simple and not in a list,
// defining handlers inline is acceptable
function SimpleButton({ onPress, label }) {
  return (
    <TouchableOpacity onPress={onPress}>
      <Text>{label}</Text>
    </TouchableOpacity>
  )
}

// Usage - this is fine for occasional renders
<SimpleButton onPress={() => navigate('Settings')} label="Settings" />
```

**Extract event handlers to module level when possible:**

```tsx
// Module-level handlers for static behavior
const handlePressIn = () => {
  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)
}

function FeedbackButton({ onPress, children }) {
  return (
    <TouchableOpacity
      onPressIn={handlePressIn}  // Stable reference
      onPress={onPress}
    >
      {children}
    </TouchableOpacity>
  )
}
```

**Impact in lists:**

```tsx
// In a list of 100 items:
// - Anonymous functions: 100 new functions per render
// - useCallback: 100 stable references (unless deps change)

// Most impactful in FlatList renderItem
const renderItem = useCallback(({ item }) => (
  <ItemCard item={item} onPress={handlePress} />
), [handlePress])

<FlatList data={items} renderItem={renderItem} />
```

**When anonymous functions are OK:**
- One-off components not in lists
- Components that always re-render anyway
- Event handlers that need inline logic and aren't in hot paths

Reference: [React Native Performance](https://reactnative.dev/docs/performance)
