---
title: Define Explicit Interface Contracts
impact: HIGH
impactDescription: Prevents implicit dependencies; enables parallel feature development
tags: bound, interfaces, contracts, types
---

## Define Explicit Interface Contracts

When features need to interact, define explicit interfaces that describe the contract. This makes dependencies visible and allows features to be developed in parallel against the contract.

**Incorrect (implicit interface):**

```typescript
// src/features/checkout/components/CheckoutForm.tsx
export function CheckoutForm({ onSuccess }) {
  // What shape does onSuccess expect?
  // What data should be passed?
  const handleSubmit = () => {
    onSuccess(someData);  // Caller must guess the shape
  };
}
```

**Correct (explicit contract):**

```typescript
// src/features/checkout/types.ts
export interface CheckoutResult {
  orderId: string;
  total: number;
  items: Array<{ id: string; quantity: number }>;
}

export interface CheckoutFormProps {
  userId: string;
  cartItems: CartItem[];
  onSuccess: (result: CheckoutResult) => void;
  onError: (error: CheckoutError) => void;
}

// src/features/checkout/components/CheckoutForm.tsx
export function CheckoutForm({ userId, cartItems, onSuccess, onError }: CheckoutFormProps) {
  const handleSubmit = async () => {
    try {
      const result = await processCheckout(userId, cartItems);
      onSuccess({
        orderId: result.id,
        total: result.total,
        items: result.items.map(i => ({ id: i.id, quantity: i.qty })),
      });
    } catch (err) {
      onError(normalizeError(err));
    }
  };
}
```

**Contract patterns:**

```typescript
// Render prop contract
interface UserListProps {
  renderUser: (user: User) => ReactNode;
  renderEmpty?: () => ReactNode;
}

// Slot contract
interface DashboardProps {
  header: ReactNode;
  sidebar: ReactNode;
  content: ReactNode;
}

// Data contract
interface AnalyticsEvent {
  name: string;
  properties: Record<string, string | number | boolean>;
  timestamp: number;
}
```

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
