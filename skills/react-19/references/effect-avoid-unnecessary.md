---
title: Avoid Effects for Derived State and User Events
impact: MEDIUM
impactDescription: eliminates sync bugs, simpler code
tags: effect, unnecessary, derived-state, events
---

## Avoid Effects for Derived State and User Events

Effects synchronize with external systems. Don't use them for: updating state based on props/state, or handling user events.

**Incorrect (effect for derived state):**

```typescript
function Form() {
  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')
  const [fullName, setFullName] = useState('')

  useEffect(() => {
    setFullName(`${firstName} ${lastName}`)
  }, [firstName, lastName])
  // Extra render, potential sync bugs

  return <input value={fullName} disabled />
}
```

**Correct (calculate during render):**

```typescript
function Form() {
  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')

  // Calculate during render - always in sync
  const fullName = `${firstName} ${lastName}`

  return <input value={fullName} disabled />
}
```

**Incorrect (effect for user event):**

```typescript
function BuyButton({ product }) {
  useEffect(() => {
    // ❌ Analytics for user action in effect
    if (product.wasAddedToCart) {
      trackPurchase(product)
    }
  }, [product])
}
```

**Correct (handle in event handler):**

```typescript
function BuyButton({ product }) {
  function handleClick() {
    addToCart(product)
    trackPurchase(product)  // ✅ In event handler
  }

  return <button onClick={handleClick}>Buy</button>
}
```

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
