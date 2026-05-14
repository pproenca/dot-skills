---
title: Avoid Redundant Comments
impact: HIGH
impactDescription: removes noise that decays into lies when code changes
tags: doc, comments, noise, signal
---

## Avoid Redundant Comments

A comment that restates what the code already says adds noise and decays — when the code changes, the comment must change too, but rarely does. A wrong comment is worse than no comment: it actively misleads the reader who trusted it. Delete comments that paraphrase their own line.

**Incorrect (the comment says what the code says):**

```tsx
function CartSummary({ items }: { items: CartItem[] }) {
  // increment quantity by 1
  const incrementQuantity = (id: string) => {
    setItems((prev) =>
      prev.map((item) =>
        // if the item id matches, update quantity
        item.id === id ? { ...item, quantity: item.quantity + 1 } : item,
      ),
    );
  };

  /** Returns the total price of all items in the cart */
  const getTotalPrice = (): number =>
    items.reduce((sum, item) => sum + item.price * item.quantity, 0);

  return <div>{/* ... */}</div>;
}
```

**Correct (code speaks for itself; comments deleted):**

```tsx
function CartSummary({ items }: { items: CartItem[] }) {
  const incrementQuantity = (id: string) => {
    setItems((prev) =>
      prev.map((item) =>
        item.id === id ? { ...item, quantity: item.quantity + 1 } : item,
      ),
    );
  };

  const getTotalPrice = (): number =>
    items.reduce((sum, item) => sum + item.price * item.quantity, 0);

  return <div>{/* ... */}</div>;
}
```

**When NOT to apply this pattern:**
- Redundant-LOOKING comments that disambiguate a subtle convention (`// 0-indexed, NOT 1-indexed` on an `index` parameter; `// in cents, not dollars` on an `amount: number`).
- JSDoc on public API exports — IDE tooltips show the description at the call site, so even a near-paraphrase has value for consumers.
- Teaching codebases, tutorials, and onboarding examples where the audience is a learner, not a maintainer.

**Why this matters:** Every line a reader has to read costs attention. Spend that budget on signal, not paraphrase.

Reference: [Clean Code, Chapter 4: Comments — Noise Comments](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
