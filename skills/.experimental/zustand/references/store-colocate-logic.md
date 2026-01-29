---
title: Colocate Actions with the State They Modify
impact: HIGH
impactDescription: improves maintainability, reduces bugs
tags: store, actions, colocation, organization
---

## Colocate Actions with the State They Modify

Keep actions and the state they modify within the same store. This promotes encapsulation and makes it easier to understand how state is updated. Avoid cross-store mutations.

**Incorrect (cross-store mutations):**

```typescript
const useUserStore = create<UserState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}))

const useCartStore = create<CartState>((set) => ({
  items: [],
  userId: null,

  // Anti-pattern: modifying user store from cart store
  addItemAndUpdateUser: (item) => {
    set((s) => ({ items: [...s.items, item] }))
    useUserStore.getState().setUser({
      ...useUserStore.getState().user,
      lastActivity: Date.now(),
    })
  },
}))
```

**Correct (actions modify own state only):**

```typescript
const useUserStore = create<UserState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  updateLastActivity: () => set((s) => ({
    user: s.user ? { ...s.user, lastActivity: Date.now() } : null,
  })),
}))

const useCartStore = create<CartState>((set) => ({
  items: [],
  addItem: (item) => set((s) => ({ items: [...s.items, item] })),
}))

// Coordinate in component or custom hook
const useAddToCartWithActivity = () => {
  const addItem = useCartStore((s) => s.addItem)
  const updateLastActivity = useUserStore((s) => s.updateLastActivity)

  return (item: CartItem) => {
    addItem(item)
    updateLastActivity()
  }
}
```

**Benefits:**
- Each store is self-contained and testable
- Clear ownership of state mutations
- Easier to trace state changes

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
