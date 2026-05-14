---
title: Prefer Types Over Comments
impact: HIGH
impactDescription: eliminates stale-doc decay by promoting invariants to compiler-checked types
tags: doc, types, invariants, refactor-safety
---

## Prefer Types Over Comments

TypeScript types are checked by the compiler and renamed automatically by refactor tools; comments drift silently the moment code changes. Whenever a comment describes a constraint on a value (allowed strings, required shape, exclusive states), encode it as a type so the invariant cannot rot.

**Incorrect (comment carries the invariant, compiler doesn't):**

```tsx
// status must be one of: 'idle', 'loading', 'success', 'error'
// caller is responsible for not passing anything else
function setOrderStatus(orderId: string, status: string) {
  // Reader has to trust the comment AND remember to update it
  // when the team adds a 'cancelled' state next sprint.
  updateOrder(orderId, { status });
}

setOrderStatus('order_42', 'loadign'); // typo compiles fine
```

**Correct (the comment IS the type):**

```tsx
type OrderStatus = 'idle' | 'loading' | 'success' | 'error';

function setOrderStatus(orderId: string, status: OrderStatus) {
  // Reader gets autocomplete; rename of a status renames every call site;
  // typos fail at compile time, not in production at 3am.
  updateOrder(orderId, { status });
}

setOrderStatus('order_42', 'loadign'); // compile error
```

**When NOT to apply this pattern:**
- WHY-level rationale a type can never express ("we use `Map` here instead of a plain object because keys can be `symbol`s for tenant isolation").
- Legal / license headers and copyright notices required by policy.
- External constraints the compiler can't verify ("Stripe API rate-limits this endpoint at 100 RPS — batch above that").

**Why this matters:** A type-checked invariant survives refactors; a commented invariant survives only until the next merge.

Reference: [Clean Code, Chapter 4: Comments](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Matt Pocock on `as const` and literal types](https://www.totaltypescript.com/)
