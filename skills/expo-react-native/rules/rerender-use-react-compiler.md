---
title: Enable React Compiler for Automatic Memoization
impact: MEDIUM
impactDescription: automatic useMemo/useCallback insertion, reduced manual optimization
tags: rerender, react-compiler, memoization, automation
---

## Enable React Compiler for Automatic Memoization

React Compiler automatically adds memoization to your components, eliminating the need for manual `useMemo`, `useCallback`, and `memo` in most cases.

**Incorrect (manual memoization everywhere):**

```typescript
const ProductCard = memo(function ProductCard({ product, onAddToCart }) {
  const formattedPrice = useMemo(
    () => formatCurrency(product.price),
    [product.price]
  )

  const handlePress = useCallback(
    () => onAddToCart(product.id),
    [product.id, onAddToCart]
  )

  return (
    <Pressable onPress={handlePress}>
      <Text>{product.name}</Text>
      <Text>{formattedPrice}</Text>
    </Pressable>
  )
})
```

**Correct (React Compiler handles optimization):**

```typescript
// With React Compiler enabled, write simple code
function ProductCard({ product, onAddToCart }) {
  const formattedPrice = formatCurrency(product.price)

  const handlePress = () => onAddToCart(product.id)

  return (
    <Pressable onPress={handlePress}>
      <Text>{product.name}</Text>
      <Text>{formattedPrice}</Text>
    </Pressable>
  )
}
// Compiler automatically adds memoization where beneficial
```

**Enable in Expo SDK 53+:**

```json
{
  "expo": {
    "experiments": {
      "reactCompiler": true
    }
  }
}
```

**Enable in Expo SDK 52 (manual setup):**

```bash
npx expo install babel-plugin-react-compiler
```

```javascript
// babel.config.js
module.exports = function (api) {
  api.cache(true)
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      ['babel-plugin-react-compiler', {}],
    ],
  }
}
```

**When manual memoization is still needed:**
- Expensive computations the compiler can't detect
- Third-party components requiring stable references
- useEffect with dependencies that shouldn't change

**Verify compiler is working:**

```bash
# Check compiled output
npx react-compiler-healthcheck
```

Reference: [React Compiler Documentation](https://react.dev/learn/react-compiler)
