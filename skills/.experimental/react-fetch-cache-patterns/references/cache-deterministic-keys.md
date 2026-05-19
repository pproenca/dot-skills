---
title: Build Deterministic Cache Keys
impact: CRITICAL
impactDescription: prevents accidental cache misses on every render
tags: cache, keys, deduplication, serialization
---

## Build Deterministic Cache Keys

Cache keys are compared structurally. `{ id: 1, type: 'A' }` and `{ type: 'A', id: 1 }` *look* equal but their JSON serializations differ — a serialization-based cache would store them as two entries. New object literals on every render produce a new key on every render, so the cache never hits. Canonicalize: sort keys, drop undefined values, strip irrelevant fields.

TanStack Query handles object key ordering automatically but does not strip `undefined` or sort arrays — if you pass user-controlled filters, normalize them before they become a key.

**Incorrect (filter object built inline on every render, undefined fields, unsorted IDs):**

```tsx
function ProductList({ category, minPrice }: Filters) {
  // New object literal each render → new key reference each render
  const filters = { category, minPrice, ids: selectedIds };
  // selectedIds order varies; minPrice may be undefined when not set
  const { data } = useQuery({
    queryKey: ['products', filters],
    queryFn: () => fetchProducts(filters),
  });
  // Result: ['products', {category: 'A', minPrice: undefined, ids: [3,1,2]}] ≠
  //         ['products', {category: 'A', ids: [1,2,3]}] — cache misses
}
```

**Correct (canonicalize: strip undefined, sort arrays, fixed shape):**

```tsx
function canonicalKey<T extends object>(obj: T): T {
  return Object.fromEntries(
    Object.entries(obj)
      .filter(([, v]) => v !== undefined)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([k, v]) => [k, Array.isArray(v) ? [...v].sort() : v])
  ) as T;
}

function ProductList({ category, minPrice }: Filters) {
  const filters = useMemo(
    () => canonicalKey({ category, minPrice, ids: selectedIds }),
    [category, minPrice, selectedIds]
  );
  const { data } = useQuery({
    queryKey: ['products', filters],
    queryFn: () => fetchProducts(filters),
  });
}
```

**Tag-style alternative (avoid serializing complex filters entirely):**

```tsx
// Hash the filters once, use the hash as the key
const filterHash = useMemo(() => hashFilters(filters), [filters]);
useQuery({ queryKey: ['products', filterHash], queryFn: () => fetchProducts(filters) });
```

**Warning:** never include `Date.now()`, `Math.random()`, or non-serializable values (functions, class instances) in a cache key — every render produces a fresh key and the cache becomes a memory leak.

Reference: [TanStack Query — Query Keys](https://tanstack.com/query/latest/docs/framework/react/guides/query-keys)
