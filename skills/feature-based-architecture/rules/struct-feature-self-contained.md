---
title: Make Features Self-Contained
impact: CRITICAL
impactDescription: Enables independent deployment and parallel team development
tags: struct, isolation, self-contained, modularity
---

## Make Features Self-Contained

Each feature folder should contain everything needed to implement that feature. When a feature requires code from multiple places, it becomes entangled with other features and cannot evolve independently.

**Incorrect (scattered feature code):**

```typescript
// src/components/checkout/CheckoutForm.tsx
import { useCart } from '../../hooks/useCart';
import { validateCard } from '../../utils/validation';
import { CartSummary } from '../cart/CartSummary';
import { paymentApi } from '../../api/payment';

export function CheckoutForm() {
  const cart = useCart();
  // Feature depends on 4 different locations
}
```

**Correct (self-contained feature):**

```typescript
// src/features/checkout/components/CheckoutForm.tsx
import { useCart } from '../hooks/useCart';
import { validateCard } from '../utils/validation';
import { CartSummary } from '../components/CartSummary';
import { submitPayment } from '../api/submit-payment';

export function CheckoutForm() {
  const cart = useCart();
  // All imports are within the feature
}
```

**Feature folder structure:**

```
features/checkout/
├── api/
│   └── submit-payment.ts
├── components/
│   ├── CheckoutForm.tsx
│   └── CartSummary.tsx
├── hooks/
│   └── useCart.ts
├── utils/
│   └── validation.ts
└── index.ts
```

**When NOT to use this pattern:**
- Truly generic utilities (date formatting, string helpers) belong in `shared/`
- UI primitives (Button, Input) belong in `shared/components/`

Reference: [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)
