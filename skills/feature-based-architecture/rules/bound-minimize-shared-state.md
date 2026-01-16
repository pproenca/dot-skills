---
title: Minimize Shared State Between Features
impact: HIGH
impactDescription: Reduces coupling surface area; prevents state synchronization bugs
tags: bound, state, coupling, shared
---

## Minimize Shared State Between Features

When multiple features share state, they become implicitly coupled. Changes to that state affect all dependent features. Prefer passing data as props or using feature-local state with explicit synchronization points.

**Incorrect (shared global state):**

```typescript
// src/stores/globalStore.ts
export const globalStore = create((set) => ({
  user: null,
  cart: { items: [] },
  notifications: [],
  theme: 'light',
  // Every feature reaches into this store
}));

// src/features/checkout/components/CheckoutForm.tsx
import { globalStore } from '@/stores/globalStore';

export function CheckoutForm() {
  const cart = globalStore(s => s.cart);
  const user = globalStore(s => s.user);
  // Checkout is now coupled to global store shape
}
```

**Correct (feature-scoped state with explicit boundaries):**

```typescript
// src/features/cart/stores/cartStore.ts
export const useCartStore = create((set) => ({
  items: [],
  addItem: (item) => set(s => ({ items: [...s.items, item] })),
  removeItem: (id) => set(s => ({ items: s.items.filter(i => i.id !== id) })),
}));

// src/features/cart/index.ts
export { useCartStore } from './stores/cartStore';
export type { CartItem } from './types';

// src/app/pages/CheckoutPage.tsx
import { useCartStore } from '@/features/cart';
import { CheckoutForm } from '@/features/checkout';

export function CheckoutPage() {
  const items = useCartStore(s => s.items);
  // App layer reads cart and passes to checkout
  return <CheckoutForm items={items} />;
}

// src/features/checkout/components/CheckoutForm.tsx
interface CheckoutFormProps {
  items: CartItem[];  // Receives data via props, not global state
}

export function CheckoutForm({ items }: CheckoutFormProps) {
  // No knowledge of cart store
}
```

**When shared state is acceptable:**
- Auth state (current user) - rarely changes, many features need it
- Theme/locale - application-wide concerns
- Feature flags - read-only, system-level

Reference: [Feature-Sliced Design](https://feature-sliced.design/)
