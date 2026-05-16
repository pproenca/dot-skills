---
title: Pick One Source of Truth; Derive the Rest
impact: HIGH
impactDescription: prevents two-state-sync bugs and eliminates parallel updates
tags: derive, state, single-source-of-truth
---

## Pick One Source of Truth; Derive the Rest

When two pieces of state must always agree (a selected item id and the selected item object, a list and its sorted version, a Date and its formatted string), one of them is the truth and the other is a *view*. Storing both means every write site must update both, every read site must trust both, and bugs of the form "the IDs disagree" become a permanent risk. Pick the smallest, most stable representation as the truth, and compute the others where they're needed.

**Incorrect (two pieces of state for one fact):**

```tsx
function ProductSelector({ products }: { products: Product[] }) {
  const [selectedId, setSelectedId]         = useState<string | null>(null);
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);

  const handleSelect = (id: string) => {
    setSelectedId(id);
    setSelectedProduct(products.find(p => p.id === id) ?? null);
    // Two setters. If you forget one (or get the order wrong, or products refetches
    // in between), they disagree. Bugs of the form "the id says X but the object is Y".
  };

  return <Details product={selectedProduct} />;
}
```

**Correct (one piece of state; the other is derived where used):**

```tsx
function ProductSelector({ products }: { products: Product[] }) {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const selectedProduct = selectedId ? products.find(p => p.id === selectedId) : null;

  return <Details product={selectedProduct} />;
  // selectedId is the truth. selectedProduct is computed on render.
  // When `products` refetches and changes shape, the derivation re-runs automatically.
}
```

**Choosing which side is the truth:**

| Pick the one that... | Example |
|----------------------|---------|
| Survives refetches/refreshes | Pick `selectedId`, not the object snapshot |
| Comes from the URL/route/persistence | Pick the URL query param over local state |
| Is the smallest stable token | Pick the id over the full record |
| The user actually interacts with | Pick the text the user typed, not the parsed value |

The other one is then a function of it.

**Other cases of two-truths trouble:**

- A `searchQuery` state and a `filteredResults` state — keep the query; derive the results in render or with a memoised function call.
- A list of items and a `selectedItemsSet` — pick one and derive the other (`selectedIds` is usually the stable choice; the array of selected objects is derived).
- A user object and a `userId` — almost always the id is the truth; the user is the derivation (refetched when stale).

**Symptoms of two-truth state:**

- Two `useState` calls that are always updated together in every handler.
- A `useEffect` that copies one piece of state to another.
- A bug pattern "X and Y disagree" or "X is stale relative to Y."
- Tests that assert both pieces in lockstep.

**When NOT to use this pattern:**

- The two pieces represent genuinely independent facts that *coincidentally* match in the simple case — keep them separate.
- The derivation is asynchronous (fetching the object given the id) — then the derivation is its own loading state, not free derivation. Use a query hook for that.

Reference: [React docs — Choosing the State Structure](https://react.dev/learn/choosing-the-state-structure#avoid-redundant-state)
