---
title: Use setQueryData over Invalidate When the Result is Known
impact: MEDIUM
impactDescription: eliminates 1 refetch per mutation
tags: mutate, set-query-data, invalidate, network
---

## Use setQueryData over Invalidate When the Result is Known

Invalidating a query schedules a refetch — a network round-trip the user pays for. But when the mutation response already contains the updated entity (most REST and GraphQL responses do), there's no need to refetch: write the response directly into the cache with `setQueryData`. Zero extra requests, immediate UI update.

This is the canonical pattern for "POST returns the created object" and "PUT returns the updated object."

**Incorrect (mutation returns the updated entity, but we throw it away and refetch):**

```tsx
const updateProduct = useMutation({
  mutationFn: (input: ProductUpdate) => api.updateProduct(input), // returns updated Product
  onSuccess: (_response, input) => {
    // We had the new data right there but ignore it — fire another request
    queryClient.invalidateQueries({ queryKey: ['product', input.id] });
  },
});
```

**Correct (write the response directly):**

```tsx
const updateProduct = useMutation({
  mutationFn: (input: ProductUpdate) => api.updateProduct(input),
  onSuccess: (updated, input) => {
    // Write the server's response directly into the cache — no refetch needed
    queryClient.setQueryData(productKeys.detail(input.id), updated);

    // Also surgically update any list views that include this product
    queryClient.setQueriesData<Product[]>(
      { queryKey: productKeys.lists() },
      (old) => old?.map(p => p.id === updated.id ? updated : p)
    );
  },
});
```

**For "create" mutations (append to a list):**

```tsx
const createComment = useMutation({
  mutationFn: (input: CommentInput) => api.createComment(input),
  onSuccess: (created, input) => {
    queryClient.setQueryData<Comment[]>(
      ['comments', input.postId],
      (old) => old ? [...old, created] : [created]
    );
  },
});
```

**For "delete" mutations (remove from cache, drop from lists):**

```tsx
const deleteProduct = useMutation({
  mutationFn: ({ id }: { id: string }) => api.deleteProduct(id),
  onSuccess: (_response, { id }) => {
    queryClient.removeQueries({ queryKey: productKeys.detail(id) });
    queryClient.setQueriesData<Product[]>(
      { queryKey: productKeys.lists() },
      (old) => old?.filter(p => p.id !== id)
    );
  },
});
```

**When invalidation IS the right choice:**
- The mutation has effects beyond the entity itself (e.g., updating a product changes "related products" — refetch related)
- The server applied business logic the client can't predict (computed fields, denormalized counts, audit fields)
- Multiple queries share denormalized state hard to update consistently in code
- You don't trust the response shape (third-party API returns partial responses)

**Pattern: setQueryData first, then invalidate as a safety net:**

```tsx
const updateProduct = useMutation({
  mutationFn: (input: ProductUpdate) => api.updateProduct(input),
  onSuccess: (updated, input) => {
    // Immediate cache update for instant UX
    queryClient.setQueryData(productKeys.detail(input.id), updated);

    // After a brief delay, refetch to catch denormalized fields we couldn't predict
    setTimeout(
      () => queryClient.invalidateQueries({ queryKey: productKeys.detail(input.id) }),
      1000
    );
  },
});
```

**Pair with [[mutate-optimistic-updates-with-rollback]]:** the optimistic update writes immediately; `setQueryData` in `onSuccess` reconciles with server response; `onError` rolls back. End-to-end: no network round-trip is ever in the critical path.

Reference: [TanStack Query — Updates from Mutation Responses](https://tanstack.com/query/latest/docs/framework/react/guides/updates-from-mutation-responses)
