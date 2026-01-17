---
title: Scope State Stores to Features
impact: MEDIUM
impactDescription: Prevents global state coupling; enables feature-level state reset and testing
tags: state, stores, scope, feature
---

## Scope State Stores to Features

Each feature should own its state store. When state is global, features become coupled through shared state, making them impossible to develop, test, or remove independently.

**Incorrect (global monolithic store):**

```typescript
// src/stores/store.ts
export const useStore = create((set) => ({
  // User feature state
  user: null,
  userLoading: false,
  setUser: (user) => set({ user }),

  // Cart feature state
  cartItems: [],
  addToCart: (item) => set(s => ({ cartItems: [...s.cartItems, item] })),

  // Notification feature state
  notifications: [],
  addNotification: (n) => set(s => ({ notifications: [...s.notifications, n] })),

  // Everything mixed together - impossible to isolate
}));
```

**Correct (feature-scoped stores):**

```typescript
// src/features/user/stores/userStore.ts
export const useUserStore = create((set) => ({
  user: null,
  isLoading: false,
  setUser: (user) => set({ user }),
  clearUser: () => set({ user: null }),
}));

// src/features/cart/stores/cartStore.ts
export const useCartStore = create((set) => ({
  items: [],
  addItem: (item) => set(s => ({ items: [...s.items, item] })),
  removeItem: (id) => set(s => ({ items: s.items.filter(i => i.id !== id) })),
  clearCart: () => set({ items: [] }),
}));

// src/features/notification/stores/notificationStore.ts
export const useNotificationStore = create((set) => ({
  notifications: [],
  add: (n) => set(s => ({ notifications: [...s.notifications, n] })),
  dismiss: (id) => set(s => ({
    notifications: s.notifications.filter(n => n.id !== id),
  })),
}));
```

**Feature exposes store via public API:**

```typescript
// src/features/cart/index.ts
export { useCartStore } from './stores/cartStore';
export type { CartItem } from './types';

// Other features use the exported store
import { useCartStore } from '@/features/cart';
```

**Benefits:**
- Feature can be removed along with its store
- Tests can reset feature state independently
- Clear ownership of state

Reference: [Feature-Sliced Design](https://feature-sliced.design/)
