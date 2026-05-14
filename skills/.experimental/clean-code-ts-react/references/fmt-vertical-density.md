---
title: Keep Related Code Close, Unrelated Code Far
impact: HIGH
impactDescription: reduces eye-tracking and working-memory cost when reading a function
tags: fmt, vertical-distance, readability, locality
---

## Keep Related Code Close, Unrelated Code Far

Vertical distance between two related lines forces the reader's eye to track context across the file. Variables should be declared near where they are used; helpers should sit near their primary caller; unrelated blocks should be separated by blank lines. Prettier can't enforce this — it's a judgment about how a human reads top to bottom.

**Incorrect (related lines stretched apart by 40 lines):**

```tsx
function generateInvoice(order: Order) {
  let subtotal = 0;
  const lineItems: LineItem[] = [];
  const discounts: Discount[] = [];
  const taxes: Tax[] = [];

  // ... 30 lines processing line items, populating lineItems ...
  for (const item of order.items) {
    lineItems.push({ /* ... */ });
  }

  // ... 10 more lines unrelated to subtotal ...
  applyShipping(order);
  validateAddress(order.address);

  // Reader has to jump back to line 2 to remember `subtotal` exists.
  for (const item of lineItems) {
    subtotal += item.price * item.quantity;
  }

  return { subtotal, lineItems, discounts, taxes };
}
```

**Correct (declare `subtotal` immediately before the loop that uses it):**

```tsx
function generateInvoice(order: Order) {
  const lineItems: LineItem[] = [];
  const discounts: Discount[] = [];
  const taxes: Tax[] = [];

  for (const item of order.items) {
    lineItems.push({ /* ... */ });
  }

  applyShipping(order);
  validateAddress(order.address);

  // Declaration sits right next to its only use — no eye-jumping.
  let subtotal = 0;
  for (const item of lineItems) {
    subtotal += item.price * item.quantity;
  }

  return { subtotal, lineItems, discounts, taxes };
}
```

**When NOT to apply this pattern:**
- React function components: hooks must be at the top in stable order (Rules of Hooks), even if a `useState` is only read at the bottom of the JSX. The framework constraint wins.
- Team style guides that mandate "all variables declared at function top" — consistency across the codebase outweighs local optimization.
- Constants and configuration intentionally hoisted to the top of a module for visibility, even if only one function uses them.

**Why this matters:** Reading is the bottleneck of software maintenance. Vertical locality is one of the cheapest tools to reduce working memory load.

Reference: [Clean Code, Chapter 5: Formatting — Vertical Distance](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
