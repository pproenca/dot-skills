---
title: Name Actions as Events Not Setters
impact: CRITICAL
impactDescription: encapsulates business logic, simplifies components
tags: store, actions, naming, encapsulation
---

## Name Actions as Events Not Setters

Name actions descriptively to represent what happened (events), not what state changed (setters). This encapsulates business logic within the store and makes the API more expressive.

**Incorrect (setter-style names):**

```typescript
const useCartStore = create<CartState>((set) => ({
  items: [],
  total: 0,

  // Setter names expose implementation details
  setItems: (items) => set({ items }),
  setTotal: (total) => set({ total }),

  // Component must calculate business logic
  addItem: (item) => set((s) => ({
    items: [...s.items, item],
    total: s.total + item.price,
  })),
}))

// Component handles logic
const handleAddToCart = (product) => {
  if (product.stock > 0) {
    addItem({ ...product, quantity: 1 })
  }
}
```

**Correct (event-style names):**

```typescript
const useCartStore = create<CartState>((set, get) => ({
  items: [],
  total: 0,

  // Event names describe what happened
  itemAddedToCart: (product: Product) => {
    if (product.stock <= 0) return

    set((s) => ({
      items: [...s.items, { ...product, quantity: 1 }],
      total: s.total + product.price,
    }))
  },

  itemRemovedFromCart: (productId: string) => {
    const item = get().items.find((i) => i.id === productId)
    if (!item) return

    set((s) => ({
      items: s.items.filter((i) => i.id !== productId),
      total: s.total - item.price * item.quantity,
    }))
  },

  cartCleared: () => set({ items: [], total: 0 }),
}))

// Component is simple
const handleAddToCart = (product) => {
  itemAddedToCart(product)
}
```

**Benefits:**
- Business logic encapsulated in store
- Components become thinner and easier to test
- Action names are self-documenting

Reference: [Redux Style Guide - Model Actions as Events](https://redux.js.org/style-guide/#model-actions-as-events-not-setters)
