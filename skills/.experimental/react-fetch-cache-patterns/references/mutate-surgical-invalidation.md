---
title: Invalidate Surgically, Not Globally
impact: MEDIUM
impactDescription: reduces post-mutation refetch storms 10-100×
tags: mutate, invalidation, surgical, query-keys
---

## Invalidate Surgically, Not Globally

After a mutation, the easy path is `queryClient.invalidateQueries()` with no arguments — every cached query refetches. On a complex page with 50 active queries, that's a 50-request storm for what was typically a single-entity change. Be surgical: invalidate only the queries that the mutation actually affects, using the key factory pattern ([[cache-shared-key-factory]]) to target precisely.

The trade-off: precise invalidation requires understanding which queries depend on which entities. The key factory pattern makes this explicit.

**Incorrect (nuke everything — 50-request storm after a single update):**

```tsx
const updateProductName = useMutation({
  mutationFn: ({ id, name }) => api.updateProduct(id, { name }),
  onSuccess: () => {
    queryClient.invalidateQueries(); // refetches EVERY query: cart, user, settings, search...
  },
});
```

**Correct (target only what changed):**

```tsx
const updateProductName = useMutation({
  mutationFn: ({ id, name }) => api.updateProduct(id, { name }),
  onSuccess: (_, { id }) => {
    // Refetch the product detail; refetch any list that includes this product
    queryClient.invalidateQueries({ queryKey: productKeys.detail(id) });
    queryClient.invalidateQueries({ queryKey: productKeys.lists() });
    // That's it — user, settings, cart are untouched
  },
});
```

**Hierarchical invalidation with the key factory:**

```ts
export const productKeys = {
  all: ['products'] as const,
  lists: () => [...productKeys.all, 'list'] as const,
  list: (filters: Filters) => [...productKeys.lists(), filters] as const,
  details: () => [...productKeys.all, 'detail'] as const,
  detail: (id: string) => [...productKeys.details(), id] as const,
};

// Invalidate at the right level for the mutation's blast radius
queryClient.invalidateQueries({ queryKey: productKeys.detail(id) });  // one product
queryClient.invalidateQueries({ queryKey: productKeys.lists() });     // all list views
queryClient.invalidateQueries({ queryKey: productKeys.all });         // everything product-related
```

**Match exactly vs prefix matching:**

```ts
// Default: prefix match — invalidates ['products', 'list', { filter: 'A' }] AND ['products', 'list', { filter: 'B' }]
queryClient.invalidateQueries({ queryKey: productKeys.lists() });

// Exact match: only the precise key
queryClient.invalidateQueries({ queryKey: productKeys.list({ filter: 'A' }), exact: true });

// Predicate: full control
queryClient.invalidateQueries({
  predicate: (query) => {
    // Invalidate only list queries with a filter that included the changed product's category
    return query.queryKey[0] === 'products' &&
           query.queryKey[1] === 'list' &&
           (query.queryKey[2] as any)?.category === changedCategory;
  },
});
```

**Refetch only "active" queries (those currently mounted):**

```ts
queryClient.invalidateQueries({
  queryKey: productKeys.lists(),
  refetchType: 'active', // don't refetch background queries — they'll refetch when next mounted
});
```

**Common invalidation patterns by mutation type:**

| Mutation | Invalidate |
|----------|-----------|
| Update entity field | `detail(id)` + `lists()` |
| Create entity | `lists()` only (and possibly `setQueryData` to add to a known list) |
| Delete entity | `removeQueries(detail(id))` + `lists()` |
| Bulk operation | Match by predicate — affected entities only |

**When to invalidate everything:** logout (`queryClient.clear()`) or major context switch (user changed accounts). For normal mutations, surgical wins.

Reference: [TanStack Query — Query Invalidation](https://tanstack.com/query/latest/docs/framework/react/guides/query-invalidation)
