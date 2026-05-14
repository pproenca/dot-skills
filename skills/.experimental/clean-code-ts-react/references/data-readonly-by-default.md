---
title: Mark Read-Only Data Readonly
impact: MEDIUM-HIGH
impactDescription: prevents silent mutation that React won't detect
tags: data, immutability, readonly, react
---

## Mark Read-Only Data Readonly

Most data in TS+React is read-only by intent — props, hook return values, store snapshots. Marking it `readonly` documents intent AND makes accidental in-place mutation a compile error. This matters more in React than elsewhere because React diffs by reference: a mutated array keeps the same reference, so the UI silently fails to update.

**Incorrect (props can be mutated, breaking React's reference equality):**

```tsx
// CartSummary sorts in place; parent's state object is now mutated and
// React won't re-render dependent components reliably.
type CheckoutProps = {
  items: CartItem[];
  total: number;
};

function CartSummary({ items, total }: CheckoutProps) {
  items.sort((a, b) => a.price - b.price); // silently mutates parent state
  return <CartTable items={items} total={total} />;
}
```

**Correct (mutation becomes a compile error):**

```tsx
// .sort() on a readonly array is a type error — caller is forced to copy first.
type CheckoutProps = {
  readonly items: readonly CartItem[];
  readonly total: number;
};

function CartSummary({ items, total }: CheckoutProps) {
  const sorted = [...items].sort((a, b) => a.price - b.price); // explicit copy
  return <CartTable items={sorted} total={total} />;
}
```

**When NOT to apply this pattern:**
- Hot paths where `readonly` wrapper allocations measurably hurt performance — rare in app code, more relevant in tight loops in libraries.
- Internal helpers where mutation IS the operation — a builder pattern, a draft state, the inside of an Immer producer.
- Interop with libraries that take mutable types (older Redux Toolkit `createSlice` draft, some D3 APIs) — readonly there fights the library.

**Why this matters:** Immutability by default removes a class of "why didn't it re-render?" bugs and makes data flow easier to reason about — the same principle as preferring pure functions.

Reference: [Clean Code, Chapter 6: Objects and Data Structures](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [TypeScript Handbook: readonly](https://www.typescriptlang.org/docs/handbook/2/objects.html#readonly-properties)
