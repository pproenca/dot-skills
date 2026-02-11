---
title: Import from Stable Public API Surfaces Only
impact: MEDIUM
impactDescription: enables internal refactoring without breaking consumers
tags: couple, public-api, encapsulation, imports
---

## Import from Stable Public API Surfaces Only

Reaching into a feature's internal file paths (e.g., `../../components/Button/utils`) couples consumers to private implementation details. Renaming or restructuring internal files breaks every deep import. Importing only from a feature's public `index.ts` creates a stable contract that allows internal changes without ripple effects.

**Incorrect (deep imports — coupled to internal file structure):**

```tsx
// Direct import of internal files — breaks if Button renames internals
import { Button } from "../../features/checkout/components/Button/Button";
import { formatCurrency } from "../../features/checkout/utils/formatCurrency";
import { useCartValidation } from "../../features/checkout/hooks/useCartValidation";
import type { CartItem } from "../../features/checkout/types/cart";

export function PaymentSummary({ cartItems }: { cartItems: CartItem[] }) {
  const { isValid, errors } = useCartValidation(cartItems);
  const total = cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0);

  return (
    <div>
      <p>{formatCurrency(total)}</p>
      {errors.map((err) => <p key={err}>{err}</p>)}
      <Button disabled={!isValid}>Pay Now</Button>
    </div>
  );
}
```

**Correct (public API imports — stable contract):**

```tsx
// features/checkout/index.ts — public API surface
export { Button } from "./components/Button/Button";
export { formatCurrency } from "./utils/formatCurrency";
export { useCartValidation } from "./hooks/useCartValidation";
export type { CartItem } from "./types/cart";

// Consumer imports from public API only
import { Button, formatCurrency, useCartValidation } from "@/features/checkout";
import type { CartItem } from "@/features/checkout";

export function PaymentSummary({ cartItems }: { cartItems: CartItem[] }) {
  const { isValid, errors } = useCartValidation(cartItems);
  const total = cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0);

  return (
    <div>
      <p>{formatCurrency(total)}</p>
      {errors.map((err) => <p key={err}>{err}</p>)}
      <Button disabled={!isValid}>Pay Now</Button>
    </div>
  );
}
// Internal renames (Button.tsx -> PrimaryButton.tsx) require no consumer changes
```

Reference: [Patterns.dev - Module Pattern](https://www.patterns.dev/react/module-pattern)
