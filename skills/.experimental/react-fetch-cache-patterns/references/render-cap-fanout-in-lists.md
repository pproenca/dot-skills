---
title: Cap Fan-Out of Queries Inside Lists
impact: MEDIUM
impactDescription: prevents unbounded query fan-out as lists grow
tags: render, fanout, lists, useQuery, batching
---

## Cap Fan-Out of Queries Inside Lists

A list component renders N children, each containing a `useQuery`. As N grows from 10 to 100 to 1000, the number of queries grows linearly — and even with deduplication, that's 1000 cache subscriptions, 1000 effect setups, 1000 re-render triggers. The pattern works fine for small lists but degrades silently as data scales. Worse, when each child fetches a different key (e.g., per-item details), you get the N+1 problem.

The fix combines: (1) lift shared queries to the parent, (2) batch per-item fetches via DataLoader, (3) cap rendered items via virtualization.

**Incorrect (per-item useQuery inside a list — fan-out scales with N):**

```tsx
function CommentList({ commentIds }: { commentIds: string[] }) {
  return commentIds.map(id => <CommentRow key={id} commentId={id} />);
}

function CommentRow({ commentId }: { commentId: string }) {
  const { data: comment } = useQuery({
    queryKey: ['comment', commentId],
    queryFn: () => fetchComment(commentId), // 1 fetch per row × 200 rows = 200 fetches
  });
  const { data: author } = useQuery({
    queryKey: ['user', comment?.authorId],
    queryFn: () => fetchUser(comment!.authorId),
    enabled: !!comment,                      // chained per-row fetch — see [[orch-avoid-effect-chains]]
  });
}
```

**Correct (lift shared fetches to the parent, batch per-item via DataLoader):**

```tsx
function CommentList({ commentIds }: { commentIds: string[] }) {
  // Single fetch for all comments (uses bulk endpoint OR DataLoader)
  const { data: comments } = useQuery({
    queryKey: ['comments', commentIds.slice().sort()],
    queryFn: () => fetchCommentsBulk(commentIds),
    staleTime: 30_000,
  });

  // Single fetch for all authors (deduplicates per-author)
  const authorIds = useMemo(
    () => [...new Set(comments?.map(c => c.authorId) ?? [])],
    [comments]
  );
  const { data: authors } = useQuery({
    queryKey: ['users', authorIds.slice().sort()],
    queryFn: () => fetchUsersBulk(authorIds),
    enabled: authorIds.length > 0,
    staleTime: 60_000,
  });

  const authorById = useMemo(
    () => new Map(authors?.map(a => [a.id, a]) ?? []),
    [authors]
  );

  return comments?.map(c => (
    <CommentRow key={c.id} comment={c} author={authorById.get(c.authorId)} />
  ));
}

function CommentRow({ comment, author }: { comment: Comment; author?: User }) {
  // No fetches — pure rendering
}
```

**When per-item useQuery is legitimate:**
- The list is short and bounded (< 20 items) — fan-out is acceptable
- Each item's data is genuinely independent (e.g., a dashboard of different widget types each with their own backend)
- A bulk endpoint genuinely doesn't exist and DataLoader batching is in place
- The list is virtualized, so only ~20 children render concurrently

**Virtualization changes the math:**

```tsx
// With virtualization, only ~25 of 2000 rows mount at a time → fan-out is bounded
const virtualizer = useVirtualizer({ count: items.length, /* ... */ });
return virtualizer.getVirtualItems().map(vRow => (
  <CommentRow key={vRow.key} commentId={items[vRow.index].id} />
  // 25 useQuery instances active regardless of items.length
));
// Acceptable, but still — bulk loading the visible window is even better
```

**Anti-pattern (don't useQueries with massive arrays):**

```tsx
// useQueries with 1000 entries creates 1000 subscriptions
const results = useQueries({
  queries: ids.map(id => ({ queryKey: ['x', id], queryFn: () => fetchX(id) })),
});
// → Use one bulk query instead, OR DataLoader if the API only supports per-item fetch
```

Reference: [TanStack Query — useQueries](https://tanstack.com/query/latest/docs/framework/react/reference/useQueries) | [[orch-batch-n-plus-one-fanout]]
