---
title: Centralize Cache Keys in a Key Factory
impact: CRITICAL
impactDescription: prevents read/write key drift
tags: cache, keys, factory, invalidation, organization
---

## Centralize Cache Keys in a Key Factory

Key drift is a silent killer: a `useQuery` reads from `['products', filters]` and a mutation invalidates `['product', filters]` (singular vs plural). The mutation succeeds, the cache appears intact, the UI shows stale data, and you spend an afternoon debugging "cache invalidation." Define keys once in a typed factory and import them everywhere — reads, writes, prefetches, invalidations all reference the same source of truth.

The factory also gives you free hierarchical invalidation: invalidating `productKeys.all` invalidates every key starting with `['products', ...]`.

**Incorrect (keys defined inline, easy to drift):**

```tsx
// somewhere in a component
useQuery({ queryKey: ['products', filters], queryFn: () => fetchProducts(filters) });

// in a mutation, six files away
queryClient.invalidateQueries({ queryKey: ['product'] }); // ❌ typo, wrong key
// invalidation looks fine in code review; runtime: nothing invalidates
```

**Correct (one source of truth):**

```tsx
// src/queries/product-keys.ts
export const productKeys = {
  all: ['products'] as const,
  lists: () => [...productKeys.all, 'list'] as const,
  list: (filters: ProductFilters) => [...productKeys.lists(), filters] as const,
  details: () => [...productKeys.all, 'detail'] as const,
  detail: (id: string) => [...productKeys.details(), id] as const,
};

// Reads
useQuery({ queryKey: productKeys.list(filters), queryFn: () => fetchProducts(filters) });
useQuery({ queryKey: productKeys.detail(id), queryFn: () => fetchProduct(id) });

// Mutation — surgical invalidation, no string typos possible
useMutation({
  mutationFn: updateProduct,
  onSuccess: (_, { id }) => {
    queryClient.invalidateQueries({ queryKey: productKeys.detail(id) });
    queryClient.invalidateQueries({ queryKey: productKeys.lists() }); // all list views
  },
});

// Logout — nuke all product queries
queryClient.removeQueries({ queryKey: productKeys.all });
```

**Benefits:**
- Type safety: TypeScript catches misuse at compile time
- Refactor confidence: rename a key, every reference updates with editor rename
- Hierarchical invalidation: invalidate at any level (`all` > `lists()` > `list(filters)`)
- Single grep location to audit cache structure

Reference: [TanStack Query — Effective React Query Keys](https://tkdodo.eu/blog/effective-react-query-keys)
