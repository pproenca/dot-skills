---
title: Implement Computed State with Getters
impact: LOW
impactDescription: enables derived values accessed via get()
tags: adv, computed, getters, derived-state
---

## Implement Computed State with Getters

For computed values that need to be accessed within actions, implement getter functions using `get()`. This keeps derived logic in the store while avoiding redundant state storage.

**Incorrect (stores computed values):**

```typescript
const useCartStore = create<CartState>((set) => ({
  items: [],
  subtotal: 0,      // Stored, must be kept in sync
  tax: 0,           // Stored, must be kept in sync
  total: 0,         // Stored, must be kept in sync

  addItem: (item) => set((s) => {
    const newItems = [...s.items, item]
    const subtotal = newItems.reduce((sum, i) => sum + i.price, 0)
    const tax = subtotal * 0.1
    // Must update all computed values manually
    return {
      items: newItems,
      subtotal,
      tax,
      total: subtotal + tax,
    }
  }),
}))
```

**Correct (computed getters):**

```typescript
const useCartStore = create<CartState>((set, get) => ({
  items: [],
  taxRate: 0.1,

  // Getters compute on demand
  getSubtotal: () => {
    return get().items.reduce((sum, item) => sum + item.price, 0)
  },

  getTax: () => {
    return get().getSubtotal() * get().taxRate
  },

  getTotal: () => {
    return get().getSubtotal() + get().getTax()
  },

  // Actions can use getters
  addItem: (item) => set((s) => ({
    items: [...s.items, item],
  })),

  canCheckout: () => {
    return get().items.length > 0 && get().getTotal() > 0
  },
}))

// Usage in components via selectors
function CartTotal() {
  const getTotal = useCartStore((s) => s.getTotal)
  return <span>Total: ${getTotal()}</span>
}
```

**Note:** Getters accessed via selectors don't trigger re-renders automatically. If you need reactive updates, select the underlying state instead:

```typescript
// This won't re-render when items change
const total = useCartStore((s) => s.getTotal())

// This will re-render when items change
const items = useCartStore((s) => s.items)
const total = useMemo(
  () => items.reduce((sum, i) => sum + i.price, 0),
  [items]
)
```

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
