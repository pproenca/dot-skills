---
title: Isolate Framework-Specific Code at the Edges
impact: MEDIUM-HIGH
impactDescription: keeps business logic testable and framework-agnostic
tags: bound, framework, separation, testability
---

## Isolate Framework-Specific Code at the Edges

Business logic that imports `react`, `next/navigation`, or `next-auth` is coupled to those framework versions and runtimes. Core logic should be plain TypeScript that returns plain values; let the edges (components, route handlers, server actions) translate between the framework and the core. The pure core is trivially testable, runs anywhere, and survives framework migrations.

**Incorrect (validation logic is secretly a React hook):**

```tsx
// validateCheckout calls useToast — now it's a hook, can't be tested
// without a renderer, can't run server-side, can't be reused outside React.
function validateCheckout(cart: Cart) {
  const toast = useToast();
  if (cart.items.length === 0) {
    toast.error('Cart is empty');
    return false;
  }
  if (cart.total < 0.01) {
    toast.error('Invalid total');
    return false;
  }
  return true;
}
```

**Correct (pure core; UI concerns live in the component):**

```tsx
// Pure: testable with `expect(validateCheckout(cart)).toEqual(...)`.
type ValidationResult =
  | { ok: true }
  | { ok: false; reason: 'empty' | 'invalid-total' };

function validateCheckout(cart: Cart): ValidationResult {
  if (cart.items.length === 0)   return { ok: false, reason: 'empty' };
  if (cart.total < 0.01)         return { ok: false, reason: 'invalid-total' };
  return { ok: true };
}

function CheckoutButton({ cart }: { cart: Cart }) {
  const toast = useToast();
  const onClick = () => {
    const result = validateCheckout(cart);
    if (!result.ok) toast.error(messageFor(result.reason));
    else submitOrder(cart);
  };
  return <button onClick={onClick}>Pay</button>;
}
```

**When NOT to apply this pattern:**
- Glue code whose entire job IS framework integration — an error boundary, a route layout, a server action wrapper.
- Small apps where the indirection costs more than it saves — there's no migration coming.
- When the framework primitive IS the right abstraction — a hook that wraps `useState` to add ergonomics SHOULD be a hook, not a pure function pretending otherwise.

**Why this matters:** Pure cores at the heart and framework-aware shells at the edges is the same separation that makes commands and queries, DTOs and domain types, testable functions and rendering — all easier to change independently.

Reference: [Clean Code, Chapter 8: Boundaries](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Clean Architecture — Robert C. Martin](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/)
