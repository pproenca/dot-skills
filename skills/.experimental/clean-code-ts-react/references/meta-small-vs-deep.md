---
title: Small Functions Lose to Deep Modules When Indirection Exceeds Comprehension
impact: MEDIUM
impactDescription: prevents shallow-module fragmentation
tags: meta, small-functions, deep-modules, ousterhout
---

## Small Functions Lose to Deep Modules When Indirection Exceeds Comprehension

Clean Code says "functions should be small." Ousterhout's *A Philosophy of Software Design* counters with **deep modules** — more functionality per interface, fewer interfaces overall. When extreme decomposition produces "shallow modules" (many tiny functions whose interfaces are nearly as large as their implementations), readers must hop across 8 files to follow one behavior. A single 25-line function with a clean top-down narrative often reads better.

**Incorrect (dogmatic small — atomized into ceremony):**

```tsx
// A 4-line operation decomposed into 5 functions in 5 files.
// Reading "what happens on checkout" requires opening all of them.

// checkout.ts
export function checkout(order: Order) {
  return runValidation(order);
}

// runValidation.ts
export function runValidation(order: Order) {
  return callValidationHelper(order);
}

// callValidationHelper.ts
export function callValidationHelper(order: Order) {
  return invokeRule(order);
}

// invokeRule.ts
export function invokeRule(order: Order) {
  return applyRule(order);
}

// applyRule.ts
export function applyRule(order: Order): ValidatedOrder {
  return { ...order, validatedAt: new Date() };
}
```

**Correct (balanced — one function, narrative top-down):**

```tsx
// One function. Reads top-to-bottom. Each section is a paragraph,
// each comment is a heading. Reader gets the whole story in one place.
export function checkout(order: Order): CheckoutResult {
  // 1. Validate inventory.
  const unavailable = order.items.filter((item) => !isInStock(item.sku));
  if (unavailable.length > 0) {
    return { ok: false, reason: 'out_of_stock', items: unavailable };
  }

  // 2. Charge the customer.
  const charge = chargeCard(order.paymentMethod, order.total);
  if (!charge.ok) {
    return { ok: false, reason: 'payment_failed', detail: charge.error };
  }

  // 3. Reserve inventory and emit confirmation.
  reserveItems(order.items);
  emitOrderPlaced(order, charge.id);

  return { ok: true, orderId: order.id, chargeId: charge.id };
}
```

**When NOT to apply this pattern:**
- When extracted helpers have INDEPENDENT value — called from multiple sites, each with a name that explains a concept worth naming.
- When the function genuinely doesn't fit on a screen (over ~40-50 lines) — at that size, decomposition usually IS the right move.
- When team conventions cap function size and the tooling/review process is built around it — follow the convention; consistency is its own value.

**Why this matters:** Clean Code's "small functions" rule and Ousterhout's "deep modules" rule are both about reducing cognitive load. Small wins when the helper names tell a clearer story than the inline code; deep wins when the inline code IS the clearer story.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Ousterhout — A Philosophy of Software Design (Ch. 4-5: Deep Modules)](https://web.stanford.edu/~ouster/cgi-bin/aposd.php)
