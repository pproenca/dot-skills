---
title: Use Stable Item Keys Across Paginated Pages
impact: MEDIUM
impactDescription: prevents full-list re-render on each new page
tags: feed, keys, pagination, react-keys, reconciliation
---

## Use Stable Item Keys Across Paginated Pages

In a paginated/infinite feed, every time a new page arrives the parent re-renders with a longer items array. If item keys are stable (`item.id`), React reconciles in O(N+1) — existing rows reuse their fibers, only the new ones mount. If keys are index-based (`key={i}`), every row "moves" when the array grows from prepending or when virtual indices shift, triggering a full unmount/remount of every visible row.

Mount/unmount cycles re-trigger effects (refetches), re-create child query subscriptions, and reset internal state (form inputs, scroll positions inside items). For high-frequency feeds, key instability is a silent 5-10× cost multiplier on scroll updates.

**Incorrect (index keys — entire list unmounts/remounts on new pages):**

```tsx
function Feed() {
  const { data } = useInfiniteQuery({/* ... */});
  const items = data?.pages.flatMap(p => p.items) ?? [];

  return items.map((item, i) => <FeedRow key={i} item={item} />);
  // After a "prepend new items" event, every existing row sees a different key
  // → every row remounts → every embedded useQuery refires → every form resets
}
```

**Correct (entity ID keys — stable across mutations):**

```tsx
function Feed() {
  const { data } = useInfiniteQuery({/* ... */});
  const items = data?.pages.flatMap(p => p.items) ?? [];

  return items.map(item => <FeedRow key={item.id} item={item} />);
  // Even when 5 new items are prepended, the existing rows keep their fibers
}
```

**For items without natural IDs (e.g., aggregated rows in a report):**

```tsx
// Generate a stable composite key on the data side, not in render
const itemsWithKeys = useMemo(
  () => items.map(item => ({ ...item, key: `${item.userId}-${item.date}` })),
  [items]
);

// In render:
itemsWithKeys.map(item => <Row key={item.key} item={item} />);
```

**De-duplicate items across pages (cursor pagination can produce repeats at page edges):**

```tsx
const items = useMemo(() => {
  const all = data?.pages.flatMap(p => p.items) ?? [];
  // Dedup by id, keep first occurrence
  const seen = new Set<string>();
  return all.filter(item => seen.has(item.id) ? false : (seen.add(item.id), true));
}, [data]);
```

**Symptoms of unstable keys (debug checklist):**
- Forms inside list items lose their input on every refresh
- Embedded queries refetch on every page load
- Animations restart on every parent update
- React DevTools shows mount/unmount on rows that visually stayed in place

**Don't use random IDs:** `key={Math.random()}` or `key={crypto.randomUUID()}` generated in render means every render produces new keys → every row remounts every render. This is the most extreme version of the bug.

Reference: [React — Keeping list items in order with key](https://react.dev/learn/rendering-lists#keeping-list-items-in-order-with-key)
