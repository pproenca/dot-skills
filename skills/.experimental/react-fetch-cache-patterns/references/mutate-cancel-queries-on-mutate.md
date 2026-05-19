---
title: Cancel In-Flight Queries Before Mutating Their Cache
impact: MEDIUM
impactDescription: prevents race conditions between mutation and refetch
tags: mutate, cancel-queries, race-conditions, optimistic
---

## Cancel In-Flight Queries Before Mutating Their Cache

Optimistic update writes `liked: true` into the cache. 200ms later, a background refetch (started before the mutation) lands with `liked: false` — overwriting your optimistic update and "un-liking" the post in the UI even though the mutation succeeded. The race is silent and intermittent. Fix: cancel any in-flight queries for the affected key inside `onMutate`, before writing the optimistic value.

This pattern is most critical with optimistic updates ([[mutate-optimistic-updates-with-rollback]]), but also applies any time `setQueryData` is called near in-flight refetches.

**Incorrect (no cancellation — background refetch can clobber optimistic update):**

```tsx
const like = useMutation({
  mutationFn: likePost,
  onMutate: ({ postId }) => {
    const previous = queryClient.getQueryData<Post>(['post', postId]);
    queryClient.setQueryData<Post>(['post', postId], { ...previous!, liked: true });
    return { previous };
    // 🚨 A refetch that started 100ms ago is still in flight.
    //    When it resolves, it overwrites our optimistic update with stale server state.
  },
});
```

**Correct (cancel in-flight queries first):**

```tsx
const like = useMutation({
  mutationFn: likePost,
  onMutate: async ({ postId }) => {
    // Cancel any refetches for this query so they don't overwrite our optimistic value
    await queryClient.cancelQueries({ queryKey: ['post', postId] });

    const previous = queryClient.getQueryData<Post>(['post', postId]);
    queryClient.setQueryData<Post>(['post', postId], { ...previous!, liked: true });
    return { previous };
  },
  onError: (_e, { postId }, ctx) => {
    if (ctx) queryClient.setQueryData(['post', postId], ctx.previous);
  },
  onSettled: (_d, _e, { postId }) => {
    // Now it's safe to refetch — the mutation result is settled
    queryClient.invalidateQueries({ queryKey: ['post', postId] });
  },
});
```

**Why this matters at scale:** any query with `refetchOnWindowFocus`, `refetchOnReconnect`, polling, or that's pending from a recent invalidation has an in-flight request. In a typical app, several queries are in flight at any moment — `cancelQueries` makes "before mutation" a known-quiet point.

**Cancellation requires AbortSignal forwarding:** for cancel to actually abort the network request, your queryFn must accept and use the `AbortSignal`. Otherwise cancel just unsubscribes the result; the request keeps running and consumes backend resources.

```ts
// Required — forward the signal
const fetchPost = ({ signal }: { signal: AbortSignal }) =>
  fetch(`/api/posts/${id}`, { signal }).then(r => r.json());
```

See [[resilience-abort-on-unmount]] for full AbortSignal patterns.

**Scope the cancellation to what you're about to mutate:**

```ts
// Too broad — cancels unrelated queries
await queryClient.cancelQueries(); // ❌

// Targeted — only the affected key
await queryClient.cancelQueries({ queryKey: ['post', postId] }); // ✅
```

**For list-affecting mutations (cancel list and detail):**

```tsx
const updatePost = useMutation({
  onMutate: async (input) => {
    await Promise.all([
      queryClient.cancelQueries({ queryKey: ['post', input.id] }),
      queryClient.cancelQueries({ queryKey: ['posts'] }), // cancel list refetches
    ]);
    // ... snapshot + optimistic updates
  },
});
```

Reference: [TanStack Query — Cancel Queries on Mutate](https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates#updating-a-single-todo)
