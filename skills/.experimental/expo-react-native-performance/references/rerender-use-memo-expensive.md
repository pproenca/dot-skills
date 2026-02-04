---
title: Memoize Expensive Computations with useMemo
impact: HIGH
impactDescription: prevents recalculation on every render
tags: rerender, useMemo, computation, memoization
---

## Memoize Expensive Computations with useMemo

Use `useMemo` to cache the result of expensive computations. Without memoization, computations run on every render, even when inputs haven't changed, blocking the JS thread.

**Incorrect (filters/sorts on every render):**

```typescript
// screens/TransactionList.tsx
export function TransactionList({ transactions, filter }: Props) {
  const [searchQuery, setSearchQuery] = useState('');

  // Runs on EVERY render, including unrelated state changes
  const filteredTransactions = transactions
    .filter((t) => t.category === filter)
    .filter((t) => t.description.includes(searchQuery))
    .sort((a, b) => b.date.getTime() - a.date.getTime());

  return <FlashList data={filteredTransactions} /* ... */ />;
}
```

**Correct (memoized until dependencies change):**

```typescript
// screens/TransactionList.tsx
export function TransactionList({ transactions, filter }: Props) {
  const [searchQuery, setSearchQuery] = useState('');

  const filteredTransactions = useMemo(() => {
    return transactions
      .filter((t) => t.category === filter)
      .filter((t) => t.description.includes(searchQuery))
      .sort((a, b) => b.date.getTime() - a.date.getTime());
  }, [transactions, filter, searchQuery]);

  return <FlashList data={filteredTransactions} /* ... */ />;
}
```

**When to use useMemo:**
- Array filtering/sorting with 100+ items
- Complex object transformations
- Heavy calculations (date parsing, formatting)

**When NOT to use:** Simple operations or operations that always depend on changing values.

Reference: [useMemo](https://react.dev/reference/react/useMemo)
