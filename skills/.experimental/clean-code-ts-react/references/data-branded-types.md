---
title: Brand Types to Make Domain Distinctions Compile-Checked
impact: MEDIUM-HIGH
impactDescription: turns argument-swap bugs into compile errors
tags: data, types, branded, nominal
---

## Brand Types to Make Domain Distinctions Compile-Checked

`type UserId = string` and `type OrderId = string` are interchangeable to TypeScript — pass one where the other is expected and the compiler shrugs. Branding (intersecting with a unique tag) makes them nominally distinct, so swaps become compile errors. A single factory function becomes the only legitimate way to construct one, which centralizes validation at the boundary.

**Incorrect (compiler can't catch argument swap):**

```ts
// Caller can swap arguments — both are strings. Silent runtime bug.
type UserId = string;
type OrderId = string;

function getOrder(userId: UserId, orderId: OrderId): Promise<Order> {
  return fetch(`/users/${userId}/orders/${orderId}`).then(r => r.json());
}

// Oops — swapped. Compiles fine, 404s at runtime (or worse, wrong order).
getOrder(order.id, user.id);
```

**Correct (swap is a compile error):**

```ts
// Same call site shape; compiler now refuses the swap.
type UserId = string & { readonly __brand: 'UserId' };
type OrderId = string & { readonly __brand: 'OrderId' };

const parseUserId = (s: string): UserId | null =>
  /^usr_[a-z0-9]+$/.test(s) ? (s as UserId) : null;
const parseOrderId = (s: string): OrderId | null =>
  /^ord_[a-z0-9]+$/.test(s) ? (s as OrderId) : null;

function getOrder(userId: UserId, orderId: OrderId): Promise<Order> {
  return fetch(`/users/${userId}/orders/${orderId}`).then(r => r.json());
}

getOrder(order.id, user.id); // Error: 'OrderId' is not assignable to 'UserId'
```

**When NOT to apply this pattern:**
- Throwaway scripts and small apps where the ceremony of factories and parsers exceeds the value of safety.
- Values that are genuinely just strings — a display name, a free-text comment — branding adds noise without invariant.
- Teams not bought in — branded types add friction everywhere they're used; one holdout doing `as UserId` defeats the purpose.

**Why this matters:** Naming with the compiler's help turns a documentation convention ("the first arg is a user id") into an enforced invariant — the same shift as discriminated unions, applied to scalars.

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Parse, Don't Validate — Alexis King](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)
