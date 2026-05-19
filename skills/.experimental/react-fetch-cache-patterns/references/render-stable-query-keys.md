---
title: Stabilize Object-Shaped Query Keys
impact: MEDIUM
impactDescription: prevents new fetch on every parent render
tags: render, query-keys, usememo, stability
---

## Stabilize Object-Shaped Query Keys

`queryKey: ['products', { filter: 'active', sort: 'name' }]` looks stable — but if `{ filter: 'active', sort: 'name' }` is created inline, a new object reference exists on every render. While TanStack Query does deep-compare keys (it tolerates new-but-equal objects), upstream code (memoized selectors, custom hooks, dependency arrays in `useEffect`) often does reference equality. The result: queries appear to refetch needlessly, or downstream `useEffect`s fire on every parent render.

Stabilize complex keys with `useMemo` keyed on their primitive inputs. The key becomes a stable reference whose identity changes only when its inputs do.

**Incorrect (key recreated every render — downstream comparisons fail):**

```tsx
function ProductList({ category, sort }: Props) {
  // New object reference every render of ProductList
  const { data } = useQuery({
    queryKey: ['products', { category, sort }],
    queryFn: () => fetchProducts({ category, sort }),
  });

  // Downstream consumers see a "different" key each render even though values are equal
  useEffect(() => {
    track('view', { category, sort }); // fires every render! 🚨
  }, [{ category, sort }]); // ← inline object is never === itself
}
```

**Correct (memoize the key object):**

```tsx
function ProductList({ category, sort }: Props) {
  const filters = useMemo(() => ({ category, sort }), [category, sort]);

  const { data } = useQuery({
    queryKey: ['products', filters],
    queryFn: () => fetchProducts(filters),
  });

  useEffect(() => {
    track('view', filters);
  }, [filters]); // stable; fires only when category or sort actually change
}
```

**Better: factor key construction into a hook with a key factory:**

```tsx
// src/queries/use-products.ts
export const productKeys = {
  list: (filters: Filters) => ['products', 'list', filters] as const,
};

export function useProducts(filters: Filters) {
  const stableFilters = useMemo(
    () => filters,
    [filters.category, filters.sort, filters.minPrice]
  );
  return useQuery({
    queryKey: productKeys.list(stableFilters),
    queryFn: () => fetchProducts(stableFilters),
  });
}

// Consumer code is clean and the key construction is reusable + testable
function ProductList(props: Props) {
  const { data } = useProducts({ category: props.category, sort: props.sort });
}
```

**For computed/derived keys, push computation into useMemo:**

```tsx
// Filter pipeline that produces a complex key
const filters = useMemo(
  () => ({
    ...baseFilters,
    expandedCategories: expandCategoryTree(baseFilters.category, categoryTree),
    locale: i18n.locale,
  }),
  [baseFilters, categoryTree, i18n.locale]
);
```

**Watch for:**
- `Date` objects in keys — `new Date()` per render produces non-equal objects; freeze it or use ISO strings
- `Set` and `Map` — they're never structurally equal to a new copy; use plain objects or arrays
- Functions in keys — never. Functions break serialization, and inline functions change every render

**For very large state objects, hash them:**

```tsx
import { hash } from 'object-hash';

const filterHash = useMemo(() => hash(complexFilters), [complexFilters]);
useQuery({
  queryKey: ['report', filterHash],
  queryFn: () => fetchReport(complexFilters),
});
```

Reference: [TanStack Query — Query Keys](https://tanstack.com/query/latest/docs/framework/react/guides/query-keys) | [TkDodo — Status Checks in React Query](https://tkdodo.eu/blog/status-checks-in-react-query)
