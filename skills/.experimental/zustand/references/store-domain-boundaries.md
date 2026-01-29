---
title: Organize Stores by Feature Domain
impact: HIGH
impactDescription: improves code navigation, enables code splitting
tags: store, organization, domains, architecture
---

## Organize Stores by Feature Domain

Structure stores around feature domains rather than data types. This aligns with how teams work on features and enables better code splitting.

**Incorrect (organized by data type):**

```typescript
// stores/entities.ts - all entities in one place
const useEntitiesStore = create((set) => ({
  users: [],
  products: [],
  orders: [],
  // Hard to find what belongs where
}))

// stores/ui.ts - all UI state together
const useUIStore = create((set) => ({
  userModalOpen: false,
  productFilterVisible: false,
  checkoutStep: 0,
  // Unrelated concerns mixed
}))
```

**Correct (organized by feature domain):**

```typescript
// features/auth/store.ts
const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  login: (credentials) => { /* ... */ },
  logout: () => set({ user: null, isAuthenticated: false }),
}))

// features/catalog/store.ts
const useCatalogStore = create<CatalogState>((set) => ({
  products: [],
  filters: { category: null, priceRange: null },
  filterVisible: false,
  setFilters: (filters) => set({ filters }),
  toggleFilterVisible: () => set((s) => ({ filterVisible: !s.filterVisible })),
}))

// features/checkout/store.ts
const useCheckoutStore = create<CheckoutState>((set) => ({
  step: 0,
  shippingAddress: null,
  paymentMethod: null,
  nextStep: () => set((s) => ({ step: s.step + 1 })),
}))
```

**Benefits:**
- Feature teams own their stores
- Easy to code-split by feature
- Related state and actions colocated
- Clear boundaries between domains

Reference: [Zustand Documentation - Slices Pattern](https://zustand.docs.pmnd.rs/guides/slices-pattern)
