---
title: Reset Feature State on Unmount
impact: MEDIUM
impactDescription: Prevents stale state bugs; ensures clean feature initialization
tags: state, reset, cleanup, unmount
---

## Reset Feature State on Unmount

When a feature unmounts, reset its state to prevent stale data from appearing when the feature remounts. Persistent stores can cause bugs when users navigate away and back.

**Incorrect (stale state persists):**

```typescript
// User views checkout, abandons, browses, returns to checkout
// Sees old form data from previous session
const useCheckoutStore = create((set) => ({
  shippingAddress: null,
  paymentMethod: null,
  setShipping: (addr) => set({ shippingAddress: addr }),
}));

function CheckoutPage() {
  const { shippingAddress } = useCheckoutStore();
  // shippingAddress still has old data from previous visit
  return <CheckoutForm defaultAddress={shippingAddress} />;
}
```

**Correct (reset on unmount):**

```typescript
// src/features/checkout/stores/checkoutStore.ts
const initialState = {
  shippingAddress: null,
  paymentMethod: null,
  step: 1,
};

export const useCheckoutStore = create((set) => ({
  ...initialState,
  setShipping: (addr) => set({ shippingAddress: addr }),
  setPayment: (method) => set({ paymentMethod: method }),
  nextStep: () => set(s => ({ step: s.step + 1 })),
  reset: () => set(initialState),
}));

// src/features/checkout/components/CheckoutPage.tsx
function CheckoutPage() {
  const reset = useCheckoutStore(s => s.reset);

  useEffect(() => {
    // Reset when leaving checkout
    return () => reset();
  }, [reset]);

  return <CheckoutForm />;
}
```

**Alternative: Feature-scoped store instance:**

```typescript
// src/features/checkout/CheckoutProvider.tsx
const CheckoutContext = createContext<CheckoutStore | null>(null);

export function CheckoutProvider({ children }) {
  // New store instance created each mount
  const storeRef = useRef<CheckoutStore>();
  if (!storeRef.current) {
    storeRef.current = createCheckoutStore();
  }

  return (
    <CheckoutContext.Provider value={storeRef.current}>
      {children}
    </CheckoutContext.Provider>
  );
}

// Store is automatically fresh on each mount
```

**When NOT to reset:**
- User preferences (theme, language)
- Draft content (auto-saved forms)
- Explicitly preserved state (shopping cart)

Reference: [Zustand - Resetting State](https://zustand-demo.pmnd.rs/)
