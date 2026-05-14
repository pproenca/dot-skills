---
title: Apply the Four Rules of Simple Design in Order
impact: MEDIUM
impactDescription: Refactor toward simplicity without breaking behavior or clarity
tags: emerge, simple-design, refactor, priority
---

## Apply the Four Rules of Simple Design in Order

Kent Beck's four rules — (1) **Passes tests**, (2) **Reveals intent**, (3) **No duplication**, (4) **Fewest elements** — are a priority order, not a checklist. (1) is non-negotiable. (4) is fine only after (1)-(3) are already true. Skipping the order produces "elegant" code that's broken, or "DRY" code that nobody understands.

**Incorrect (collapsing duplication before intent is clear):**

```tsx
// Step 1: tests pass.
// Step 2: SKIPPED — names like `handle`, `process` reveal nothing.
// Step 3: extracted because the call sites looked similar.
// Result: a clever abstraction nobody can read or extend.
function handle<T>(items: T[], k: keyof T, p: (x: T) => boolean): T[] {
  return items.filter(p).sort((a, b) => (a[k] > b[k] ? 1 : -1));
}

const out = handle(orders, 'total', (o) => o.status === 'paid');
```

**Correct (reveal intent first, deduplicate only if concepts truly match):**

```tsx
// Rule 2 (intent) before Rule 3 (DRY).
// If a second use site appears with genuinely the same concept,
// THEN extract. Until then, this reads top-to-bottom.
function listPaidOrdersByTotal(orders: Order[]): Order[] {
  return orders
    .filter((order) => order.status === 'paid')
    .sort((a, b) => a.total - b.total);
}

const paidOrders = listPaidOrdersByTotal(orders);
```

**When NOT to apply this pattern:**
- Framework-shaped code where "fewest elements" competes with library conventions (Next.js route segments, React Server Component boundaries) — follow the framework's shape.
- Design-system primitives where the elements ARE the public API — splitting a `<Stack>` into `<Stack.Item>` is the contract, not over-decomposition.
- Prototypes and spikes — simple design is unfinished by definition; optimize when the design stabilizes.

**Why this matters:** The rules are ordered because they trade off. A premature collapse to "fewest elements" usually destroys "reveals intent" and breaks "passes tests" with edge cases the original code handled implicitly.

Reference: [Kent Beck — The Four Rules of Simple Design](https://martinfowler.com/bliki/BeckDesignRules.html), [Clean Code, Chapter 12: Emergence](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
