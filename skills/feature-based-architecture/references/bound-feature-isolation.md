---
title: Enforce Feature Isolation
impact: HIGH
impactDescription: Changes in one feature have zero impact on others; enables fearless refactoring
tags: bound, isolation, coupling, independence
---

## Enforce Feature Isolation

Each feature should be modifiable, testable, and deployable without affecting other features. When features are isolated, refactoring is safe and localized. When they're coupled, every change risks cascading failures.

**Incorrect (coupled features):**

```typescript
// src/features/order/hooks/useOrder.ts
import { useCart } from '@/features/cart/hooks/useCart';
import { useUser } from '@/features/user/hooks/useUser';
import { usePayment } from '@/features/payment/hooks/usePayment';

export function useOrder() {
  const cart = useCart();
  const user = useUser();
  const payment = usePayment();

  // Tightly coupled to 3 other features
  // Change in any feature can break orders
  async function submitOrder() {
    const order = {
      items: cart.items,
      userId: user.id,
      paymentMethod: payment.selectedMethod,
    };
    // ...
  }
}
```

**Correct (isolated with dependency injection):**

```typescript
// src/features/order/hooks/useOrder.ts
interface OrderDependencies {
  items: CartItem[];
  userId: string;
  paymentMethod: PaymentMethod;
}

export function useOrder() {
  async function submitOrder(deps: OrderDependencies) {
    const order = {
      items: deps.items,
      userId: deps.userId,
      paymentMethod: deps.paymentMethod,
    };
    // ...
  }

  return { submitOrder };
}

// src/app/pages/CheckoutPage.tsx - composition at app layer
import { useCart } from '@/features/cart';
import { useUser } from '@/features/user';
import { usePayment } from '@/features/payment';
import { useOrder } from '@/features/order';

export function CheckoutPage() {
  const cart = useCart();
  const user = useUser();
  const payment = usePayment();
  const order = useOrder();

  const handleSubmit = () => {
    order.submitOrder({
      items: cart.items,
      userId: user.id,
      paymentMethod: payment.selectedMethod,
    });
  };
}
```

**Benefits:**
- Order feature can be tested with mock dependencies
- Cart, user, and payment can change without breaking orders
- Clear contract between features

Reference: [Feature-Sliced Design](https://feature-sliced.design/)
