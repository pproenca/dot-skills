---
title: Compute What You Can Compute; Store Only What You Can't
impact: HIGH
impactDescription: eliminates state variables and the sync bugs they cause
tags: derive, state, react, computed
---

## Compute What You Can Compute; Store Only What You Can't

Every stored value is a promise to keep it in sync with every input that feeds it. When `fullName = firstName + ' ' + lastName` is held in its own variable, every place that updates `firstName` must also update `fullName` — or the bug is "the name doesn't refresh." The mental-model gap is that the engineer thinks of `fullName` as a *thing*, when it's really a *view of other things*. Computed values don't need storing; they need a getter, a memo, or just an inline expression.

**Incorrect (React component with redundant state for derived values):**

```tsx
function CartSummary({ items }: { items: CartItem[] }) {
  const [itemCount, setItemCount] = useState(0);
  const [subtotal, setSubtotal] = useState(0);
  const [hasItems, setHasItems] = useState(false);

  useEffect(() => {
    setItemCount(items.length);
    setSubtotal(items.reduce((s, it) => s + it.price * it.qty, 0));
    setHasItems(items.length > 0);
  }, [items]);
  // Three pieces of state and one effect — for values that are pure functions of `items`.
  // Every render now has stale-state-during-update risk. Bugs lurk in the gap between
  // when `items` changes and when the effect catches up.

  return <Footer count={itemCount} subtotal={subtotal} empty={!hasItems} />;
}
```

**Correct (no state at all — the values are just computed):**

```tsx
function CartSummary({ items }: { items: CartItem[] }) {
  const itemCount = items.length;
  const subtotal  = items.reduce((s, it) => s + it.price * it.qty, 0);
  const hasItems  = itemCount > 0;
  return <Footer count={itemCount} subtotal={subtotal} empty={!hasItems} />;
  // No useState. No useEffect. No stale-state window. Always correct on every render.
  // If `subtotal` is expensive, wrap it in useMemo. Don't promote it to state.
}
```

**Outside React — getters instead of fields:**

```typescript
// Incorrect:
class Invoice {
  items: LineItem[];
  total: number;  // updated by every method that mutates items
  itemCount: number;
  isEmpty: boolean;

  addItem(item: LineItem) {
    this.items.push(item);
    this.total += item.price * item.qty;
    this.itemCount++;
    this.isEmpty = false;
  }
  // Three writes per mutation. One missed write = inconsistent invoice.
}

// Correct:
class Invoice {
  items: LineItem[];

  get total()     { return this.items.reduce((s, it) => s + it.price * it.qty, 0); }
  get itemCount() { return this.items.length; }
  get isEmpty()   { return this.items.length === 0; }

  addItem(item: LineItem) { this.items.push(item); }
  // One source of truth. Derived values can never desync.
}
```

**Symptoms of "stored what could be computed":**

- A `useEffect` (or `componentDidUpdate`) whose only job is to copy one piece of state into another.
- A field on a class whose value is set every time another field changes.
- A "refresh" function that walks a list of state and updates each entry.
- A bug ticket of the form "X doesn't update when Y changes."
- Two pieces of state that are *always* a function of each other.

**When NOT to use this pattern:**

- The derivation is genuinely expensive and runs on every render — use `useMemo`/getter with memoisation, not state.
- The "derived" value is actually an independent input that the user can override — then it's not derived; it's its own state.
- You need to *capture* the value at a specific moment (a snapshot) — that's state, not derivation. Example: `[priceAtPurchase, setPriceAtPurchase]` records what the user agreed to pay even after the menu price changes. The current price would re-derive; the agreed price needs to be stored.

Reference: [React docs — You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
