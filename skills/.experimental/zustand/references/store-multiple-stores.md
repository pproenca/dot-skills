---
title: Use Multiple Small Stores Instead of One Monolithic Store
impact: CRITICAL
impactDescription: reduces re-render scope, improves maintainability
tags: store, architecture, modularity, performance
---

## Use Multiple Small Stores Instead of One Monolithic Store

Unlike Redux, Zustand encourages multiple small stores instead of a single global store. Each store handles one domain, reducing subscription scope and preventing unrelated state changes from triggering re-renders.

**Incorrect (monolithic store):**

```typescript
const useStore = create<AppState>((set) => ({
  // User domain
  user: null,
  setUser: (user) => set({ user }),

  // Cart domain
  cartItems: [],
  addToCart: (item) => set((s) => ({ cartItems: [...s.cartItems, item] })),

  // UI domain
  sidebarOpen: false,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),

  // Theme domain
  theme: 'light',
  setTheme: (theme) => set({ theme }),
}))
// Any state change triggers re-renders in all subscribed components
```

**Correct (domain-specific stores):**

```typescript
const useUserStore = create<UserState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}))

const useCartStore = create<CartState>((set) => ({
  cartItems: [],
  addToCart: (item) => set((s) => ({ cartItems: [...s.cartItems, item] })),
}))

const useUIStore = create<UIState>((set) => ({
  sidebarOpen: false,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
}))

const useThemeStore = create<ThemeState>((set) => ({
  theme: 'light',
  setTheme: (theme) => set({ theme }),
}))
// Cart changes only affect components subscribed to useCartStore
```

**Benefits:**
- Smaller subscription scope means fewer unnecessary re-renders
- Easier to test and maintain isolated domains
- Better code splitting potential

Reference: [Working with Zustand - TkDodo](https://tkdodo.eu/blog/working-with-zustand)
