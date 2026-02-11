---
title: Derive State Instead of Syncing for Zero Extra Renders
impact: MEDIUM-HIGH
impactDescription: eliminates double-render cycle, 1 render instead of 2 per update
tags: sub, derived-state, useEffect, render-cycle
---

## Derive State Instead of Syncing for Zero Extra Renders

Using useEffect to synchronize derived state from props or other state causes a double-render cycle: the first render uses stale derived state, then the effect fires and sets state again, triggering a second render. Computing the derived value directly during render produces the correct result in a single pass.

**Incorrect (useEffect sync causes double render per update):**

```tsx
interface CartItem {
  id: string
  name: string
  price: number
  quantity: number
}

function CartSummary({ cartItems }: { cartItems: CartItem[] }) {
  const [totalPrice, setTotalPrice] = useState(0)
  const [itemCount, setItemCount] = useState(0)
  const [hasExpensiveItem, setHasExpensiveItem] = useState(false)

  useEffect(() => {
    // Fires after render, triggers a second render with updated values
    setTotalPrice(cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0))
    setItemCount(cartItems.reduce((sum, item) => sum + item.quantity, 0))
    setHasExpensiveItem(cartItems.some((item) => item.price > 100))
  }, [cartItems])

  return (
    <div>
      <p>{itemCount} items — ${totalPrice.toFixed(2)}</p>
      {hasExpensiveItem && <span className="badge">Premium items in cart</span>}
    </div>
  )
}
```

**Correct (derived during render, single render cycle):**

```tsx
interface CartItem {
  id: string
  name: string
  price: number
  quantity: number
}

function CartSummary({ cartItems }: { cartItems: CartItem[] }) {
  const totalPrice = cartItems.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  )
  const itemCount = cartItems.reduce((sum, item) => sum + item.quantity, 0)
  const hasExpensiveItem = cartItems.some((item) => item.price > 100)

  return (
    <div>
      <p>{itemCount} items — ${totalPrice.toFixed(2)}</p>
      {hasExpensiveItem && <span className="badge">Premium items in cart</span>}
    </div>
  )
}
```

Reference: [React Docs — You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
