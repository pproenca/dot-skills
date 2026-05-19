---
title: Apply Optimistic Updates with Rollback on Failure
impact: MEDIUM
impactDescription: eliminates 200-800ms perceived mutation latency
tags: mutate, optimistic, rollback, ux, on-mutate
---

## Apply Optimistic Updates with Rollback on Failure

When the user clicks "like", waiting 300ms for the server's confirmation before updating the heart icon makes the app feel sluggish. Optimistic updates: apply the change to the cache instantly, fire the mutation in the background, and if it fails, roll back. Most mutations succeed — so most users see an instant response — and the rare failure rewinds cleanly.

Pair it with [[resilience-no-auto-retry-mutations]]: optimistic UX + idempotency-keyed mutations + bounded retries is the safe combination.

**Incorrect (block on server — heart turns red 300ms later):**

```tsx
const like = useMutation({
  mutationFn: likePost,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['post', postId] }),
});

<HeartIcon
  liked={post.liked}
  onClick={() => like.mutate({ postId })}
  loading={like.isPending} // user sees a spinner for 300ms
/>
```

**Correct (instant feedback with snapshot/rollback):**

```tsx
const like = useMutation({
  mutationFn: likePost,
  onMutate: async ({ postId }) => {
    // 1. Cancel in-flight queries for this post so they don't overwrite our optimistic update
    await queryClient.cancelQueries({ queryKey: ['post', postId] });

    // 2. Snapshot the current value (for rollback)
    const previous = queryClient.getQueryData<Post>(['post', postId]);

    // 3. Optimistically update
    if (previous) {
      queryClient.setQueryData<Post>(['post', postId], {
        ...previous,
        liked: true,
        likeCount: previous.likeCount + 1,
      });
    }

    return { previous }; // returned context goes to onError / onSettled
  },
  onError: (err, { postId }, ctx) => {
    // 4. Rollback to the snapshot on failure
    if (ctx?.previous) queryClient.setQueryData(['post', postId], ctx.previous);
    toast.error('Failed to like — please try again');
  },
  onSettled: (data, error, { postId }) => {
    // 5. Always refetch on settle to reconcile with server truth
    queryClient.invalidateQueries({ queryKey: ['post', postId] });
  },
});

<HeartIcon
  liked={post.liked}
  onClick={() => like.mutate({ postId: post.id })} // no isPending check needed
/>
```

**Optimistic updates for lists (add an item with a temporary ID):**

```tsx
const create = useMutation({
  mutationFn: createComment,
  onMutate: async (newComment) => {
    await queryClient.cancelQueries({ queryKey: ['comments', postId] });
    const previous = queryClient.getQueryData<Comment[]>(['comments', postId]) ?? [];

    // Append optimistic comment with a tempId
    const tempId = `temp-${Date.now()}`;
    queryClient.setQueryData<Comment[]>(['comments', postId], [
      ...previous,
      { ...newComment, id: tempId, pending: true },
    ]);

    return { previous, tempId };
  },
  onError: (_e, _vars, ctx) => {
    if (ctx) queryClient.setQueryData(['comments', postId], ctx.previous);
  },
  onSuccess: (serverComment, _vars, ctx) => {
    // Replace the temp comment with the server version (real ID)
    queryClient.setQueryData<Comment[]>(['comments', postId], comments =>
      comments?.map(c => c.id === ctx?.tempId ? serverComment : c) ?? [serverComment]
    );
  },
});
```

**When NOT to optimize optimistically:**
- Mutations whose server-side outcome is unpredictable (e.g., "reserve seat" — the seat may already be taken)
- Mutations that compute new data unknowable client-side (e.g., "generate AI summary")
- Critical-path mutations where wrong-then-rollback is worse than waiting (charge processing, security-sensitive)

**Race condition watch:** if two mutations on the same entity race, the second `onMutate` snapshot may already reflect the first's optimistic update. Always cancel queries in `onMutate` to flush any in-flight reads that might land between snapshot and revert.

Reference: [TanStack Query — Optimistic Updates](https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates)
