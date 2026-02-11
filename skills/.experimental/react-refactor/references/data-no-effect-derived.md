---
title: Avoid Effects for Derived or Computed Data
impact: MEDIUM
impactDescription: eliminates double-render cycle, prevents stale derived values
tags: data, derived-state, effects, performance
---

## Avoid Effects for Derived or Computed Data

Using useEffect to compute values from existing state or props causes a double render: one with stale derived data, then another after the effect updates. The user sees a flash of wrong content, and the extra render wastes CPU cycles. Values that can be computed from existing data should be calculated directly during render.

**Incorrect (effect for derived state — double render with stale value):**

```tsx
"use client";

import { useState, useEffect } from "react";

interface CartItem {
  productName: string;
  price: number;
  quantity: number;
  taxRate: number;
}

export function CartSummary({ cartItems }: { cartItems: CartItem[] }) {
  const [subtotal, setSubtotal] = useState(0);
  const [tax, setTax] = useState(0);
  const [total, setTotal] = useState(0);

  // First render shows $0.00 for all values, then effect fires and triggers re-render
  useEffect(() => {
    const newSubtotal = cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0);
    const newTax = cartItems.reduce((sum, item) => sum + item.price * item.quantity * item.taxRate, 0);
    setSubtotal(newSubtotal);
    setTax(newTax);
    setTotal(newSubtotal + newTax);
  }, [cartItems]);

  return (
    <div>
      <p>Subtotal: ${subtotal.toFixed(2)}</p>
      <p>Tax: ${tax.toFixed(2)}</p>
      <p>Total: ${total.toFixed(2)}</p>
    </div>
  );
}
```

**Correct (compute during render — always correct, one render):**

```tsx
"use client";

interface CartItem {
  productName: string;
  price: number;
  quantity: number;
  taxRate: number;
}

export function CartSummary({ cartItems }: { cartItems: CartItem[] }) {
  const subtotal = cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const tax = cartItems.reduce((sum, item) => sum + item.price * item.quantity * item.taxRate, 0);
  const total = subtotal + tax;

  return (
    <div>
      <p>Subtotal: ${subtotal.toFixed(2)}</p>
      <p>Tax: ${tax.toFixed(2)}</p>
      <p>Total: ${total.toFixed(2)}</p>
    </div>
  );
}
// Values are correct on the first render — no flash, no wasted cycle
```

Reference: [React Docs - You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
