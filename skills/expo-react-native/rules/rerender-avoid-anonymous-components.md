---
title: Avoid Anonymous Components in JSX
impact: MEDIUM
impactDescription: prevents component unmount/remount on every parent render
tags: rerender, anonymous, components, jsx
---

## Avoid Anonymous Components in JSX

Defining components inline within JSX creates new component types on every render, causing React to unmount and remount them instead of updating.

**Incorrect (anonymous component recreated each render):**

```typescript
function ProductPage({ productId }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <View>
      <ProductHeader productId={productId} />

      {/* Anonymous component - new type every render */}
      {(() => {
        const PriceDisplay = () => (
          <View>
            <Text>Price: ${calculatePrice(productId, quantity)}</Text>
          </View>
        )
        return <PriceDisplay />
      })()}

      <QuantitySelector value={quantity} onChange={setQuantity} />
    </View>
  )
}
// PriceDisplay unmounts and remounts on every quantity change
```

**Correct (named component outside render):**

```typescript
function PriceDisplay({ productId, quantity }) {
  const price = calculatePrice(productId, quantity)
  return (
    <View>
      <Text>Price: ${price}</Text>
    </View>
  )
}

function ProductPage({ productId }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <View>
      <ProductHeader productId={productId} />
      <PriceDisplay productId={productId} quantity={quantity} />
      <QuantitySelector value={quantity} onChange={setQuantity} />
    </View>
  )
}
// PriceDisplay updates in place, preserving state
```

**Also incorrect (component defined inside render):**

```typescript
function ProductPage({ productId }) {
  const [quantity, setQuantity] = useState(1)

  // Component defined inside - new type every render
  const PriceDisplay = () => (
    <Text>Price: ${calculatePrice(productId, quantity)}</Text>
  )

  return (
    <View>
      <PriceDisplay />  {/* Remounts on every render */}
    </View>
  )
}
```

**Correct alternatives:**

```typescript
// Option 1: Inline JSX (no component wrapper needed)
function ProductPage({ productId }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <View>
      <Text>Price: ${calculatePrice(productId, quantity)}</Text>
    </View>
  )
}

// Option 2: useMemo for expensive render (rare)
function ProductPage({ productId }) {
  const [quantity, setQuantity] = useState(1)

  const priceElement = useMemo(() => (
    <Text>Price: ${calculatePrice(productId, quantity)}</Text>
  ), [productId, quantity])

  return <View>{priceElement}</View>
}
```

**Signs of this anti-pattern:**
- Component state resets unexpectedly
- Animations restart on parent re-render
- Input fields lose focus when typing
