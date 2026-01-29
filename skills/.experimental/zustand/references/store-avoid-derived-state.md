---
title: Derive Computed Values Instead of Storing Them
impact: HIGH
impactDescription: eliminates sync bugs, reduces state surface
tags: store, derived-state, selectors, computation
---

## Derive Computed Values Instead of Storing Them

Don't store values that can be computed from other state. Derived state creates synchronization problems and increases the chance of bugs. Use selectors to compute values on demand.

**Incorrect (storing derived state):**

```typescript
const useCartStore = create<CartState>((set) => ({
  items: [],
  itemCount: 0,      // Derived from items.length
  subtotal: 0,       // Derived from items
  tax: 0,            // Derived from subtotal
  total: 0,          // Derived from subtotal + tax

  addItem: (item) => set((s) => {
    const newItems = [...s.items, item]
    const subtotal = newItems.reduce((sum, i) => sum + i.price, 0)
    const tax = subtotal * 0.1
    // Must update 5 values, easy to miss one
    return {
      items: newItems,
      itemCount: newItems.length,
      subtotal,
      tax,
      total: subtotal + tax,
    }
  }),
}))
```

**Correct (compute values via selectors):**

```typescript
const useCartStore = create<CartState>((set) => ({
  items: [],
  taxRate: 0.1,

  addItem: (item) => set((s) => ({
    items: [...s.items, item],
  })),
}))

// Derive values with selectors
const useItemCount = () => useCartStore((s) => s.items.length)

const useSubtotal = () => useCartStore((s) =>
  s.items.reduce((sum, item) => sum + item.price, 0)
)

const useTotal = () => useCartStore((s) => {
  const subtotal = s.items.reduce((sum, item) => sum + item.price, 0)
  return subtotal + subtotal * s.taxRate
})
```

**When NOT to use this pattern:**
- Expensive computations that need memoization (use `useMemo` outside the store)
- Values needed for external subscriptions (React Query keys, etc.)

**Benefits:**
- Single source of truth
- No synchronization bugs
- Simpler actions

Reference: [Working with Zustand - TkDodo](https://tkdodo.eu/blog/working-with-zustand)
