---
title: Enable React Compiler for Automatic Memoization
impact: MEDIUM
impactDescription: eliminates manual memo/useMemo/useCallback
tags: render, react-compiler, memoization, expo, automatic
---

## Enable React Compiler for Automatic Memoization

React Compiler automatically adds memoization, eliminating the need for manual memo(), useMemo(), and useCallback().

**Incorrect (manual memoization everywhere):**

```tsx
// Manual memoization is tedious and error-prone
const ProductCard = memo(function ProductCard({ product, onBuy }) {
  const formattedPrice = useMemo(() => {
    return formatCurrency(product.price)
  }, [product.price])

  const handleBuy = useCallback(() => {
    onBuy(product.id)
  }, [product.id, onBuy])

  return (
    <View>
      <Text>{product.name}</Text>
      <Text>{formattedPrice}</Text>
      <Button onPress={handleBuy} title="Buy" />
    </View>
  )
})
```

**Correct (React Compiler handles it):**

```json
// app.json - enable React Compiler (Expo SDK 54+)
{
  "expo": {
    "experiments": {
      "reactCompiler": true
    }
  }
}
```

```tsx
// Clean code - compiler adds memoization automatically
function ProductCard({ product, onBuy }) {
  const formattedPrice = formatCurrency(product.price)

  const handleBuy = () => {
    onBuy(product.id)
  }

  return (
    <View>
      <Text>{product.name}</Text>
      <Text>{formattedPrice}</Text>
      <Button onPress={handleBuy} title="Buy" />
    </View>
  )
}
// Compiler automatically memoizes components, values, and callbacks
```

**Verify compiler is working:**

```tsx
// In development, check for compiler output
// Components should show memoization in React DevTools

// You can also check the compiled output
// npx expo export --dump-sourcemap
```

**Gradual migration approach:**

```tsx
// Start with React Compiler, remove manual memoization gradually
// The compiler handles conflicts gracefully

// Step 1: Enable compiler
// Step 2: New code doesn't need manual memoization
// Step 3: Gradually remove memo/useMemo/useCallback from existing code
```

**When manual memoization is still useful:**

```tsx
// Custom comparison logic still needs memo()
const ExpensiveItem = memo(
  function ExpensiveItem({ item }) {
    return <ComplexView item={item} />
  },
  (prev, next) => prev.item.id === next.item.id  // Custom comparison
)

// Very expensive computations may benefit from explicit useMemo
const sortedData = useMemo(() => {
  console.log('Sorting 10000 items...')  // Log shows when it runs
  return heavySort(data)
}, [data])
```

**Requirements:**
- Expo SDK 54 or later
- React 19 or experimental React with compiler
- Code must follow React rules (pure components, hooks rules)

**Benefits:**
- Cleaner code
- Fewer bugs from incorrect dependencies
- Automatic optimization for all components
- No performance overhead from unnecessary memoization

Reference: [React Compiler Documentation](https://react.dev/learn/react-compiler)
